import 'package:flutter_test/flutter_test.dart';
import 'package:sonic_nest/models/recording_entry.dart';
import 'package:sonic_nest/models/recording_settings.dart';

void main() {
  test('recording metadata JSON roundtrip retains organizer data', () {
    final now = DateTime.utc(2026, 8, 14, 1, 2, 3);
    final entry = RecordingEntry(
      id: 'abc',
      title: 'Lecture',
      filePath: '/audio/lecture.flac',
      durationMs: 123456,
      sizeBytes: 999,
      format: RecordingFormat.flac,
      bitRate: 320000,
      sampleRate: 48000,
      channels: 2,
      createdAt: now,
      modifiedAt: now,
      favorite: true,
      pinned: true,
      tags: const ['study', 'ai'],
      folder: 'School',
      notes: 'Review chapter 4',
      markers: const [
        RecordingMarker(
          positionMs: 5000,
          label: 'Important',
          note: 'Definition',
        ),
      ],
      waveform: const [.1, .3, .8],
    );

    final restored = RecordingEntry.fromJson(entry.toJson());
    expect(restored.id, entry.id);
    expect(restored.format, RecordingFormat.flac);
    expect(restored.tags, ['study', 'ai']);
    expect(restored.markers.single.label, 'Important');
    expect(restored.waveform, [.1, .3, .8]);
    expect(restored.favorite, isTrue);
    expect(restored.pinned, isTrue);
  });

  test('copyWith can clear trash state', () {
    final entry = RecordingEntry(
      id: 'abc',
      title: 'Deleted',
      filePath: '/trash/a.wav',
      durationMs: 1,
      sizeBytes: 1,
      format: RecordingFormat.wav,
      bitRate: 0,
      sampleRate: 44100,
      channels: 1,
      createdAt: DateTime.utc(2026),
      modifiedAt: DateTime.utc(2026),
      trashedAt: DateTime.utc(2026, 2),
    );
    expect(entry.copyWith(clearTrashedAt: true).trashedAt, isNull);
  });
}
