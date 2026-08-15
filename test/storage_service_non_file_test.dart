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

  test('non-file collision forces a numbered destination', () async {
    final recordings = await storage.recordingsDirectory;
    final occupied = Directory('${recordings.path}/Reserved.wav');
    await occupied.create();

    final allocated = await storage.uniqueRecordingPath('Reserved', 'wav');

    expect(allocated, isNot(occupied.path));
    expect(await occupied.exists(), isTrue);
  });
}
