import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/file_name.dart';

class StorageService {
  Directory? _root;

  Future<Directory> get root async {
    if (_root != null) {
      return _root!;
    }
    final base = await getApplicationDocumentsDirectory();
    final directory = Directory(p.join(base.path, 'SonicNest'));
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    _root = directory;
    return directory;
  }

  Future<Directory> get recordingsDirectory async {
    final directory = Directory(p.join((await root).path, 'Recordings'));
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  Future<Directory> get trashDirectory async {
    final directory = Directory(p.join((await root).path, '.trash'));
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  Future<Directory> get tempDirectory async {
    final base = await getTemporaryDirectory();
    final directory = Directory(p.join(base.path, 'SonicNest'));
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  Future<String> uniqueRecordingPath(String title, String extension) async {
    return _uniquePath(await recordingsDirectory, title, extension);
  }

  Future<String> uniqueTrashPath(String title, String extension) async {
    return _uniquePath(await trashDirectory, title, extension);
  }

  Future<String> uniqueTempPath(String title, String extension) async {
    return _uniquePath(await tempDirectory, title, extension);
  }

  Future<String> _uniquePath(
    Directory directory,
    String title,
    String extension,
  ) async {
    final stem = sanitizeFileStem(title);
    final ext = extension.startsWith('.') ? extension.substring(1) : extension;
    var candidate = p.join(directory.path, '$stem.$ext');
    var suffix = 2;
    while (await File(candidate).exists()) {
      candidate = p.join(directory.path, '$stem ($suffix).$ext');
      suffix++;
    }
    return candidate;
  }

  Future<int> fileSize(String path) async {
    final file = File(path);
    return await file.exists() ? file.length() : 0;
  }

  Future<String> renameAudio(String currentPath, String newTitle) async {
    final extension = p.extension(currentPath).replaceFirst('.', '');
    final target = await uniqueRecordingPath(newTitle, extension);
    return (await File(currentPath).rename(target)).path;
  }

  Future<String> duplicateAudio(String sourcePath, String newTitle) async {
    final extension = p.extension(sourcePath).replaceFirst('.', '');
    final target = await uniqueRecordingPath(newTitle, extension);
    return (await File(sourcePath).copy(target)).path;
  }

  Future<String> moveToTrash(String sourcePath, String title) async {
    final extension = p.extension(sourcePath).replaceFirst('.', '');
    final target = await uniqueTrashPath(title, extension);
    return (await File(sourcePath).rename(target)).path;
  }

  Future<String> restoreFromTrash(String sourcePath, String title) async {
    final extension = p.extension(sourcePath).replaceFirst('.', '');
    final target = await uniqueRecordingPath(title, extension);
    return (await File(sourcePath).rename(target)).path;
  }

  Future<void> deleteIfExists(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<String> importFile(String sourcePath) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw const FileSystemException('Selected audio file no longer exists.');
    }
    final extension = p.extension(source.path).replaceFirst('.', '').toLowerCase();
    const supported = {'m4a', 'wav', 'flac', 'opus', 'mp3', 'ogg', 'aac'};
    if (!supported.contains(extension)) {
      throw const FormatException('Unsupported audio extension.');
    }
    final title = p.basenameWithoutExtension(source.path);
    final target = await uniqueRecordingPath(title, extension);
    return (await source.copy(target)).path;
  }
}
