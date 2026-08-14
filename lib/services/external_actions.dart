import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ExternalActions {
  Future<List<String>> pickAudioFiles() async {
    final result = await FilePicker.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: const ['m4a', 'wav', 'flac', 'opus', 'mp3', 'ogg', 'aac'],
    );
    if (result == null) return [];
    return result.files.map((file) => file.path).whereType<String>().toList();
  }

  Future<String?> pickSingleAudioFile() async {
    final result = await FilePicker.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: const ['m4a', 'wav', 'flac', 'opus', 'mp3', 'ogg', 'aac'],
    );
    return result?.files.single.path;
  }

  Future<String?> chooseExportPath(String fileName) {
    return FilePicker.saveFile(
      dialogTitle: 'Export recording',
      fileName: fileName,
    );
  }

  Future<void> shareFile(String path, {String? text}) =>
      shareFiles([path], text: text);

  Future<void> shareFiles(List<String> paths, {String? text}) async {
    if (paths.isEmpty) return;
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
