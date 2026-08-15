import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sonic_nest/models/recording_entry.dart';
import 'package:sonic_nest/models/recording_settings.dart';
import 'package:sonic_nest/services/library_recovery_service.dart';
import 'package:sonic_nest/services/storage_service.dart';

void main() {
  late Directory sandbox;
  late Directory documents;
  late Directory temporary;
  late StorageService storage;
  var nextId = 0;

  setUp(() async {
    sandbox = await Directory.systemTemp.createTemp('sonicnest-recovery-test-');
    documents = Directory('${sandbox.path}/documents');
    temporary = Directory('${sandbox.path}/temporary');
    await documents.create(recursive: true);
    await temporary.create(recursive: true);
    storage = StorageService(
      documentsDirectoryProvider: () async => documents,
      temporaryDirectoryProvider: () async => temporary,
    );
    nextId = 0;
  });

  tearDown(() async {
    if (await sandbox.exists()) {
      await sandbox.delete(recursive: true);
    }
  });

  LibraryRecoveryService createRecovery({
    Future<Duration> Function(String path)? probeDuration,
    Future<List<double>> Function(String path)? extractWaveform,
  }) {
    return LibraryRecoveryService(
      storage: storage,
      probeDuration:
          probeDuration ?? (_) async => const Duration(milliseconds: 2500),
      extractWaveform:
          extractWaveform ?? (_) async => const [0.0, 0.5, 1.0, 0.25],
      idFactory: () => 'recovered-${nextId++}',
    );
  }

  Future<File> createRecording(String title, String extension) async {
    final path = await storage.uniqueRecordingPath(title, extension);
    final file = File(path);
    await file.writeAsBytes(const [1, 2, 3, 4], flush: true);
    return file;
  }

  Future<File> createTrashRecording(String title, String extension) async {
    final path = await storage.uniqueTrashPath(title, extension);
    final file = File(path);
    await file.writeAsBytes(const [4, 3, 2, 1], flush: true);
    return file;
  }

  test('recovers supported managed audio missing from metadata', () async {
    final orphan = await createRecording('Orphan', 'wav');

    final recovered = await createRecovery().recoverOrphanedRecordings(
      const [],
    );

    expect(recovered, hasLength(1));
    final entry = recovered.single;
    expect(entry.id, 'recovered-0');
    expect(entry.title, 'Orphan');
    expect(entry.filePath, orphan.path);
    expect(entry.format, RecordingFormat.wav);
    expect(entry.durationMs, 2500);
    expect(entry.sizeBytes, 4);
    expect(entry.channels, 0);
    expect(entry.tags, ['Recovered']);
    expect(entry.notes, contains('metadata was missing'));
    expect(entry.waveform, [0.0, 0.5, 1.0, 0.25]);
    expect(entry.isTrashed, isFalse);
  });

  test('recovers an unindexed managed Trash file back into Trash', () async {
    final orphan = await createTrashRecording('Interrupted Delete', 'flac');

    final recovered = await createRecovery().recoverOrphanedRecordings(
      const [],
    );

    expect(recovered, hasLength(1));
    final entry = recovered.single;
    expect(entry.filePath, orphan.path);
    expect(entry.format, RecordingFormat.flac);
    expect(entry.isTrashed, isTrue);
    expect(entry.trashedAt, isNotNull);
    expect(entry.tags, ['Recovered']);
    expect(entry.notes, contains('Recovered in Trash'));
  });

  test(
    'does not duplicate a managed file already represented in metadata',
    () async {
      final file = await createRecording('Known', 'm4a');
      final now = DateTime.utc(2026, 8, 15);
      final known = RecordingEntry(
        id: 'known',
        title: 'Known',
        filePath: file.path,
        durationMs: 100,
        sizeBytes: 4,
        format: RecordingFormat.m4a,
        bitRate: 96000,
        sampleRate: 44100,
        channels: 1,
        createdAt: now,
        modifiedAt: now,
      );

      final recovered = await createRecovery().recoverOrphanedRecordings([
        known,
      ]);

      expect(recovered, isEmpty);
    },
  );

  test('does not duplicate a managed Trash file already represented', () async {
    final file = await createTrashRecording('Known Trash', 'wav');
    final now = DateTime.utc(2026, 8, 15);
    final known = RecordingEntry(
      id: 'known-trash',
      title: 'Known Trash',
      filePath: file.path,
      durationMs: 100,
      sizeBytes: 4,
      format: RecordingFormat.wav,
      bitRate: 0,
      sampleRate: 48000,
      channels: 1,
      createdAt: now,
      modifiedAt: now,
      trashedAt: now,
    );

    final recovered = await createRecovery().recoverOrphanedRecordings([known]);

    expect(recovered, isEmpty);
  });

  test('keeps damaged orphan visible when media probing fails', () async {
    final file = await createRecording('Damaged', 'mp3');
    final recovery = createRecovery(
      probeDuration: (_) async => throw const FormatException('bad media'),
      extractWaveform: (_) async => throw const FormatException('bad media'),
    );

    final recovered = await recovery.recoverOrphanedRecordings(const []);

    expect(recovered, hasLength(1));
    expect(recovered.single.filePath, file.path);
    expect(recovered.single.format, RecordingFormat.mp3);
    expect(recovered.single.durationMs, 0);
    expect(recovered.single.waveform, isEmpty);
  });

  test('recovers each supported format with a unique metadata id', () async {
    for (final format in RecordingFormat.values) {
      await createRecording('Audio ${format.name}', format.extension);
    }

    final recovered = await createRecovery().recoverOrphanedRecordings(
      const [],
    );

    expect(recovered, hasLength(RecordingFormat.values.length));
    expect(
      recovered.map((entry) => entry.id).toSet(),
      hasLength(recovered.length),
    );
    expect(
      recovered.map((entry) => entry.format).toSet(),
      RecordingFormat.values.toSet(),
    );
  });
}
