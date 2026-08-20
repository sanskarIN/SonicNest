import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';
import 'package:share_plus/share_plus.dart';

import 'core/theme.dart';
import 'core/wav_encoder.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SonicNestWebApp());
}

class SonicNestWebApp extends StatelessWidget {
  const SonicNestWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SonicNest Web',
      debugShowCheckedModeBanner: false,
      theme: SonicNestTheme.light(),
      darkTheme: SonicNestTheme.dark(),
      themeMode: ThemeMode.system,
      home: const WebRecorderScreen(),
    );
  }
}

class WebRecording {
  const WebRecording({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.bytes,
    required this.duration,
  });

  final int id;
  final String title;
  final DateTime createdAt;
  final Uint8List bytes;
  final Duration duration;
}

class WebRecorderScreen extends StatefulWidget {
  const WebRecorderScreen({super.key});

  @override
  State<WebRecorderScreen> createState() => _WebRecorderScreenState();
}

class _WebRecorderScreenState extends State<WebRecorderScreen> {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  final List<WebRecording> _recordings = <WebRecording>[];

  StreamSubscription<Uint8List>? _recordingSubscription;
  StreamSubscription<Amplitude>? _amplitudeSubscription;
  StreamSubscription<PlayerState>? _playerSubscription;
  Timer? _timer;
  BytesBuilder? _capturedBytes;

  RecordConfig _effectiveConfig = const RecordConfig(
    encoder: AudioEncoder.pcm16bits,
    sampleRate: 44100,
    numChannels: 1,
    autoGain: true,
    echoCancel: true,
    noiseSuppress: true,
  );
  RecordState _recordState = RecordState.stop;
  Duration _elapsed = Duration.zero;
  double _amplitudeDb = -60.0;
  bool _busy = false;
  bool _autoGain = true;
  bool _echoCancel = true;
  bool _noiseSuppress = true;
  int _channels = 1;
  InputDevice? _selectedDevice;
  List<InputDevice> _devices = const <InputDevice>[];
  int? _playingId;
  int _nextRecordingId = 1;

  bool get _isRecording => _recordState == RecordState.record;
  bool get _isPaused => _recordState == RecordState.pause;
  bool get _hasActiveCapture => _isRecording || _isPaused;

  @override
  void initState() {
    super.initState();
    _recorder.setOnConfigChanged((config) {
      if (!mounted) return;
      setState(() => _effectiveConfig = config);
    });
    _playerSubscription = _player.playerStateStream.listen((state) {
      if (!mounted || state.processingState != ProcessingState.completed) return;
      setState(() => _playingId = null);
    });
    unawaited(_refreshDevices(requestPermission: false));
  }

  @override
  void dispose() {
    _timer?.cancel();
    unawaited(_recordingSubscription?.cancel());
    unawaited(_amplitudeSubscription?.cancel());
    unawaited(_playerSubscription?.cancel());
    unawaited(_recorder.dispose());
    unawaited(_player.dispose());
    super.dispose();
  }

  Future<void> _refreshDevices({required bool requestPermission}) async {
    try {
      if (requestPermission && !await _recorder.hasPermission()) {
        _showMessage('Microphone permission is required to record.');
        return;
      }
      final devices = await _recorder.listInputDevices();
      if (!mounted) return;
      setState(() {
        _devices = devices;
        if (_selectedDevice != null &&
            !devices.any((device) => device.id == _selectedDevice!.id)) {
          _selectedDevice = null;
        }
      });
    } catch (_) {
      if (requestPermission) {
        _showMessage('Unable to enumerate browser audio inputs.');
      }
    }
  }

