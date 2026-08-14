import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../core/constants.dart';
import '../core/naming_template.dart';
import '../models/recording_entry.dart';
import '../models/recording_settings.dart';
import 'audio_processor.dart';
import 'background_service_bridge.dart';
import 'storage_service.dart';

enum RecorderStatus { idle, countdown, recording, paused, processing, error }

class RecorderResult {
  const RecorderResult({
    required this.path,
    required this.title,
    required this.duration,
    required this.settings,
    required this.waveform,
    required this.markers,
  });

  final String path;
  final String title;
  final Duration duration;
  final RecordingSettings settings;
  final List<double> waveform;
  final List<RecordingMarker> markers;
}

class RecorderService extends ChangeNotifier {
  RecorderService(this._storage, this._processor, this._background);

  final StorageService _storage;
  final AudioProcessor _processor;
  final BackgroundServiceBridge _background;
  final AudioRecorder _recorder = AudioRecorder();
  final Stopwatch _stopwatch = Stopwatch();
  final List<double> _waveform = [];
  final List<RecordingMarker> _markers = [];

  StreamSubscription<Amplitude>? _amplitudeSubscription;
  Timer? _timer;
  bool _transitioning = false;
  String? _capturePath;
  String? _targetPath;
  String? _title;
  RecordingSettings? _settings;
  InputDevice? _selectedDevice;
  bool _postTranscode = false;
  bool _screenWakeEnabled = false;
  int _countdownGeneration = 0;

  RecorderStatus status = RecorderStatus.idle;
  Duration elapsed = Duration.zero;
  double amplitude = 0;
  double peakAmplitude = 0;
  bool clipping = false;
  int countdownRemaining = 0;
  String? lastError;
  RecordConfig? effectiveConfig;

  bool get isActive =>
      status == RecorderStatus.countdown ||
      status == RecorderStatus.recording ||
      status == RecorderStatus.paused;
  bool get isCapturing =>
      status == RecorderStatus.recording || status == RecorderStatus.paused;
  List<double> get waveform => List.unmodifiable(_waveform);
  List<RecordingMarker> get markers => List.unmodifiable(_markers);
  InputDevice? get selectedDevice => _selectedDevice;

  Future<List<InputDevice>> listInputDevices() => _recorder.listInputDevices();

  void selectInputDevice(InputDevice? device) {
    if (isActive) {
      throw StateError(
        'Input device cannot be changed during an active recording.',
      );
    }
    _selectedDevice = device;
    notifyListeners();
  }

  Future<String> _autoTitle(RecordingSettings settings) async {
    final sequence = await _storage.nextRecordingSequence();
    return renderRecordingName(
      template: settings.namingTemplate,
      timestamp: DateTime.now(),
      sequence: sequence,
      prefix: settings.namingPrefix,
      suffix: settings.namingSuffix,
      category: settings.namingCategory,
    );
  }

