import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../core/formatters.dart';
import '../l10n/app_localizations.dart';
import '../widgets/recording_tile.dart';
import 'batch_convert_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final active = controller.recordings.where((e) => !e.isTrashed).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final recent = active.take(4).toList();
    final totalBytes = active.fold<int>(0, (sum, e) => sum + e.sizeBytes);
    final totalDuration = active.fold<Duration>(
      Duration.zero,
      (sum, e) => sum + e.duration,
    );

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          l10n.welcomeToSonicNest,
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.homeDescription,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth > 760;
            final cards = [
              _SummaryCard(
                icon: Icons.library_music,
                title: '${active.length}',
                subtitle: l10n.recordings,
              ),
              _SummaryCard(
                icon: Icons.schedule,
                title: formatDuration(totalDuration),
                subtitle: l10n.recordedAudio,
              ),
              _SummaryCard(
                icon: Icons.storage,
                title: formatBytes(totalBytes),
                subtitle: l10n.localStorage,
              ),
            ];
            return wide
                ? Row(
                    children: cards
                        .map(
                          (card) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: card,
                            ),
                          ),
                        )
                        .toList(),
                  )
                : Column(
                    children: cards
                        .map(
                          (card) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: card,
                          ),
                        )
                        .toList(),
                  );
          },
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 14,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mic, size: 30),
                ),
                SizedBox(
                  width: 330,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.quickRecord,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(l10n.quickRecordHint),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => controller.setNavigationIndex(1),
                  icon: const Icon(Icons.fiber_manual_record),
                  label: Text(l10n.record),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.multiple_stop_outlined, size: 34),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.batchConvert,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(l10n.batchConvertHomeHint),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.tonalIcon(
                  onPressed: active.isEmpty
                      ? null
                      : () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BatchConvertScreen(
                                controller: controller,
                              ),
                            ),
                          ),
                  icon: const Icon(Icons.transform_outlined),
                  label: Text(l10n.open),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 26),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.recentRecordings,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            TextButton(
              onPressed: () => controller.setNavigationIndex(2),
              child: Text(l10n.viewAll),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (recent.isEmpty)
          const _EmptyHome()
        else
          ...recent.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RecordingTile(
                entry: entry,
                onTap: () async {
                  await controller.openRecording(entry);
                  if (context.mounted) {
                    await showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => _MiniPlayer(controller: controller),
                    );
                  }
                },
                onFavorite: () => controller.toggleFavorite(entry),
                onMore: () => controller.setNavigationIndex(2),
              ),
            ),
          ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(icon, size: 30),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  Text(subtitle),
                ],
              ),
            ],
          ),
        ),
      );
}

class _EmptyHome extends StatelessWidget {
  const _EmptyHome();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Icon(
              Icons.graphic_eq,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(l10n.recordingsWillAppearHere),
            const SizedBox(height: 4),
            Text(l10n.useQuickRecordOrImport),
          ],
        ),
      ),
    );
  }
}

class _MiniPlayer extends StatelessWidget {
  const _MiniPlayer({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entry = controller.selectedRecording;
    if (entry == null) {
      return const SizedBox.shrink();
    }
    final durationMs = controller.player.duration.inMilliseconds;
    final progress = durationMs <= 0
        ? 0.0
        : controller.player.position.inMilliseconds / durationMs;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              entry.title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            Slider(
              value: progress.clamp(0.0, 1.0).toDouble(),
              onChanged: (value) => controller.player.seek(
                Duration(milliseconds: (durationMs * value).round()),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () =>
                      controller.player.jump(const Duration(seconds: -10)),
                  icon: const Icon(Icons.replay_10),
                ),
                FilledButton.tonalIcon(
                  onPressed: controller.player.isPlaying
                      ? controller.player.pause
                      : controller.player.play,
                  icon: Icon(
                    controller.player.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                  ),
                  label: Text(
                    controller.player.isPlaying ? l10n.pause : l10n.play,
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      controller.player.jump(const Duration(seconds: 10)),
                  icon: const Icon(Icons.forward_10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
