import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/constants.dart';
import '../models/recording_entry.dart';

class MetadataStore {
  File? _file;

  Future<File> get _metadataFile async {
    if (_file != null) {
      return _file!;
    }
    final directory = await getApplicationSupportDirectory();
    final appDirectory = Directory(p.join(directory.path, 'SonicNest'));
    if (!await appDirectory.exists()) {
      await appDirectory.create(recursive: true);
    }
    _file = File(p.join(appDirectory.path, 'recordings.json'));
    return _file!;
  }

  Future<List<RecordingEntry>> load() async {
    final file = await _metadataFile;
    if (!await file.exists()) {
      return [];
    }
    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map<String, dynamic>) {
        return [];
      }
      final rawEntries = decoded['recordings'] as List<dynamic>? ?? const [];
      return rawEntries
          .whereType<Map>()
          .map(
            (item) => RecordingEntry.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .where((entry) => entry.id.isNotEmpty && entry.filePath.isNotEmpty)
          .toList();
    } on FormatException {
      final backup = File(
        '${file.path}.corrupt.${DateTime.now().millisecondsSinceEpoch}',
      );
      await file.copy(backup.path);
      return [];
    }
  }

  Future<void> save(List<RecordingEntry> entries) async {
    final file = await _metadataFile;
    final temp = File('${file.path}.tmp');
    final backup = File('${file.path}.bak');
    final payload = <String, Object>{
      'schemaVersion': AppConstants.metadataSchemaVersion,
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
      'recordings': entries.map((entry) => entry.toJson()).toList(),
    };
    await temp.writeAsString(
      const JsonEncoder.withIndent('  ').convert(payload),
      flush: true,
    );

    if (await backup.exists()) {
      await backup.delete();
    }
    if (await file.exists()) {
      await file.rename(backup.path);
    }
    try {
      await temp.rename(file.path);
      if (await backup.exists()) {
        await backup.delete();
      }
    } catch (_) {
      if (await file.exists()) {
        await file.delete();
      }
      if (await backup.exists()) {
        await backup.rename(file.path);
      }
      rethrow;
    }
  }
}
