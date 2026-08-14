import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../core/formatters.dart';
import '../models/recording_entry.dart';
import '../widgets/waveform_view.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key, required this.controller, required this.entry});

  final AppController controller;
  final RecordingEntry entry;

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late RangeValues _trimRange;
  bool _processing = false;
  String? _status;

  AppController get controller => widget.controller;
  RecordingEntry get entry => widget.entry;

  @override
  void initState() {
    super.initState();
    final maxMs = math.max(1, entry.durationMs).toDouble();
    _trimRange = RangeValues(0, maxMs);
  }

  @override
  Widget build(BuildContext context) {
    final maxMs = math.max(1, entry.durationMs).toDouble();
    final start = Duration(milliseconds: _trimRange.start.round());
    final end = Duration(milliseconds: _trimRange.end.round());
    return Scaffold(
      appBar: AppBar(title: const Text('Audio Editor')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(entry.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                const Text('Edits are exported as new files. Your original recording is never overwritten.'),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Trim', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 16),
                        WaveformView(samples: entry.waveform, height: 108),
                        RangeSlider(
                          values: _trimRange,
                          min: 0,
                          max: maxMs,
                          divisions: math.min(1000, math.max(1, entry.durationMs ~/ 100)).toInt(),
                          labels: RangeLabels(formatDuration(start), formatDuration(end)),
                          onChanged: _processing ? null : (value) => setState(() => _trimRange = value),
                        ),
                        Row(
                          children: [
                            Expanded(child: Text('Start ${formatDuration(start)}')),
                            Text('End ${formatDuration(end)}'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _processing || end - start < const Duration(milliseconds: 200)
                              ? null
                              : () => _runTrim(start, end),
                          icon: const Icon(Icons.content_cut),
                          label: const Text('Export trimmed copy'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Quick processing', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            FilledButton.tonalIcon(
                              onPressed: _processing ? null : _normalize,
                              icon: const Icon(Icons.multiline_chart),
                              label: const Text('Normalize'),
                            ),
                            FilledButton.tonalIcon(
                              onPressed: _processing ? null : _removeSilence,
                              icon: const Icon(Icons.content_cut_outlined),
                              label: const Text('Remove silence'),
                            ),
                            FilledButton.tonalIcon(
                              onPressed: _processing ? null : _fade,
                              icon: const Icon(Icons.gradient),
                              label: const Text('Fade in/out'),
                            ),
                            FilledButton.tonalIcon(
                              onPressed: _processing ? null : _split,
                              icon: const Icon(Icons.call_split),
                              label: const Text('Split at playhead'),
                            ),
                            FilledButton.tonalIcon(
                              onPressed: _processing ? null : _merge,
                              icon: const Icon(Icons.merge_type),
                              label: const Text('Merge another file'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: IconButton.filledTonal(
                      tooltip: controller.player.isPlaying ? 'Pause preview' : 'Play preview',
                      onPressed: () => controller.player.isPlaying ? controller.player.pause() : controller.player.play(),
                      icon: Icon(controller.player.isPlaying ? Icons.pause : Icons.play_arrow),
                    ),
                    title: const Text('Preview original'),
                    subtitle: Text('${formatDuration(controller.player.position)} / ${formatDuration(controller.player.duration)}'),
                    trailing: SizedBox(
                      width: 140,
                      child: Slider(
                        value: controller.player.duration.inMilliseconds <= 0
                            ? 0
                            : controller.player.position.inMilliseconds
                                .clamp(0, controller.player.duration.inMilliseconds)
                                .toDouble(),
                        max: math.max(1, controller.player.duration.inMilliseconds).toDouble(),
                        onChanged: (value) => controller.player.seek(Duration(milliseconds: value.round())),
                      ),
                    ),
                  ),
                ),
                if (_processing || _status != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: ListTile(
                      leading: _processing
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3))
                          : const Icon(Icons.check_circle_outline),
                      title: Text(_processing ? 'Processing audio' : 'Editor status'),
                      subtitle: _status == null ? null : Text(_status!),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _runTrim(Duration start, Duration end) async {
    await _run('Trimmed copy created.', () async {
      final output = await controller.processor.trim(
        inputPath: entry.filePath,
        outputTitle: '${entry.title} Trimmed',
        format: entry.format,
        start: start,
        end: end,
        bitRate: _bitRate,
      );
      await controller.addProcessedFile(output, title: '${entry.title} Trimmed', format: entry.format, markers: _markersInside(start, end));
    });
  }

  Future<void> _normalize() async {
    await _run('Normalized copy created.', () async {
      final output = await controller.processor.normalize(
        inputPath: entry.filePath,
        outputTitle: '${entry.title} Normalized',
        format: entry.format,
        bitRate: _bitRate,
      );
      await controller.addProcessedFile(output, title: '${entry.title} Normalized', format: entry.format, markers: entry.markers);
    });
  }

  Future<void> _removeSilence() async {
    await _run('Silence-cleaned copy created.', () async {
      final output = await controller.processor.removeSilence(
        inputPath: entry.filePath,
        outputTitle: '${entry.title} Silence Cleaned',
        format: entry.format,
        bitRate: _bitRate,
      );
      await controller.addProcessedFile(output, title: '${entry.title} Silence Cleaned', format: entry.format);
    });
  }

  Future<void> _fade() async {
    final duration = entry.duration;
    final outStart = duration > const Duration(seconds: 2) ? duration - const Duration(seconds: 1) : duration * .5;
    await _run('Faded copy created.', () async {
      final output = await controller.processor.fade(
        inputPath: entry.filePath,
        outputTitle: '${entry.title} Faded',
        format: entry.format,
        bitRate: _bitRate,
        fadeOutStart: outStart,
      );
      await controller.addProcessedFile(output, title: '${entry.title} Faded', format: entry.format, markers: entry.markers);
    });
  }

  Future<void> _split() async {
    var at = controller.player.position;
    if (at <= Duration.zero || at >= entry.duration) {
      at = Duration(milliseconds: entry.durationMs ~/ 2);
    }
    if (at <= Duration.zero) {
      setState(() => _status = 'This recording is too short to split.');
      return;
    }
    await _run('Split copies created.', () async {
      final outputs = await controller.processor.split(
        inputPath: entry.filePath,
        outputTitle: entry.title,
        format: entry.format,
        at: at,
        bitRate: _bitRate,
      );
      await controller.addProcessedFile(outputs[0], title: '${entry.title} Part 1', format: entry.format);
      await controller.addProcessedFile(outputs[1], title: '${entry.title} Part 2', format: entry.format);
    });
  }

  Future<void> _merge() async {
    final other = await controller.external.pickSingleAudioFile();
    if (other == null) return;
    await _run('Merged copy created.', () async {
      final output = await controller.processor.merge(
        inputPaths: [entry.filePath, other],
        outputTitle: '${entry.title} Merged',
        format: entry.format,
        bitRate: _bitRate,
      );
      await controller.addProcessedFile(output, title: '${entry.title} Merged', format: entry.format);
    });
  }

  int get _bitRate => entry.bitRate > 0 ? entry.bitRate : controller.settings.recording.bitRate;

  List<RecordingMarker> _markersInside(Duration start, Duration end) {
    return entry.markers
        .where((marker) => marker.positionMs >= start.inMilliseconds && marker.positionMs <= end.inMilliseconds)
        .map((marker) => RecordingMarker(positionMs: marker.positionMs - start.inMilliseconds, label: marker.label, note: marker.note))
        .toList();
  }

  Future<void> _run(String success, Future<void> Function() action) async {
    if (_processing) return;
    setState(() {
      _processing = true;
      _status = null;
    });
    try {
      await action();
      if (!mounted) return;
      setState(() => _status = success);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success)));
    } catch (error) {
      if (!mounted) return;
      setState(() => _status = 'Processing failed: $error');
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }
}
