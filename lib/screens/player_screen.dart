import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../core/formatters.dart';
import '../models/recording_entry.dart';
import '../widgets/waveform_view.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key, required this.controller, required this.entry});

  final AppController controller;
  final RecordingEntry entry;

  @override
  Widget build(BuildContext context) {
    final player = controller.player;
    final duration = player.duration > Duration.zero ? player.duration : entry.duration;
    final position = player.position > duration ? duration : player.position;
    final maxMs = duration.inMilliseconds <= 0 ? 1.0 : duration.inMilliseconds.toDouble();
    final valueMs = position.inMilliseconds.clamp(0, maxMs.toInt()).toDouble();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
        actions: [
          IconButton(
            tooltip: entry.favorite ? 'Remove from favorites' : 'Add to favorites',
            onPressed: () => controller.toggleFavorite(entry),
            icon: Icon(entry.favorite ? Icons.favorite : Icons.favorite_border),
          ),
          IconButton(
            tooltip: 'Share',
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
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  '${entry.format.label} • ${formatBytes(entry.sizeBytes)}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                WaveformView(
                  samples: entry.waveform,
                  height: 112,
                  progress: maxMs <= 1 ? 0 : valueMs / maxMs,
                ),
                Slider(
                  value: valueMs,
                  min: 0,
                  max: maxMs,
                  onChanged: (value) => player.seek(Duration(milliseconds: value.round())),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(formatDuration(position)),
                    Text(formatDuration(duration)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filledTonal(
                      tooltip: 'Jump back ${controller.settings.skipIntervalSeconds} seconds',
                      onPressed: () => player.jump(Duration(seconds: -controller.settings.skipIntervalSeconds)),
                      icon: const Icon(Icons.replay_10),
                    ),
                    const SizedBox(width: 18),
                    FilledButton.tonalIcon(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(108, 62),
                        shape: const StadiumBorder(),
                      ),
                      onPressed: player.isLoading
                          ? null
                          : () => player.isPlaying ? player.pause() : player.play(),
                      icon: Icon(player.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 34),
                      label: Text(player.isPlaying ? 'Pause' : 'Play'),
                    ),
                    const SizedBox(width: 18),
                    IconButton.filledTonal(
                      tooltip: 'Jump forward ${controller.settings.skipIntervalSeconds} seconds',
                      onPressed: () => player.jump(Duration(seconds: controller.settings.skipIntervalSeconds)),
                      icon: const Icon(Icons.forward_10),
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
                      label: const Text('Repeat'),
                      selected: player.looping,
                      onSelected: player.setLooping,
                      avatar: const Icon(Icons.repeat, size: 18),
                    ),
                    FilterChip(
                      label: const Text('Skip silence'),
                      selected: player.skipSilence,
                      onSelected: (value) async {
                        try {
                          await player.setSkipSilence(value);
                        } on UnsupportedError catch (error) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message ?? error.toString())));
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
                  Text('Bookmarks', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  ...entry.markers.map(
                    (marker) => ListTile(
                      leading: const Icon(Icons.bookmark_outline),
                      title: Text(marker.label),
                      subtitle: marker.note.isEmpty ? null : Text(marker.note),
                      trailing: Text(formatDuration(Duration(milliseconds: marker.positionMs))),
                      onTap: () => player.seek(Duration(milliseconds: marker.positionMs)),
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
}

class _Artwork extends StatelessWidget {
  const _Artwork({required this.entry, required this.isPlaying});
  final RecordingEntry entry;
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
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
          semanticLabel: isPlaying ? 'Audio playing' : 'Audio recording',
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
        label: Text('${controller.player.speed.toStringAsFixed(controller.player.speed % 1 == 0 ? 0 : 2)}×'),
        onPressed: menuController.isOpen ? menuController.close : menuController.open,
      ),
      menuChildren: speeds
          .map(
            (speed) => MenuItemButton(
              onPressed: () => controller.player.setSpeed(speed),
              leadingIcon: controller.player.speed == speed ? const Icon(Icons.check) : const SizedBox(width: 24),
              child: Text('${speed}×'),
            ),
          )
          .toList(),
    );
  }
}
