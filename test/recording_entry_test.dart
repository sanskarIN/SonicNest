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

  test('malformed optional metadata falls back without throwing', () {
    final entry = RecordingEntry.fromJson({
      'id': 'safe-id',
      'title': 42,
      'filePath': '/audio/safe.wav',
      'durationMs': 'bad-duration',
      'sizeBytes': <String, Object>{},
      'format': 7,
      'bitRate': false,
      'sampleRate': '48000',
      'channels': null,
      'createdAt': 123,
      'modifiedAt': <String>[],
      'favorite': 'yes',
      'pinned': 1,
      'tags': ['valid', 3, null],
      'folder': false,
      'notes': 99,
      'markers': [
        {
          'positionMs': 'bad',
          'label': 5,
          'note': false,
        },
        'not-a-marker',
        {1: 'non-string-key'},
      ],
      'waveform': [0.25, 'bad', 1],
      'trashedAt': 1234,
    });

    expect(entry.id, 'safe-id');
    expect(entry.title, 'Recording');
    expect(entry.filePath, '/audio/safe.wav');
    expect(entry.durationMs, 0);
    expect(entry.sizeBytes, 0);
    expect(entry.format, RecordingFormat.m4a);
    expect(entry.bitRate, 0);
    expect(entry.sampleRate, 0);
    expect(entry.channels, 1);
    expect(entry.favorite, isFalse);
    expect(entry.pinned, isFalse);
    expect(entry.tags, ['valid']);
    expect(entry.folder, isEmpty);
    expect(entry.notes, isEmpty);
    expect(entry.markers, hasLength(1));
    expect(entry.markers.single.positionMs, 0);
    expect(entry.markers.single.label, 'Marker');
    expect(entry.waveform, [0.25, 1.0]);
    expect(entry.trashedAt, isNull);
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
