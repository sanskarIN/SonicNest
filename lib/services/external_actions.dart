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
    while (await File(candidate).exists()) {
      candidate = p.join(
        directory.path,
        '$stem ($suffix)$extension',
      );
      suffix++;
    }
    return candidate;
  }

  Future<ExternalCopyBatchResult> copyFilesToDirectoryCollisionSafe({
    required List<String> sourcePaths,
    required String directoryPath,
  }) async {
    final copiedPaths = <String>[];
    final failures = <String, String>{};
    for (final sourcePath in sourcePaths) {
      try {
        copiedPaths.add(
          await copyFileToDirectoryCollisionSafe(
            sourcePath: sourcePath,
            directoryPath: directoryPath,
          ),
        );
      } catch (error) {
        failures[sourcePath] = error.toString();
      }
    }
    return ExternalCopyBatchResult(
      copiedPaths: copiedPaths,
      failures: failures,
    );
  }

  Future<void> openUrl(String value) async {
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme) {
      throw ArgumentError.value(value, 'value', 'Invalid URL.');
    }
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw StateError('Unable to open the requested URL.');
    }
  }

  Future<ShareResult> shareFiles(List<String> paths) async {
    if (paths.isEmpty) {
      throw ArgumentError.value(paths, 'paths', 'No files selected.');
    }
    return SharePlus.instance.share(
      ShareParams(
        files: paths.map(XFile.new).toList(growable: false),
      ),
    );
  }
}
