import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/file_name.dart';

class StorageStats {
  const StorageStats({
    required this.recordingsBytes,
    required this.trashBytes,
    required this.temporaryBytes,
    required this.recordingCount,
    required this.trashCount,
    required this.temporaryFileCount,
  });

  final int recordingsBytes;
  final int trashBytes;
  final int temporaryBytes;
  final int recordingCount;
  final int trashCount;
  final int temporaryFileCount;

  int get totalManagedBytes => recordingsBytes + trashBytes + temporaryBytes;
}

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

  Future<int> nextRecordingSequence() async {
    final recordings = await _countFiles(await recordingsDirectory);
    final trash = await _countFiles(await trashDirectory);
    return recordings + trash + 1;
  }

  Future<StorageStats> stats() async {
    final recordingMetrics = await _directoryMetrics(await recordingsDirectory);
    final trashMetrics = await _directoryMetrics(await trashDirectory);
    final tempMetrics = await _directoryMetrics(await tempDirectory);
    return StorageStats(
      recordingsBytes: recordingMetrics.bytes,
      trashBytes: trashMetrics.bytes,
      temporaryBytes: tempMetrics.bytes,
      recordingCount: recordingMetrics.files,
      trashCount: trashMetrics.files,
      temporaryFileCount: tempMetrics.files,
    );
  }

  Future<void> clearTemporaryFiles() async {
    final directory = await tempDirectory;
    await for (final entity in directory.list(followLinks: false)) {
      try {
        await entity.delete(recursive: true);
      } on FileSystemException {
        // A file may still be in use by an active platform codec. Leave it alone.
      }
    }
  }

  Future<({int bytes, int files})> _directoryMetrics(Directory directory) async {
    var bytes = 0;
    var files = 0;
    if (!await directory.exists()) {
      return (bytes: 0, files: 0);
    }
    await for (final entity in directory.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        try {
          bytes += await entity.length();
          files++;
        } on FileSystemException {
          // Ignore files that disappear while the statistics pass is running.
        }
      }
    }
    return (bytes: bytes, files: files);
  }

  Future<int> _countFiles(Directory directory) async {
    final metrics = await _directoryMetrics(directory);
    return metrics.files;
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
