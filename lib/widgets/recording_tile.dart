import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../l10n/app_localizations.dart';
import '../models/recording_entry.dart';
import '../models/recording_settings.dart';
import 'waveform_view.dart';

class RecordingTile extends StatelessWidget {
  const RecordingTile({
    super.key,
    required this.entry,
    required this.onTap,
    required this.onFavorite,
    required this.onMore,
    this.onLongPress,
    this.onSecondaryTapDown,
    this.selected = false,
  });

  final RecordingEntry entry;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final VoidCallback onMore;
  final VoidCallback? onLongPress;
  final GestureTapDownCallback? onSecondaryTapDown;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: selected ? scheme.secondaryContainer.withValues(alpha: 0.55) : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        onLongPress: onLongPress,
        onSecondaryTapDown: onSecondaryTapDown ?? (details) => onMore(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (selected)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.check_circle,
                        size: 20,
                        color: scheme.primary,
                      ),
                    )
                  else if (entry.pinned)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.push_pin,
                        size: 18,
                        color: scheme.primary,
                      ),
                    ),
                  Expanded(
                    child: Text(
                      entry.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  if (!selected) ...[
                    IconButton(
                      tooltip: entry.favorite
                          ? l10n.removeFromFavorites
                          : l10n.addToFavorites,
                      onPressed: onFavorite,
                      icon: Icon(
                        entry.favorite ? Icons.favorite : Icons.favorite_border,
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.bulkActions,
                      onPressed: onMore,
                      icon: const Icon(Icons.more_vert),
                    ),
                  ],
                ],
              ),
              if (entry.waveform.isNotEmpty) ...[
                const SizedBox(height: 6),
                WaveformView(
                  samples: entry.waveform,
                  height: 44,
                  compact: true,
                ),
              ],
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(formatDuration(entry.duration)),
                  Text(formatBytes(entry.sizeBytes)),
                  Text(_formatLabel(entry.format)),
                  if (entry.folder.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.folder_outlined, size: 16),
                        const SizedBox(width: 4),
                        Text(entry.folder),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                formatDateTime(entry.createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
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
