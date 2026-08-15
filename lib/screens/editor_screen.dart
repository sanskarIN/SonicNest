import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../core/formatters.dart';
import '../l10n/app_localizations.dart';
import '../models/recording_entry.dart';
import '../models/recording_settings.dart';
import '../services/advanced_audio_processor.dart';
import '../widgets/waveform_view.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({
    super.key,
    required this.controller,
    required this.entry,
  });

  final AppController controller;
  final RecordingEntry entry;

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late RangeValues _trimRange;
  late RecordingFormat _exportFormat;
  late final AdvancedAudioProcessor _advanced;
  final List<RangeValues> _undoRanges = <RangeValues>[];
  final List<RangeValues> _redoRanges = <RangeValues>[];
  RangeValues? _interactionStart;
  bool _processing = false;
  String? _status;
  double _gainDb = 0;
  Duration _silenceDuration = const Duration(seconds: 1);

  AppController get controller => widget.controller;
  RecordingEntry get entry => widget.entry;

  @override
  void initState() {
    super.initState();
    final maxMs = math.max(1, entry.durationMs).toDouble();
    _trimRange = RangeValues(0, maxMs);
    _exportFormat = entry.format;
    _advanced = AdvancedAudioProcessor(controller.storage);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final maxMs = math.max(1, entry.durationMs).toDouble();
    final start = Duration(milliseconds: _trimRange.start.round());
    final end = Duration(milliseconds: _trimRange.end.round());
    final selectionDuration = end - start;
    final normalizedSelection = RangeValues(
      (_trimRange.start / maxMs).clamp(0.0, 1.0).toDouble(),
      (_trimRange.end / maxMs).clamp(0.0, 1.0).toDouble(),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.audioEditor),
        actions: [
          IconButton(
            tooltip: l10n.undoSelectionChange,
            onPressed: _processing || _undoRanges.isEmpty
                ? null
                : _undoSelection,
            icon: const Icon(Icons.undo),
          ),
          IconButton(
            tooltip: l10n.redoSelectionChange,
            onPressed: _processing || _redoRanges.isEmpty
                ? null
                : _redoSelection,
            icon: const Icon(Icons.redo),
          ),
          IconButton(
            tooltip: l10n.resetSelection,
            onPressed: _processing ? null : _resetSelection,
            icon: const Icon(Icons.restart_alt),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  entry.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(l10n.editorNonDestructiveHint),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.selectionEditor,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(l10n.selectionEditorHint),
                        const SizedBox(height: 16),
                        WaveformView(
                          samples: entry.waveform,
                          height: 120,
                          selection: normalizedSelection,
                          onSelectionChangeStart: _beginRangeEdit,
                          onSelectionChanged: (values) {
                            setState(() {
                              _trimRange = RangeValues(
                                values.start * maxMs,
                                values.end * maxMs,
                              );
                            });
                          },
                          onSelectionChangeEnd: (_) => _finishRangeEdit(),
                        ),
                        RangeSlider(
                          values: _trimRange,
                          min: 0,
                          max: maxMs,
                          divisions: math
                              .min(1000, math.max(1, entry.durationMs ~/ 100))
                              .toInt(),
                          labels: RangeLabels(
                            formatDuration(start),
                            formatDuration(end),
                          ),
                          onChangeStart: _processing
                              ? null
                              : (_) => _beginRangeEdit(),
                          onChanged: _processing
                              ? null
                              : (value) => setState(() => _trimRange = value),
                          onChangeEnd: _processing
                              ? null
                              : (_) => _finishRangeEdit(),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.selectionStart(formatDuration(start)),
                              ),
                            ),
                            Text(
                              l10n.selectionEnd(
                                formatDuration(end),
                                formatDuration(selectionDuration),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            FilledButton.icon(
                              onPressed:
                                  _processing ||
                                      selectionDuration <
                                          const Duration(milliseconds: 200)
                                  ? null
                                  : () => _runTrim(start, end),
                              icon: const Icon(Icons.crop),
                              label: Text(l10n.keepSelectionAsCopy),
                            ),
                            FilledButton.tonalIcon(
                              onPressed:
                                  _processing ||
                                      selectionDuration <
                                          const Duration(milliseconds: 200) ||
                                      selectionDuration >= entry.duration
                                  ? null
                                  : () => _cutSelection(start, end),
                              icon: const Icon(Icons.content_cut),
                              label: Text(l10n.cutSelectionFromCopy),
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
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.quickProcessing,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            FilledButton.tonalIcon(
                              onPressed: _processing ? null : _normalize,
                              icon: const Icon(Icons.multiline_chart),
                              label: Text(l10n.normalize),
                            ),
                            FilledButton.tonalIcon(
                              onPressed: _processing ? null : _removeSilence,
                              icon: const Icon(Icons.content_cut_outlined),
                              label: Text(l10n.removeSilence),
                            ),
                            FilledButton.tonalIcon(
                              onPressed: _processing ? null : _fade,
                              icon: const Icon(Icons.gradient),
                              label: Text(l10n.fadeInOut),
                            ),
                            FilledButton.tonalIcon(
                              onPressed: _processing ? null : _split,
                              icon: const Icon(Icons.call_split),
                              label: Text(l10n.splitAtPlayhead),
                            ),
                            FilledButton.tonalIcon(
                              onPressed: _processing ? null : _merge,
                              icon: const Icon(Icons.merge_type),
                              label: Text(l10n.mergeAnotherFile),
                            ),
                            FilledButton.tonalIcon(
                              onPressed: _processing ? null : _noiseCleanup,
                              icon: const Icon(
                                Icons.cleaning_services_outlined,
                              ),
                              label: Text(l10n.basicNoiseCleanup),
                            ),
                            FilledButton.tonalIcon(
                              onPressed: _processing ? null : _compress,
                              icon: const Icon(Icons.compress),
                              label: Text(l10n.compressor),
                            ),
                            FilledButton.tonalIcon(
                              onPressed: _processing ? null : _limit,
                              icon: const Icon(Icons.vertical_align_center),
                              label: Text(l10n.limiter),
                            ),
                            FilledButton.tonalIcon(
                              onPressed: _processing ? null : _highPass,
                              icon: const Icon(Icons.trending_up),
                              label: Text(l10n.highPassVoiceFilter),
                            ),
                            FilledButton.tonalIcon(
                              onPressed: _processing ? null : _lowPass,
                              icon: const Icon(Icons.trending_down),
                              label: Text(l10n.lowPassFilter),
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
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.gainAndSilence,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 10),
                        Text(l10n.outputGain(_gainDb.toStringAsFixed(1))),
                        Slider(
                          value: _gainDb,
                          min: -18,
                          max: 12,
                          divisions: 60,
                          label: '${_gainDb.toStringAsFixed(1)} dB',
                          onChanged: _processing
                              ? null
                              : (value) => setState(() => _gainDb = value),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: _processing || _gainDb.abs() < .05
                              ? null
                              : _applyGain,
                          icon: const Icon(Icons.volume_up_outlined),
                          label: Text(l10n.exportGainAdjustedCopy),
                        ),
                        const Divider(height: 32),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<Duration>(
                                initialValue: _silenceDuration,
                                decoration: InputDecoration(
                                  labelText: l10n.silenceDuration,
                                ),
                                items:
                                    const [
                                          Duration(milliseconds: 250),
                                          Duration(milliseconds: 500),
                                          Duration(seconds: 1),
                                          Duration(seconds: 2),
                                          Duration(seconds: 5),
                                        ]
                                        .map(
                                          (duration) => DropdownMenuItem(
                                            value: duration,
                                            child: Text(
                                              duration.inMilliseconds < 1000
                                                  ? '${duration.inMilliseconds} ms'
                                                  : '${duration.inMilliseconds / 1000} s',
                                            ),
                                          ),
                                        )
                                        .toList(),
                                onChanged: _processing
                                    ? null
                                    : (value) {
                                        if (value != null) {
                                          setState(
                                            () => _silenceDuration = value,
                                          );
                                        }
                                      },
                              ),
                            ),
                            const SizedBox(width: 12),
                            FilledButton.tonalIcon(
                              onPressed: _processing ? null : _insertSilence,
                              icon: const Icon(Icons.space_bar),
                              label: Text(l10n.insertAtPlayhead),
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
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.exportPreset,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(l10n.exportPresetHint),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            DropdownMenu<RecordingFormat>(
                              initialSelection: _exportFormat,
                              label: Text(l10n.format),
                              onSelected: _processing
                                  ? null
                                  : (value) {
                                      if (value != null) {
                                        setState(() => _exportFormat = value);
                                      }
                                    },
                              dropdownMenuEntries: RecordingFormat.values
                                  .map(
                                    (format) => DropdownMenuEntry(
                                      value: format,
                                      label: format.label,
                                    ),
                                  )
                                  .toList(),
                            ),
                            FilledButton.tonalIcon(
                              onPressed: _processing ? null : _exportPreset,
                              icon: const Icon(Icons.audio_file_outlined),
                              label: Text(
                                l10n.exportFormatCopy(_exportFormat.label),
                              ),
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
                      tooltip: controller.player.isPlaying
                          ? l10n.pausePreview
                          : l10n.playPreview,
                      onPressed: () => controller.player.isPlaying
                          ? controller.player.pause()
                          : controller.player.play(),
                      icon: Icon(
                        controller.player.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                      ),
                    ),
                    title: Text(l10n.previewOriginal),
                    subtitle: Text(
                      '${formatDuration(controller.player.position)} / '
                      '${formatDuration(controller.player.duration)}',
                    ),
                    trailing: SizedBox(
                      width: 140,
                      child: Slider(
                        value: controller.player.duration.inMilliseconds <= 0
                            ? 0
                            : controller.player.position.inMilliseconds
                                  .clamp(
                                    0,
                                    controller.player.duration.inMilliseconds,
                                  )
                                  .toDouble(),
                        max: math
                            .max(1, controller.player.duration.inMilliseconds)
                            .toDouble(),
                        onChanged: (value) => controller.player.seek(
                          Duration(milliseconds: value.round()),
                        ),
                      ),
                    ),
                  ),
                ),
                if (_processing || _status != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: ListTile(
                      leading: _processing
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 3),
                            )
                          : const Icon(Icons.check_circle_outline),
                      title: Text(
                        _processing ? l10n.processingAudio : l10n.editorStatus,
                      ),
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

  void _beginRangeEdit() {
    _interactionStart ??= _trimRange;
  }

  void _finishRangeEdit() {
    final before = _interactionStart;
    _interactionStart = null;
    if (before == null || _sameRange(before, _trimRange)) {
      return;
    }
    setState(() {
      _undoRanges.add(before);
      if (_undoRanges.length > 50) {
        _undoRanges.removeAt(0);
      }
      _redoRanges.clear();
    });
  }

  bool _sameRange(RangeValues a, RangeValues b) =>
      (a.start - b.start).abs() < .5 && (a.end - b.end).abs() < .5;

  void _undoSelection() {
    if (_undoRanges.isEmpty) {
      return;
    }
    setState(() {
      _redoRanges.add(_trimRange);
      _trimRange = _undoRanges.removeLast();
    });
  }

  void _redoSelection() {
    if (_redoRanges.isEmpty) {
      return;
    }
    setState(() {
      _undoRanges.add(_trimRange);
      _trimRange = _redoRanges.removeLast();
    });
  }

  void _resetSelection() {
    final full = RangeValues(0, math.max(1, entry.durationMs).toDouble());
    if (_sameRange(full, _trimRange)) {
      return;
    }
    setState(() {
      _undoRanges.add(_trimRange);
      _redoRanges.clear();
      _trimRange = full;
    });
  }

  Future<void> _runTrim(Duration start, Duration end) async {
    final l10n = AppLocalizations.of(context);
    await _run(l10n.selectionCopyCreated, () async {
      final title = l10n.selectionCopyTitle(entry.title);
      final output = await controller.processor.trim(
        inputPath: entry.filePath,
        outputTitle: title,
        format: entry.format,
        start: start,
        end: end,
        bitRate: _bitRate,
      );
      await controller.addProcessedFile(
        output,
        title: title,
        format: entry.format,
        markers: _markersInside(start, end),
      );
    });
  }

  Future<void> _cutSelection(Duration start, Duration end) async {
    final l10n = AppLocalizations.of(context);
    await _run(l10n.cutCopyCreated, () async {
      final title = l10n.cutCopyTitle(entry.title);
      final output = await _advanced.cutSelection(
        inputPath: entry.filePath,
        outputTitle: title,
        format: entry.format,
        start: start,
        end: end,
        bitRate: _bitRate,
      );
      await controller.addProcessedFile(
        output,
        title: title,
        format: entry.format,
        markers: _markersAfterCut(start, end),
      );
    });
  }

  Future<void> _normalize() async {
    final l10n = AppLocalizations.of(context);
    final title = l10n.normalizedCopyTitle(entry.title);
    await _run(l10n.normalizedCopyCreated, () async {
      final output = await controller.processor.normalize(
        inputPath: entry.filePath,
        outputTitle: title,
        format: entry.format,
        bitRate: _bitRate,
      );
      await controller.addProcessedFile(
        output,
        title: title,
        format: entry.format,
        markers: entry.markers,
      );
    });
  }

  Future<void> _removeSilence() async {
    final l10n = AppLocalizations.of(context);
    final title = l10n.silenceCleanedCopyTitle(entry.title);
    await _run(l10n.silenceCleanedCopyCreated, () async {
      final output = await controller.processor.removeSilence(
        inputPath: entry.filePath,
        outputTitle: title,
        format: entry.format,
        bitRate: _bitRate,
      );
      await controller.addProcessedFile(
        output,
        title: title,
        format: entry.format,
      );
    });
  }

  Future<void> _fade() async {
    final l10n = AppLocalizations.of(context);
    final duration = entry.duration;
    final outStart = duration > const Duration(seconds: 2)
        ? duration - const Duration(seconds: 1)
        : duration * .5;
    final title = l10n.fadedCopyTitle(entry.title);
    await _run(l10n.fadedCopyCreated, () async {
      final output = await controller.processor.fade(
        inputPath: entry.filePath,
        outputTitle: title,
        format: entry.format,
        bitRate: _bitRate,
        fadeOutStart: outStart,
      );
      await controller.addProcessedFile(
        output,
        title: title,
        format: entry.format,
        markers: entry.markers,
      );
    });
  }

  Future<void> _split() async {
    final l10n = AppLocalizations.of(context);
    var at = controller.player.position;
    if (at <= Duration.zero || at >= entry.duration) {
      at = Duration(milliseconds: entry.durationMs ~/ 2);
    }
    if (at <= Duration.zero) {
      setState(() => _status = l10n.recordingTooShortToSplit);
      return;
    }
    await _run(l10n.splitCopiesCreated, () async {
      final outputs = await controller.processor.split(
        inputPath: entry.filePath,
        outputTitle: entry.title,
        format: entry.format,
        at: at,
        bitRate: _bitRate,
      );
      await controller.addProcessedFile(
        outputs[0],
        title: l10n.partTitle(entry.title, 1),
        format: entry.format,
      );
      await controller.addProcessedFile(
        outputs[1],
        title: l10n.partTitle(entry.title, 2),
        format: entry.format,
      );
    });
  }

  Future<void> _merge() async {
    final l10n = AppLocalizations.of(context);
    final other = await controller.external.pickSingleAudioFile();
    if (other == null) {
      return;
    }
    final title = l10n.mergedCopyTitle(entry.title);
    await _run(l10n.mergedCopyCreated, () async {
      final output = await controller.processor.merge(
        inputPaths: [entry.filePath, other],
        outputTitle: title,
        format: entry.format,
        bitRate: _bitRate,
      );
      await controller.addProcessedFile(
        output,
        title: title,
        format: entry.format,
      );
    });
  }

  Future<void> _applyGain() async {
    final l10n = AppLocalizations.of(context);
    final gain = _gainDb;
    await _run(l10n.gainAdjustedCopyCreated, () async {
      final title =
          '${entry.title} ${gain >= 0 ? '+' : ''}${gain.toStringAsFixed(1)}dB';
      final output = await _advanced.adjustVolume(
        inputPath: entry.filePath,
        outputTitle: title,
        format: entry.format,
        bitRate: _bitRate,
        gainDb: gain,
      );
      await controller.addProcessedFile(
        output,
        title: title,
        format: entry.format,
        markers: entry.markers,
      );
    });
  }

  Future<void> _insertSilence() async {
    final l10n = AppLocalizations.of(context);
    final raw = controller.player.position;
    final at = raw < Duration.zero
        ? Duration.zero
        : (raw > entry.duration ? entry.duration : raw);
    final silence = _silenceDuration;
    await _run(l10n.silenceInsertedCopyCreated, () async {
      final title = l10n.silenceInsertedCopyTitle(entry.title);
      final output = await _advanced.insertSilence(
        inputPath: entry.filePath,
        outputTitle: title,
        format: entry.format,
        at: at,
        silenceDuration: silence,
        bitRate: _bitRate,
        sampleRate: entry.sampleRate > 0
            ? entry.sampleRate
            : controller.settings.recording.sampleRate,
        channels: entry.channels > 0
            ? entry.channels
            : controller.settings.recording.channels,
      );
      await controller.addProcessedFile(
        output,
        title: title,
        format: entry.format,
        markers: _markersAfterInsertion(at, silence),
      );
    });
  }

  Future<void> _noiseCleanup() {
    final l10n = AppLocalizations.of(context);
    return _advancedCopy(
      success: l10n.noiseCleanedCopyCreated,
      title: l10n.noiseCleanedCopyTitle(entry.title),
      action: (title) => _advanced.noiseCleanup(
        inputPath: entry.filePath,
        outputTitle: title,
        format: entry.format,
        bitRate: _bitRate,
      ),
    );
  }

  Future<void> _compress() {
    final l10n = AppLocalizations.of(context);
    return _advancedCopy(
      success: l10n.compressedDynamicsCopyCreated,
      title: l10n.compressedCopyTitle(entry.title),
      action: (title) => _advanced.compressor(
        inputPath: entry.filePath,
        outputTitle: title,
        format: entry.format,
        bitRate: _bitRate,
      ),
    );
  }

  Future<void> _limit() {
    final l10n = AppLocalizations.of(context);
    return _advancedCopy(
      success: l10n.limitedCopyCreated,
      title: l10n.limitedCopyTitle(entry.title),
      action: (title) => _advanced.limiter(
        inputPath: entry.filePath,
        outputTitle: title,
        format: entry.format,
        bitRate: _bitRate,
      ),
    );
  }

  Future<void> _highPass() {
    final l10n = AppLocalizations.of(context);
    return _advancedCopy(
      success: l10n.highPassFilteredCopyCreated,
      title: l10n.highPassCopyTitle(entry.title),
      action: (title) => _advanced.highPass(
        inputPath: entry.filePath,
        outputTitle: title,
        format: entry.format,
        bitRate: _bitRate,
        frequencyHz: 100,
      ),
    );
  }

  Future<void> _lowPass() {
    final l10n = AppLocalizations.of(context);
    return _advancedCopy(
      success: l10n.lowPassFilteredCopyCreated,
      title: l10n.lowPassCopyTitle(entry.title),
      action: (title) => _advanced.lowPass(
        inputPath: entry.filePath,
        outputTitle: title,
        format: entry.format,
        bitRate: _bitRate,
        frequencyHz: 12000,
      ),
    );
  }

  Future<void> _advancedCopy({
    required String success,
    required String title,
    required Future<String> Function(String title) action,
  }) async {
    await _run(success, () async {
      final output = await action(title);
      await controller.addProcessedFile(
        output,
        title: title,
        format: entry.format,
        markers: entry.markers,
      );
    });
  }

  Future<void> _exportPreset() async {
    final l10n = AppLocalizations.of(context);
    final format = _exportFormat;
    await _run(l10n.formatCopyCreated(format.label), () async {
      final title = '${entry.title} ${format.label}';
      final output = await controller.processor.transcode(
        inputPath: entry.filePath,
        outputTitle: title,
        format: format,
        bitRate: _bitRate,
        sampleRate: entry.sampleRate > 0
            ? entry.sampleRate
            : controller.settings.recording.sampleRate,
        channels: entry.channels > 0
            ? entry.channels
            : controller.settings.recording.channels,
      );
      await controller.addProcessedFile(
        output,
        title: title,
        format: format,
        markers: entry.markers,
      );
    });
  }

  int get _bitRate =>
      entry.bitRate > 0 ? entry.bitRate : controller.settings.recording.bitRate;

  List<RecordingMarker> _markersInside(Duration start, Duration end) {
    return entry.markers
        .where(
          (marker) =>
              marker.positionMs >= start.inMilliseconds &&
              marker.positionMs <= end.inMilliseconds,
        )
        .map(
          (marker) => RecordingMarker(
            positionMs: marker.positionMs - start.inMilliseconds,
            label: marker.label,
            note: marker.note,
          ),
        )
        .toList();
  }

  List<RecordingMarker> _markersAfterCut(Duration start, Duration end) {
    final removedMs = (end - start).inMilliseconds;
    return entry.markers
        .where(
          (marker) =>
              marker.positionMs < start.inMilliseconds ||
              marker.positionMs > end.inMilliseconds,
        )
        .map(
          (marker) => RecordingMarker(
            positionMs: marker.positionMs > end.inMilliseconds
                ? marker.positionMs - removedMs
                : marker.positionMs,
            label: marker.label,
            note: marker.note,
          ),
        )
        .toList();
  }

  List<RecordingMarker> _markersAfterInsertion(Duration at, Duration inserted) {
    return entry.markers
        .map(
          (marker) => RecordingMarker(
            positionMs: marker.positionMs >= at.inMilliseconds
                ? marker.positionMs + inserted.inMilliseconds
                : marker.positionMs,
            label: marker.label,
            note: marker.note,
          ),
        )
        .toList();
  }

  Future<void> _run(String success, Future<void> Function() action) async {
    if (_processing) {
      return;
    }
    setState(() {
      _processing = true;
      _status = null;
    });
    try {
      await action();
      if (!mounted) {
        return;
      }
      setState(() => _status = success);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(success)));
    } catch (error) {
      if (!mounted) {
        return;
      }
      final message = AppLocalizations.of(context).processingFailed(error);
      setState(() => _status = message);
    } finally {
      if (mounted) {
        setState(() => _processing = false);
      }
    }
  }
}
