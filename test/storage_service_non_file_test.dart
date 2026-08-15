import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sonic_nest/services/storage_service.dart';

void main() {
  late Directory sandbox;
  late StorageService storage;

  setUp(() async {
    sandbox = await Directory.systemTemp.createTemp(
      'sonicnest-storage-non-file-test-',
    );
    final documents = Directory('${sandbox.path}/documents');
    final temporary = Directory('${sandbox.path}/temporary');
    await documents.create(recursive: true);
    await temporary.create(recursive: true);
    storage = StorageService(
      documentsDirectoryProvider: () async => documents,
      temporaryDirectoryProvider: () async => temporary,
    );
  });

  tearDown(() async {
    if (await sandbox.exists()) {
      await sandbox.delete(recursive: true);
    }
  });

  test('directory with an audio extension is never treated as audio', () async {
    final recordings = await storage.recordingsDirectory;
    final directory = Directory('${recordings.path}/Folder.wav');
    await directory.create();

    expect(await storage.isManagedAudioPath(directory.path), isFalse);
    await expectLater(
      storage.renameAudio(directory.path, 'Renamed'),
      throwsA(isA<FileSystemException>()),
    );
    await expectLater(
      storage.moveToTrash(directory.path, 'Folder'),
      throwsA(isA<FileSystemException>()),
    );
    await expectLater(
      storage.deleteManagedAudioIfExists(directory.path),
      throwsA(isA<FileSystemException>()),
    );
    expect(await directory.exists(), isTrue);
  });

  test(
    'unsupported regular file inside managed storage is protected',
    () async {
      final recordings = await storage.recordingsDirectory;
      final notes = File('${recordings.path}/notes.txt');
      await notes.writeAsString('do not treat as recording', flush: true);

      expect(await storage.isManagedAudioPath(notes.path), isFalse);
      await expectLater(
        storage.renameAudio(notes.path, 'Renamed'),
        throwsA(isA<FileSystemException>()),
      );
      await expectLater(
        storage.duplicateAudio(notes.path, 'Copy'),
        throwsA(isA<FileSystemException>()),
      );
      await expectLater(
        storage.moveToTrash(notes.path, 'Notes'),
        throwsA(isA<FileSystemException>()),
      );
      await expectLater(
        storage.deleteManagedAudioIfExists(notes.path),
        throwsA(isA<FileSystemException>()),
      );

      expect(await notes.exists(), isTrue);
      expect(await notes.readAsString(), 'do not treat as recording');
    },
  );

  test('non-file collision forces a numbered destination', () async {
    final recordings = await storage.recordingsDirectory;
    final occupied = Directory('${recordings.path}/Reserved.wav');
    await occupied.create();

    final allocated = await storage.uniqueRecordingPath('Reserved', 'wav');

    expect(allocated, isNot(occupied.path));
    expect(await occupied.exists(), isTrue);
  });

  test('storage stats and sequence count only managed audio entries', () async {
    final recordings = await storage.recordingsDirectory;
    final trash = await storage.trashDirectory;
    final temporary = await storage.tempDirectory;

    final active = File('${recordings.path}/active.wav');
    final trashed = File('${trash.path}/deleted.mp3');
    final unsupported = File('${recordings.path}/notes.txt');
    final nestedDirectory = Directory('${recordings.path}/nested');
    final nestedAudio = File('${nestedDirectory.path}/nested.flac');
    final temporaryFile = File('${temporary.path}/processing.tmp');

    await nestedDirectory.create(recursive: true);
    await active.writeAsBytes(const [1, 2, 3], flush: true);
    await trashed.writeAsBytes(const [4, 5, 6, 7], flush: true);
    await unsupported.writeAsBytes(const [8, 9, 10, 11, 12], flush: true);
    await nestedAudio.writeAsBytes(const [13, 14, 15, 16, 17, 18], flush: true);
    await temporaryFile.writeAsBytes(const [19, 20], flush: true);

    final stats = await storage.stats();

    expect(stats.recordingCount, 1);
    expect(stats.recordingsBytes, 3);
    expect(stats.trashCount, 1);
    expect(stats.trashBytes, 4);
    expect(stats.temporaryFileCount, 1);
    expect(stats.temporaryBytes, 2);
    expect(stats.totalManagedBytes, 9);
    expect(await storage.nextRecordingSequence(), 3);
  });
}
