import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/constants.dart';
import '../models/recording_entry.dart';

class UnsupportedMetadataSchemaException implements Exception {
  const UnsupportedMetadataSchemaException(this.schemaVersion);

  final int schemaVersion;

  @override
  String toString() =>
      'UnsupportedMetadataSchemaException: metadata schema '
      '$schemaVersion is not supported by this SonicNest build.';
}

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
    final backup = File('${file.path}.bak');

    if (!await file.exists()) {
      if (!await backup.exists()) {
        return [];
      }
      final recovered = await _decodeEntries(backup);
      if (!recovered.valid) {
        await _backupCorruptFile(backup);
        await save(const []);
        return [];
      }
      await backup.copy(file.path);
      await backup.delete();
      return recovered.entries;
    }

    final primary = await _decodeEntries(file);
    if (primary.valid) {
      if (await backup.exists()) {
        await backup.delete();
      }
      return primary.entries;
    }

    await _backupCorruptFile(file);
    if (!await backup.exists()) {
      await save(const []);
      return [];
    }

    final recovered = await _decodeEntries(backup);
    if (!recovered.valid) {
      await _backupCorruptFile(backup);
      await save(const []);
      return [];
    }

    await backup.copy(file.path);
    await backup.delete();
    return recovered.entries;
  }

  Future<({bool valid, List<RecordingEntry> entries})> _decodeEntries(
    File file,
  ) async {
    dynamic decoded;
    try {
      decoded = jsonDecode(await file.readAsString());
    } on FormatException {
      return (valid: false, entries: const <RecordingEntry>[]);
    } on FileSystemException {
      return (valid: false, entries: const <RecordingEntry>[]);
    }

    if (decoded is! Map) {
      return (valid: false, entries: const <RecordingEntry>[]);
    }

    Map<String, dynamic> root;
    try {
      root = Map<String, dynamic>.from(decoded);
    } on Object {
      return (valid: false, entries: const <RecordingEntry>[]);
    }

    final schemaVersion = root['schemaVersion'];
    if (schemaVersion != null) {
      if (schemaVersion is! int) {
        return (valid: false, entries: const <RecordingEntry>[]);
      }
      if (schemaVersion != AppConstants.metadataSchemaVersion) {
        throw UnsupportedMetadataSchemaException(schemaVersion);
      }
    }

    final rawEntries = root['recordings'];
    if (rawEntries == null) {
      return (valid: true, entries: const <RecordingEntry>[]);
    }
    if (rawEntries is! List) {
      return (valid: false, entries: const <RecordingEntry>[]);
    }

    final entries = <RecordingEntry>[];
    final seenIds = <String>{};
    final seenPaths = <String>{};
    for (final item in rawEntries) {
      if (item is! Map) {
        continue;
      }
      try {
        final entry = RecordingEntry.fromJson(Map<String, dynamic>.from(item));
        if (entry.id.isEmpty || entry.filePath.isEmpty) {
          continue;
        }
        final normalizedPath = p.normalize(entry.filePath);
        if (!seenIds.add(entry.id) || !seenPaths.add(normalizedPath)) {
          continue;
        }
        entries.add(entry);
      } on Object {
        // Isolate malformed records so one bad entry cannot block startup or
        // hide otherwise recoverable library metadata.
      }
    }
    return (valid: true, entries: entries);
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
