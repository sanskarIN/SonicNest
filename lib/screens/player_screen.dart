import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../core/formatters.dart';
import '../l10n/app_localizations.dart';
import '../models/recording_entry.dart';
import '../models/recording_settings.dart';
import '../widgets/waveform_view.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({
    super.key,
    required this.controller,
    required this.entry,
  });

  final AppController controller;
  final RecordingEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final player = controller.player;
    final duration = player.duration > Duration.zero
        ? player.duration
        : entry.duration;
    final position = player.position > duration ? duration : player.position;
    final maxMs = duration.inMilliseconds <= 0
        ? 1.0
        : duration.inMilliseconds.toDouble();
    final valueMs = position.inMilliseconds.clamp(0, maxMs.toInt()).toDouble();
    final adjacent = _adjacentState();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.nowPlaying),
        actions: [
          IconButton(
            tooltip: entry.favorite
                ? l10n.removeFromFavorites
                : l10n.addToFavorites,
            onPressed: () => controller.toggleFavorite(entry),
            icon: Icon(entry.favorite ? Icons.favorite : Icons.favorite_border),
          ),
          IconButton(
            tooltip: l10n.share,
            onPressed: () => controller.shareRecording(entry),
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _Artwork(entry: entry, isPlaying: player.isPlaying),
                const SizedBox(height: 28),
                Text(
                  entry.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_formatLabel(entry.format)} • ${formatBytes(entry.sizeBytes)}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                WaveformView(
                  samples: entry.waveform,
                  height: 112,
                  progress: maxMs <= 1 ? 0 : valueMs / maxMs,
                  selection: player.hasSelectionLoop
                      ? RangeValues(
                          (player.selectionLoopStart!.inMilliseconds / maxMs)
                              .clamp(0.0, 1.0)
                              .toDouble(),
                          (player.selectionLoopEnd!.inMilliseconds / maxMs)
                              .clamp(0.0, 1.0)
                              .toDouble(),
                        )
                      : null,
                ),
                Slider(
                  value: valueMs,
                  min: 0,
                  max: maxMs,
                  onChanged: (value) =>
                      player.seek(Duration(milliseconds: value.round())),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(formatDuration(position)),
                    Text(formatDuration(duration)),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    IconButton.filledTonal(
                      tooltip: l10n.previousRecording,
                      onPressed: adjacent.hasPrevious
                          ? () => _openRelative(-1)
                          : null,
                      icon: const Icon(Icons.skip_previous_rounded),
                    ),
                    IconButton.filledTonal(
                      tooltip: l10n.jumpBackSeconds(
                        controller.settings.skipIntervalSeconds,
                      ),
                      onPressed: () => player.jump(
                        Duration(
                          seconds: -controller.settings.skipIntervalSeconds,
                        ),
                      ),
                      icon: const Icon(Icons.replay_10),
                    ),
                    FilledButton.tonalIcon(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(108, 62),
                        shape: const StadiumBorder(),
                      ),
                      onPressed: player.isLoading
                          ? null
                          : () => player.isPlaying
                                ? player.pause()
                                : player.play(),
                      icon: Icon(
                        player.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 34,
                      ),
                      label: Text(player.isPlaying ? l10n.pause : l10n.play),
                    ),
                    IconButton.filledTonal(
                      tooltip: l10n.jumpForwardSeconds(
                        controller.settings.skipIntervalSeconds,
                      ),
                      onPressed: () => player.jump(
                        Duration(
                          seconds: controller.settings.skipIntervalSeconds,
                        ),
                      ),
                      icon: const Icon(Icons.forward_10),
                    ),
                    IconButton.filledTonal(
                      tooltip: l10n.nextRecording,
                      onPressed: adjacent.hasNext
                          ? () => _openRelative(1)
                          : null,
                      icon: const Icon(Icons.skip_next_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    _SpeedMenu(controller: controller),
                    FilterChip(
                      label: Text(l10n.repeat),
                      selected: player.looping,
                      onSelected: player.setLooping,
                      avatar: const Icon(Icons.repeat, size: 18),
                    ),
                    ActionChip(
                      avatar: Icon(
                        player.hasSelectionLoop
                            ? Icons.repeat_on_rounded
                            : Icons.repeat_one_on_outlined,
                        size: 18,
                      ),
                      label: Text(
                        player.hasSelectionLoop
                            ? '${formatDuration(player.selectionLoopStart!)}–${formatDuration(player.selectionLoopEnd!)}'
                            : l10n.abLoop,
                      ),
                      onPressed: () =>
                          _configureSelectionLoop(context, duration),
                    ),
                    if (player.hasSelectionLoop)
                      ActionChip(
                        avatar: const Icon(Icons.close, size: 18),
                        label: Text(l10n.clearLoop),
                        onPressed: player.clearSelectionLoop,
                      ),
                    FilterChip(
                      label: Text(l10n.skipSilence),
                      selected: player.skipSilence,
                      onSelected: (value) async {
                        try {
                          await player.setSkipSilence(value);
                        } on UnsupportedError catch (error) {
                          if (!context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(error.message ?? error.toString()),
                            ),
                          );
                        }
                      },
                      avatar: const Icon(Icons.fast_forward_outlined, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                Row(
                  children: [
                    const Icon(Icons.volume_down),
                    Expanded(
                      child: Slider(
                        value: player.volume,
                        onChanged: player.setVolume,
                      ),
                    ),
                    const Icon(Icons.volume_up),
                  ],
                ),
                if (entry.markers.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    l10n.bookmarks,
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  ...entry.markers.map(
                    (marker) => ListTile(
                      leading: const Icon(Icons.bookmark_outline),
                      title: Text(marker.label),
                      subtitle: marker.note.isEmpty ? null : Text(marker.note),
                      trailing: Text(
                        formatDuration(
                          Duration(milliseconds: marker.positionMs),
                        ),
                      ),
                      onTap: () => player.seek(
                        Duration(milliseconds: marker.positionMs),
                      ),
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

  ({bool hasPrevious, bool hasNext, int index, List<RecordingEntry> entries})
  _adjacentState() {
    final entries =
        controller.recordings
            .where((candidate) => !candidate.isTrashed)
            .toList(growable: false)
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final index = entries.indexWhere((candidate) => candidate.id == entry.id);
    return (
      hasPrevious: index > 0,
      hasNext: index >= 0 && index < entries.length - 1,
      index: index,
      entries: entries,
    );
  }

  Future<void> _openRelative(int direction) async {
    final adjacent = _adjacentState();
    final targetIndex = adjacent.index + direction;
    if (adjacent.index < 0 ||
        targetIndex < 0 ||
        targetIndex >= adjacent.entries.length) {
      return;
    }
    await controller.openRecording(adjacent.entries[targetIndex]);
  }

  Future<void> _configureSelectionLoop(
    BuildContext context,
    Duration duration,
  ) async {
    if (duration <= const Duration(milliseconds: 400)) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    final maxMs = duration.inMilliseconds.toDouble();
    final player = controller.player;
    final current = player.position.inMilliseconds.clamp(
      0,
      duration.inMilliseconds,
    );
    final defaultStart = player.hasSelectionLoop
        ? player.selectionLoopStart!.inMilliseconds.toDouble()
        : math.max(0, current - 5000).toDouble();
    final defaultEnd = player.hasSelectionLoop
        ? player.selectionLoopEnd!.inMilliseconds.toDouble()
        : math.min(duration.inMilliseconds, current + 5000).toDouble();
    var values = RangeValues(
      defaultStart,
      math.max(defaultStart + 200, defaultEnd).clamp(0, maxMs).toDouble(),
    );

    final selection = await showDialog<RangeValues>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(l10n.abLoop),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${formatDuration(Duration(milliseconds: values.start.round()))} – '
                  '${formatDuration(Duration(milliseconds: values.end.round()))}',
                ),
                RangeSlider(
                  values: values,
                  min: 0,
                  max: maxMs,
                  divisions: math.min(
                    1000,
                    math.max(1, duration.inMilliseconds ~/ 100),
                  ),
                  onChanged: (next) {
                    if (next.end - next.start >= 200) {
                      setDialogState(() => values = next);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, values),
              child: Text(l10n.loopSelection),
            ),
          ],
        ),
      ),
    );
    if (selection == null) {
      return;
    }
    await player.setSelectionLoop(
      Duration(milliseconds: selection.start.round()),
      Duration(milliseconds: selection.end.round()),
    );
  }
}

String _formatLabel(RecordingFormat format) => switch (format) {
  RecordingFormat.m4a => 'M4A / AAC',
  RecordingFormat.wav => 'WAV',
  RecordingFormat.flac => 'FLAC',
  RecordingFormat.opus => 'Opus',
  RecordingFormat.mp3 => 'MP3',
  RecordingFormat.ogg => 'OGG / Vorbis',
  RecordingFormat.aac => 'AAC',
};

class _Artwork extends StatelessWidget {
  const _Artwork({required this.entry, required this.isPlaying});
  final RecordingEntry entry;
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Container(
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [scheme.primaryContainer, scheme.tertiaryContainer],
          ),
        ),
        child: Icon(
          isPlaying ? Icons.graphic_eq_rounded : Icons.multitrack_audio_rounded,
          size: 88,
          color: scheme.onPrimaryContainer,
          semanticLabel: isPlaying ? l10n.audioPlaying : l10n.audioRecording,
        ),
      ),
    );
  }
}

class _SpeedMenu extends StatelessWidget {
  const _SpeedMenu({required this.controller});
  final AppController controller;

  static const speeds = [.5, .75, 1.0, 1.25, 1.5, 1.75, 2.0];

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      builder: (context, menuController, child) => ActionChip(
        avatar: const Icon(Icons.speed, size: 18),
        label: Text(
          '${controller.player.speed.toStringAsFixed(controller.player.speed % 1 == 0 ? 0 : 2)}×',
        ),
        onPressed: menuController.isOpen
            ? menuController.close
            : menuController.open,
      ),
      menuChildren: speeds
          .map(
            (speed) => MenuItemButton(
              onPressed: () => controller.player.setSpeed(speed),
              leadingIcon: controller.player.speed == speed
                  ? const Icon(Icons.check)
                  : const SizedBox(width: 24),
              child: Text('$speed×'),
            ),
          )
          .toList(),
    );
  }
}
