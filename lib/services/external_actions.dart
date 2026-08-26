import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ExternalCopyBatchResult {
  const ExternalCopyBatchResult({
    required this.copiedPaths,
    required this.failures,
  });

  final List<String> copiedPaths;
  final Map<String, String> failures;

  int get copiedCount => copiedPaths.length;
  int get failedCount => failures.length;
  bool get hasFailures => failures.isNotEmpty;
}

class ExternalActions {
  Future<List<String>> pickAudioFiles() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const [
        'm4a',
        'wav',
        'flac',
        'opus',
        'mp3',
        'ogg',
        'aac',
      ],
    );
    if (result.isEmpty) {
      return [];
    }
    return result.map((file) => file.path).whereType<String>().toList();
  }

  Future<String?> pickSingleAudioFile() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const [
        'm4a',
        'wav',
        'flac',
        'opus',
        'mp3',
        'ogg',
        'aac',
      ],
    );
    return file?.path;
  }

  Future<String?> pickSingleJsonFile() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );
    return file?.path;
  }

  Future<String?> chooseExportPath(String fileName) async {
    final directoryPath = await FilePicker.getDirectoryPath();
    if (directoryPath == null) {
      return null;
    }
    final directory = Directory(directoryPath);
    if (!await directory.exists()) {
      throw StateError('The selected destination folder is unavailable.');
    }
    return _collisionSafeDestination(directory, p.basename(fileName));
  }

  Future<String?> chooseExportDirectory() {
    return FilePicker.getDirectoryPath();
  }

  Future<String> copyFileToDirectoryCollisionSafe({
    required String sourcePath,
    required String directoryPath,
  }) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw StateError('Source file no longer exists.');
    }

    final directory = Directory(directoryPath);
    if (!await directory.exists()) {
      throw StateError('The selected destination folder is unavailable.');
    }

    final candidate = await _collisionSafeDestination(
      directory,
      p.basename(sourcePath),
    );
    final copied = await source.copy(candidate);
    return copied.path;
  }

  Future<String> _collisionSafeDestination(
    Directory directory,
    String fileName,
  ) async {
    final safeName = p.basename(fileName);
    if (safeName.isEmpty || safeName == '.' || safeName == '..') {
      throw ArgumentError.value(
        fileName,
        'fileName',
        'Invalid export filename.',
      );
    }
    final stem = p.basenameWithoutExtension(safeName);
    final extension = p.extension(safeName);
    var candidate = p.join(directory.path, '$stem$extension');
    var suffix = 2;

    while (await _pathOccupied(candidate)) {
      candidate = p.join(directory.path, '$stem ($suffix)$extension');
      suffix++;
    }
    return candidate;
  }

  Future<bool> _pathOccupied(String path) async {
    try {
      return await FileSystemEntity.type(path, followLinks: false) !=
          FileSystemEntityType.notFound;
    } on FileSystemException {
      // Do not choose a destination path that cannot be inspected safely.
      return true;
    }
  }

  Future<ExternalCopyBatchResult> copyFilesToDirectoryCollisionSafe({
    required Iterable<String> sourcePaths,
    required String directoryPath,
  }) async {
    final copiedPaths = <String>[];
    final failures = <String, String>{};

    for (final sourcePath in sourcePaths) {
      try {
        final copied = await copyFileToDirectoryCollisionSafe(
          sourcePath: sourcePath,
          directoryPath: directoryPath,
        );
        copiedPaths.add(copied);
      } catch (error) {
        failures[sourcePath] = error.toString();
      }
    }

    return ExternalCopyBatchResult(
      copiedPaths: List.unmodifiable(copiedPaths),
      failures: Map.unmodifiable(failures),
    );
  }

  Future<void> shareFile(String path, {String? text}) =>
      shareFiles([path], text: text);

  Future<void> shareFiles(List<String> paths, {String? text}) async {
    if (paths.isEmpty) {
      return;
    }
    await SharePlus.instance.share(
      ShareParams(
        files: paths.map(XFile.new).toList(growable: false),
        text: text,
      ),
    );
  }

  Future<void> launchExternal(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw StateError('Could not open external link.');
    }
  }

  Future<void> composeEmail(String email, {String? subject}) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: subject == null ? null : {'subject': subject},
    );
    if (!await launchUrl(uri)) {
      throw StateError('Could not open an email application.');
    }
  }
}