  Future<void> start(RecordingSettings settings) async {
    if (_transitioning || status != RecorderStatus.idle) {
      return;
    }
    _transitioning = true;
    final countdownGeneration = ++_countdownGeneration;
    try {
      lastError = null;
      final permission = await _recorder.hasPermission();
      if (!permission) {
        throw StateError('Microphone permission was not granted.');
      }

      _settings = settings;
      _title = await _autoTitle(settings);
      _waveform.clear();
      _markers.clear();
      peakAmplitude = 0;
      amplitude = 0;
      clipping = false;
      elapsed = Duration.zero;
      effectiveConfig = null;

      if (settings.countdownSeconds > 0) {
        status = RecorderStatus.countdown;
        countdownRemaining = settings.countdownSeconds;
        notifyListeners();
        while (countdownRemaining > 0) {
          await Future<void>.delayed(const Duration(seconds: 1));
          if (countdownGeneration != _countdownGeneration ||
              status != RecorderStatus.countdown) {
            return;
          }
          countdownRemaining--;
          notifyListeners();
        }
      }

      if (countdownGeneration != _countdownGeneration) {
        return;
      }

      if (settings.keepScreenAwake) {
        await WakelockPlus.enable();
        _screenWakeEnabled = true;
      }

      final requestedEncoder = settings.format.nativeEncoder;
      final directSupported =
          !settings.format.needsTranscode &&
          await _recorder.isEncoderSupported(requestedEncoder);
      AudioEncoder captureEncoder;
      String captureExtension;
      if (directSupported) {
        captureEncoder = requestedEncoder;
        captureExtension = settings.format.extension;
        _postTranscode = false;
      } else if (await _recorder.isEncoderSupported(AudioEncoder.wav)) {
        captureEncoder = AudioEncoder.wav;
        captureExtension = 'wav';
        _postTranscode = true;
      } else if (await _recorder.isEncoderSupported(AudioEncoder.aacLc)) {
        captureEncoder = AudioEncoder.aacLc;
        captureExtension = 'm4a';
        _postTranscode = true;
      } else {
        throw UnsupportedError(
          'No compatible capture encoder is available on this platform.',
        );
      }

      _capturePath = _postTranscode
          ? await _storage.uniqueTempPath('${_title}_capture', captureExtension)
          : await _storage.uniqueRecordingPath(_title!, captureExtension);
      _targetPath = _postTranscode
          ? await _storage.uniqueRecordingPath(
              _title!,
              settings.format.extension,
            )
          : _capturePath;

      await _recorder.setOnConfigChanged((config) {
        effectiveConfig = config;
        notifyListeners();
      });

      final config = RecordConfig(
        encoder: captureEncoder,
        bitRate: settings.bitRate,
        sampleRate: settings.sampleRate,
        numChannels: settings.channels,
        device: _selectedDevice,
        autoGain: settings.autoGain,
        echoCancel: settings.echoCancel,
        noiseSuppress: settings.noiseSuppress,
        audioInterruption: AudioInterruptionMode.pause,
      );

      await _background.start();
      await _recorder.start(config, path: _capturePath!);
      _stopwatch
        ..reset()
        ..start();
      _timer = Timer.periodic(const Duration(milliseconds: 250), (_) {
        elapsed = _stopwatch.elapsed;
        notifyListeners();
      });
      _amplitudeSubscription = _recorder
          .onAmplitudeChanged(const Duration(milliseconds: 100))
          .listen(
            _onAmplitude,
            onError: (Object error, StackTrace stack) {
              lastError = 'Amplitude monitor error: $error';
              notifyListeners();
            },
          );
      countdownRemaining = 0;
      status = RecorderStatus.recording;
      notifyListeners();
    } catch (error) {
      status = RecorderStatus.error;
      countdownRemaining = 0;
      lastError = error.toString();
      await _safeStopBackground();
      await _safeDisableScreenWake();
      await _cleanupFailedCapture();
      notifyListeners();
      rethrow;
    } finally {
      _transitioning = false;
    }
  }

  void _onAmplitude(Amplitude value) {
    final currentDb = value.current.isFinite ? value.current : -160.0;
    final normalized = ((currentDb + 60) / 60).clamp(0.0, 1.0).toDouble();
    amplitude = normalized;
    peakAmplitude = math.max(peakAmplitude, normalized);
    clipping = currentDb > -1.0;
    if (_waveform.length >= AppConstants.maxWaveformSamples) {
      for (var index = 0; index < _waveform.length ~/ 2; index++) {
        _waveform[index] = math.max(
          _waveform[index * 2],
          _waveform[index * 2 + 1],
        );
      }
      _waveform.removeRange(_waveform.length ~/ 2, _waveform.length);
    }
    _waveform.add(normalized);
    notifyListeners();
  }

  Future<void> pause() async {
    if (_transitioning || status != RecorderStatus.recording) {
      return;
    }
    _transitioning = true;
    try {
      await _recorder.pause();
      _stopwatch.stop();
      status = RecorderStatus.paused;
      notifyListeners();
    } finally {
      _transitioning = false;
    }
  }

  Future<void> resume() async {
    if (_transitioning || status != RecorderStatus.paused) {
      return;
    }
    _transitioning = true;
    try {
      await _recorder.resume();
      _stopwatch.start();
      status = RecorderStatus.recording;
      notifyListeners();
    } finally {
      _transitioning = false;
    }
  }

  void addMarker({String? label, String note = ''}) {
    if (!isCapturing) {
      return;
    }
    final index = _markers.length + 1;
    _markers.add(
      RecordingMarker(
        positionMs: elapsed.inMilliseconds,
        label: label?.trim().isNotEmpty == true
            ? label!.trim()
            : 'Marker $index',
        note: note.trim(),
      ),
    );
    notifyListeners();
  }

