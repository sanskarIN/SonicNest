import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/constants.dart';
import '../models/recording_entry.dart';

class MetadataStore {
  MetadataStore({
    Future<Directory> Function()? supportDirectoryProvider,
    DateTime Function()? clock,
  }) : _supportDirectoryProvider =
           supportDirectoryProvider ?? getApplicationSupportDirectory,
       _clock = clock ?? DateTime.now;

  final Future<Directory> Function() _supportDirectoryProvider;
  final DateTime Function() _clock;

  File? _file;

  Future<File> get _metadataFile async {
    if (_file != null) {
      return _file!;
    }
    final directory = await _supportDirectoryProvider();
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

    dynamic decoded;
    try {
      decoded = jsonDecode(await file.readAsString());
    } on FormatException {
      await _backupCorruptFile(file);
      return [];
    }

    if (decoded is! Map) {
      await _backupCorruptFile(file);
      return [];
    }

    Map<String, dynamic> root;
    try {
      root = Map<String, dynamic>.from(decoded);
    } on Object {
      await _backupCorruptFile(file);
      return [];
    }

    final rawEntries = root['recordings'];
    if (rawEntries == null) {
      return [];
    }
    if (rawEntries is! List) {
      await _backupCorruptFile(file);
      return [];
    }

    final entries = <RecordingEntry>[];
    for (final item in rawEntries) {
      if (item is! Map) {
        continue;
      }
      try {
        final entry = RecordingEntry.fromJson(
          Map<String, dynamic>.from(item),
        );
        if (entry.id.isNotEmpty && entry.filePath.isNotEmpty) {
          entries.add(entry);
        }
      } on Object {
        // Isolate malformed records so one bad entry cannot block startup or
        // hide otherwise recoverable library metadata.
      }
    }
    return entries;
  }

  Future<void> save(List<RecordingEntry> entries) async {
    final file = await _metadataFile;
    final temp = File('${file.path}.tmp');
    final backup = File('${file.path}.bak');
    final payload = <String, Object>{
      'schemaVersion': AppConstants.metadataSchemaVersion,
      'updatedAt': _clock().toUtc().toIso8601String(),
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

  Future<void> _backupCorruptFile(File file) async {
    if (!await file.exists()) {
      return;
    }
    final timestamp = _clock().millisecondsSinceEpoch;
    var backup = File('${file.path}.corrupt.$timestamp');
    var suffix = 1;
    while (await backup.exists()) {
      backup = File('${file.path}.corrupt.$timestamp.$suffix');
      suffix += 1;
    }
    await file.copy(backup.path);
  }
}
