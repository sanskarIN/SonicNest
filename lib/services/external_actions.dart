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
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
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
    if (result == null) {
      return [];
    }
    return result.files.map((file) => file.path).whereType<String>().toList();
  }

  Future<String?> pickSingleAudioFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
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
    return result?.files.single.path;
  }

  Future<String?> chooseExportPath(String fileName) {
    return FilePicker.platform.saveFile(fileName: fileName);
  }

  Future<String?> chooseExportDirectory() {
    return FilePicker.platform.getDirectoryPath();
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

    final fileName = p.basename(sourcePath);
    final stem = p.basenameWithoutExtension(fileName);
    final extension = p.extension(fileName);
    var candidate = p.join(directory.path, '$stem$extension');
    var suffix = 2;

    while (await File(candidate).exists()) {
      candidate = p.join(directory.path, '$stem ($suffix)$extension');
      suffix++;
    }

    final copied = await source.copy(candidate);
    return copied.path;
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