  Future<RecorderResult> stop() async {
    if (_transitioning || !isCapturing) {
      throw StateError('No active recording to stop.');
    }
    _transitioning = true;
    status = RecorderStatus.processing;
    notifyListeners();
    try {
      _stopwatch.stop();
      elapsed = _stopwatch.elapsed;
      _timer?.cancel();
      await _amplitudeSubscription?.cancel();
      _amplitudeSubscription = null;
      final recordedPath = await _recorder.stop();
      await _safeStopBackground();
      final capturePath = recordedPath ?? _capturePath;
      final settings = _settings;
      final title = _title;
      if (capturePath == null || settings == null || title == null) {
        throw StateError('Recorder returned no valid output path.');
      }

      var finalPath = capturePath;
      if (_postTranscode) {
        finalPath = await _processor.transcode(
          inputPath: capturePath,
          outputTitle: title,
          format: settings.format,
          bitRate: settings.bitRate,
          sampleRate: settings.sampleRate,
          channels: settings.channels,
        );
        await _storage.deleteIfExists(capturePath);
      }
      if (!await File(finalPath).exists()) {
        throw StateError('Recorded file was not saved.');
      }

      final result = RecorderResult(
        path: finalPath,
        title: title,
        duration: elapsed,
        settings: settings,
        waveform: List<double>.from(_waveform),
        markers: List<RecordingMarker>.from(_markers),
      );
      await _safeDisableScreenWake();
      _resetState();
      return result;
    } catch (error) {
      lastError = error.toString();
      status = RecorderStatus.error;
      await _safeStopBackground();
      await _safeDisableScreenWake();
      notifyListeners();
      rethrow;
    } finally {
      _transitioning = false;
    }
  }

  Future<void> cancel() async {
    if (status == RecorderStatus.countdown) {
      _countdownGeneration++;
      countdownRemaining = 0;
      _resetState();
      return;
    }
    if (_transitioning || !isCapturing) {
      return;
    }
    _transitioning = true;
    try {
      _timer?.cancel();
      _stopwatch.stop();
      await _amplitudeSubscription?.cancel();
      _amplitudeSubscription = null;
      await _recorder.cancel();
      await _safeStopBackground();
      await _safeDisableScreenWake();
      await _deleteCaptureFiles();
      _resetState();
    } finally {
      _transitioning = false;
    }
  }

  void acknowledgeError() {
    if (status == RecorderStatus.error) {
      _resetState();
    }
  }

  Future<void> _safeStopBackground() async {
    try {
      await _background.stop();
    } catch (_) {
      // Core recording cleanup must not be blocked by a foreground-service error.
    }
  }

  Future<void> _safeDisableScreenWake() async {
    if (!_screenWakeEnabled) {
      return;
    }
    try {
      await WakelockPlus.disable();
    } finally {
      _screenWakeEnabled = false;
    }
  }

  Future<void> _cleanupFailedCapture() async {
    try {
      await _recorder.cancel();
    } catch (_) {
      // The recorder may not have entered a capturable state yet.
    }
    await _deleteCaptureFiles();
  }

  Future<void> _deleteCaptureFiles() async {
    final capturePath = _capturePath;
    final targetPath = _targetPath;
    if (capturePath != null) {
      await _storage.deleteIfExists(capturePath);
    }
    if (targetPath != null && targetPath != capturePath) {
      await _storage.deleteIfExists(targetPath);
    }
  }

  void _resetState() {
    _timer?.cancel();
    _stopwatch
      ..stop()
      ..reset();
    _capturePath = null;
    _targetPath = null;
    _title = null;
    _settings = null;
    _postTranscode = false;
    countdownRemaining = 0;
    elapsed = Duration.zero;
    amplitude = 0;
    peakAmplitude = 0;
    clipping = false;
    status = RecorderStatus.idle;
    notifyListeners();
  }

  @override
  void dispose() {
    _countdownGeneration++;
    _timer?.cancel();
    unawaited(_amplitudeSubscription?.cancel());
    if (_screenWakeEnabled) {
      unawaited(WakelockPlus.disable());
    }
    _recorder.dispose();
    super.dispose();
  }
}