  Future<void> _startRecording() async {
    if (_busy || _hasActiveCapture) return;
    setState(() => _busy = true);
    try {
      if (!await _recorder.hasPermission()) {
        _showMessage('Allow microphone access in your browser to record.');
        return;
      }

      await _refreshDevices(requestPermission: false);
      final config = RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 44100,
        numChannels: _channels,
        device: _selectedDevice,
        autoGain: _autoGain,
        echoCancel: _echoCancel,
        noiseSuppress: _noiseSuppress,
      );
      _effectiveConfig = config;
      _capturedBytes = BytesBuilder(copy: false);

      final stream = await _recorder.startStream(config);
      _recordingSubscription = stream.listen(
        (chunk) => _capturedBytes?.add(chunk),
        onError: (_) => _showMessage('Browser audio capture failed.'),
      );

      await _amplitudeSubscription?.cancel();
      _amplitudeSubscription = _recorder
          .onAmplitudeChanged(const Duration(milliseconds: 120))
          .listen((value) {
            if (!mounted) return;
            setState(() {
              _amplitudeDb = value.current.clamp(-60.0, 0.0).toDouble();
            });
          });

      _elapsed = Duration.zero;
      _timer?.cancel();
      if (!mounted) return;
      setState(() => _recordState = RecordState.record);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted || !_isRecording) return;
        setState(() => _elapsed += const Duration(seconds: 1));
      });
    } catch (error) {
      _capturedBytes = null;
      _showMessage('Could not start recording: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pauseOrResume() async {
    if (_busy || !_hasActiveCapture) return;
    setState(() => _busy = true);
    try {
      if (_isPaused) {
        await _recorder.resume();
        if (mounted) setState(() => _recordState = RecordState.record);
      } else {
        await _recorder.pause();
        if (mounted) setState(() => _recordState = RecordState.pause);
      }
    } catch (error) {
      _showMessage('Could not change recording state: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _stopRecording() async {
    if (_busy || !_hasActiveCapture) return;
    setState(() => _busy = true);
    try {
      await _recorder.stop();
      _timer?.cancel();
      _timer = null;
      if (mounted) setState(() => _recordState = RecordState.stop);

      await _recordingSubscription?.cancel();
      _recordingSubscription = null;
      await _amplitudeSubscription?.cancel();
      _amplitudeSubscription = null;

      final pcm = _capturedBytes?.takeBytes() ?? Uint8List(0);
      _capturedBytes = null;
      if (pcm.isEmpty) {
        _showMessage('No audio data was captured.');
        return;
      }

      final wav = pcm16ToWav(
        pcm,
        sampleRate: _effectiveConfig.sampleRate,
        channels: _effectiveConfig.numChannels,
      );
      final id = _nextRecordingId++;
      final recording = WebRecording(
        id: id,
        title: 'Web recording $id',
        createdAt: DateTime.now(),
        bytes: wav,
        duration: _elapsed,
      );
      if (!mounted) return;
      setState(() {
        _amplitudeDb = -60.0;
        _recordings.insert(0, recording);
      });
    } catch (error) {
      _showMessage('Could not finish recording: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancelRecording() async {
    if (_busy || !_hasActiveCapture) return;
    setState(() => _busy = true);
    try {
      await _recorder.cancel();
      _capturedBytes = null;
      _timer?.cancel();
      _timer = null;
      await _recordingSubscription?.cancel();
      _recordingSubscription = null;
      await _amplitudeSubscription?.cancel();
      _amplitudeSubscription = null;
      if (!mounted) return;
      setState(() {
        _recordState = RecordState.stop;
        _elapsed = Duration.zero;
        _amplitudeDb = -60.0;
      });
    } catch (error) {
      _showMessage('Could not cancel recording: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _play(WebRecording recording) async {
    try {
      if (_playingId == recording.id && _player.playing) {
        await _player.pause();
        if (mounted) setState(() {});
        return;
      }
      await _player.setAudioSource(_BytesAudioSource(recording.bytes));
      if (!mounted) return;
      setState(() => _playingId = recording.id);
      unawaited(_player.play());
    } catch (error) {
      _showMessage('Could not play this recording: $error');
    }
  }

  Future<void> _download(WebRecording recording) async {
    try {
      final safeTimestamp = recording.createdAt
          .toIso8601String()
          .replaceAll(':', '-')
          .replaceAll('.', '-');
      await SharePlus.instance.share(
        ShareParams(
          files: <XFile>[
            XFile.fromData(recording.bytes, mimeType: 'audio/wav'),
          ],
          fileNameOverrides: <String>['sonicnest-$safeTimestamp.wav'],
          title: recording.title,
          downloadFallbackEnabled: true,
        ),
      );
    } catch (error) {
      _showMessage('Could not share or download this recording: $error');
    }
  }

  void _delete(WebRecording recording) {
    if (_playingId == recording.id) {
      unawaited(_player.stop());
      _playingId = null;
    }
    setState(() => _recordings.removeWhere((item) => item.id == recording.id));
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final contentWidth = width > 980 ? 920.0 : double.infinity;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SonicNest Web'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Refresh microphones',
            onPressed: _hasActiveCapture
                ? null
                : () => _refreshDevices(requestPermission: true),
            icon: const Icon(Icons.mic_external_on_outlined),
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: contentWidth,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            children: <Widget>[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        'Browser recorder',
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Record locally in your browser. SonicNest does not upload microphone audio. Download or share finished recordings to keep them beyond this browser session.',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 22),
                      _AmplitudeMeter(valueDb: _amplitudeDb),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          _formatDuration(_elapsed),
                          style: theme.textTheme.displaySmall,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: <Widget>[
                          FilledButton.icon(
                            onPressed: _busy || _hasActiveCapture
                                ? null
                                : _startRecording,
                            icon: const Icon(Icons.fiber_manual_record),
                            label: const Text('Record'),
                          ),
                          OutlinedButton.icon(
                            onPressed: _busy || !_hasActiveCapture
                                ? null
                                : _pauseOrResume,
                            icon: Icon(
                              _isPaused ? Icons.play_arrow : Icons.pause,
                            ),
                            label: Text(_isPaused ? 'Resume' : 'Pause'),
                          ),
                          FilledButton.tonalIcon(
                            onPressed: _busy || !_hasActiveCapture
                                ? null
                                : _stopRecording,
                            icon: const Icon(Icons.stop),
                            label: const Text('Stop'),
                          ),
                          TextButton.icon(
                            onPressed: _busy || !_hasActiveCapture
                                ? null
                                : _cancelRecording,
                            icon: const Icon(Icons.close),
                            label: const Text('Cancel'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text('Input settings', style: theme.textTheme.titleLarge),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String?>(
                        initialValue: _selectedDevice?.id,
                        decoration: const InputDecoration(
                          labelText: 'Microphone',
                        ),
                        items: <DropdownMenuItem<String?>>[
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Browser default'),
                          ),
                          ..._devices.map(
                            (device) => DropdownMenuItem<String?>(
                              value: device.id,
                              child: Text(
                                device.label.isEmpty
                                    ? 'Microphone ${device.id}'
                                    : device.label,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        onChanged: _hasActiveCapture
                            ? null
                            : (id) {
                                setState(() {
                                  _selectedDevice = id == null
                                      ? null
                                      : _devices.firstWhere(
                                          (device) => device.id == id,
                                        );
                                });
                              },
                      ),
                      const SizedBox(height: 12),
                      SegmentedButton<int>(
                        segments: const <ButtonSegment<int>>[
                          ButtonSegment<int>(value: 1, label: Text('Mono')),
                          ButtonSegment<int>(value: 2, label: Text('Stereo')),
                        ],
                        selected: <int>{_channels},
                        onSelectionChanged: _hasActiveCapture
                            ? null
                            : (values) =>
                                  setState(() => _channels = values.first),
                      ),
                      const SizedBox(height: 10),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        value: _autoGain,
                        onChanged: _hasActiveCapture
                            ? null
                            : (value) => setState(() => _autoGain = value),
                        title: const Text('Automatic gain'),
                      ),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        value: _echoCancel,
                        onChanged: _hasActiveCapture
                            ? null
                            : (value) => setState(() => _echoCancel = value),
                        title: const Text('Echo cancellation'),
                      ),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        value: _noiseSuppress,
                        onChanged: _hasActiveCapture
                            ? null
                            : (value) =>
                                  setState(() => _noiseSuppress = value),
                        title: const Text('Noise suppression'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text('This session', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 10),
              if (_recordings.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No browser recordings yet. Finished recordings appear here until the page is refreshed or closed.',
                    ),
                  ),
                )
              else
                ..._recordings.map(
                  (recording) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Card(
                      child: ListTile(
                        leading: IconButton(
                          tooltip: 'Play or pause',
                          onPressed: () => _play(recording),
                          icon: Icon(
                            _playingId == recording.id && _player.playing
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_fill,
                          ),
                        ),
                        title: Text(recording.title),
                        subtitle: Text(
                          '${_formatDuration(recording.duration)} • WAV • ${_formatBytes(recording.bytes.length)}',
                        ),
                        trailing: Wrap(
                          spacing: 4,
                          children: <Widget>[
                            IconButton(
                              tooltip: 'Share or download',
                              onPressed: () => _download(recording),
                              icon: const Icon(Icons.download_outlined),
                            ),
                            IconButton(
                              tooltip: 'Delete from this session',
                              onPressed: () => _delete(recording),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 18),
              Text(
                'Web capability note: recording, pause/resume, amplitude, microphone selection, playback, and share/download are browser-native. FFmpeg editing and durable managed-library storage remain native-app capabilities because the current FFmpeg and path-provider dependencies do not support Web.',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmplitudeMeter extends StatelessWidget {
  const _AmplitudeMeter({required this.valueDb});

  final double valueDb;

  @override
  Widget build(BuildContext context) {
    final normalized = ((valueDb + 60.0) / 60.0)
        .clamp(0.0, 1.0)
        .toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        LinearProgressIndicator(value: normalized),
        const SizedBox(height: 6),
        Text(
          '${valueDb.toStringAsFixed(1)} dBFS',
          textAlign: TextAlign.end,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}

class _BytesAudioSource extends StreamAudioSource {
  _BytesAudioSource(this.bytes);

  final Uint8List bytes;

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= bytes.length;
    return StreamAudioResponse(
      sourceLength: bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream<List<int>>.value(bytes.sublist(start, end)),
      contentType: 'audio/wav',
    );
  }
}

String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
}

String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  final kib = bytes / 1024;
  if (kib < 1024) return '${kib.toStringAsFixed(1)} KiB';
  return '${(kib / 1024).toStringAsFixed(1)} MiB';
}
