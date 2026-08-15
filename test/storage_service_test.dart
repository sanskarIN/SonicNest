import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sonic_nest/services/storage_service.dart';

void main() {
  late Directory sandbox;
  late Directory documents;
  late Directory temporary;
  late StorageService storage;

  setUp(() async {
    sandbox = await Directory.systemTemp.createTemp('sonicnest-storage-test-');
    documents = Directory('${sandbox.path}/documents');
    temporary = Directory('${sandbox.path}/temporary');
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

  Future<File> createManagedRecording(String title) async {
    final path = await storage.uniqueRecordingPath(title, 'wav');
    final file = File(path);
    await file.writeAsBytes(const [0, 1, 2, 3], flush: true);
    return file;
  }

  test('rename, trash and restore remain inside managed storage', () async {
    final source = await createManagedRecording('Original');

    final renamed = await storage.renameAudio(source.path, 'Renamed');
    expect(await File(renamed).exists(), isTrue);
    expect(await storage.isManagedAudioPath(renamed), isTrue);

    final trashed = await storage.moveToTrash(renamed, 'Renamed');
    expect(await File(trashed).exists(), isTrue);
    expect(await storage.isManagedAudioPath(trashed), isTrue);
    expect(
      await storage.isManagedAudioPath(trashed, includeTrash: false),
      isFalse,
    );

    final restored = await storage.restoreFromTrash(trashed, 'Renamed');
    expect(await File(restored).exists(), isTrue);
    expect(await storage.isManagedAudioPath(restored), isTrue);
    expect(
      await storage.isManagedAudioPath(restored, includeTrash: false),
      isTrue,
    );
  });

  test('managed mutation methods reject an external source path', () async {
    final external = File('${sandbox.path}/outside.wav');
    await external.writeAsBytes(const [7, 8, 9], flush: true);

    await expectLater(
      storage.renameAudio(external.path, 'Renamed'),
      throwsA(isA<FileSystemException>()),
    );
    await expectLater(
      storage.duplicateAudio(external.path, 'Copy'),
      throwsA(isA<FileSystemException>()),
    );
    await expectLater(
      storage.moveToTrash(external.path, 'Outside'),
      throwsA(isA<FileSystemException>()),
    );
    await expectLater(
      storage.restoreFromTrash(external.path, 'Outside'),
      throwsA(isA<FileSystemException>()),
    );

    expect(await external.exists(), isTrue);
  });

  test('managed delete never removes an external file', () async {
    final external = File('${sandbox.path}/do-not-delete.wav');
    await external.writeAsBytes(const [4, 5, 6], flush: true);

    await expectLater(
      storage.deleteManagedAudioIfExists(external.path),
      throwsA(isA<FileSystemException>()),
    );
    expect(await external.exists(), isTrue);

    final managed = await createManagedRecording('Delete Me');
    await storage.deleteManagedAudioIfExists(managed.path);
    expect(await managed.exists(), isFalse);
  });

  test('collision allocation keeps every managed recording distinct', () async {
    final firstPath = await storage.uniqueRecordingPath('Same Name', 'wav');
    await File(firstPath).writeAsBytes(const [1], flush: true);

    final secondPath = await storage.uniqueRecordingPath('Same Name', '.wav');
    await File(secondPath).writeAsBytes(const [2], flush: true);

    expect(firstPath, isNot(secondPath));
    expect(await File(firstPath).readAsBytes(), [1]);
    expect(await File(secondPath).readAsBytes(), [2]);
  });

  test('recoverable file discovery returns only supported top-level audio', () async {
    final directory = await storage.recordingsDirectory;
    final wav = File('${directory.path}/b.wav');
    final mp3 = File('${directory.path}/a.MP3');
    final text = File('${directory.path}/notes.txt');
    final nestedDirectory = Directory('${directory.path}/nested');
    final nestedAudio = File('${nestedDirectory.path}/hidden.flac');
    await nestedDirectory.create(recursive: true);
    await wav.writeAsBytes(const [1], flush: true);
    await mp3.writeAsBytes(const [2], flush: true);
    await text.writeAsString('not audio', flush: true);
    await nestedAudio.writeAsBytes(const [3], flush: true);

    final files = await storage.managedRecordingFiles();

    expect(files.map((file) => file.path), [mp3.path, wav.path]);
  });

  test('Trash discovery is isolated from active recording discovery', () async {
    final active = await createManagedRecording('Active');
    final trashDirectory = await storage.trashDirectory;
    final trashed = File('${trashDirectory.path}/Deleted.wav');
    final ignored = File('${trashDirectory.path}/diagnostic.txt');
    await trashed.writeAsBytes(const [9, 8, 7], flush: true);
    await ignored.writeAsString('not audio', flush: true);

    final activeFiles = await storage.managedRecordingFiles();
    final trashFiles = await storage.managedTrashFiles();

    expect(activeFiles.map((file) => file.path), [active.path]);
    expect(trashFiles.map((file) => file.path), [trashed.path]);
  });
}
