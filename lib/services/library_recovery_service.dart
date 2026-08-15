import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../models/recording_entry.dart';
import '../models/recording_settings.dart';
import 'storage_service.dart';

class LibraryRecoveryService {
  LibraryRecoveryService({
    required this.storage,
    required this.probeDuration,
    required this.extractWaveform,
    String Function()? idFactory,
  }) : _idFactory = idFactory ?? const Uuid().v7;

  final StorageService storage;
  final Future<Duration> Function(String path) probeDuration;
  final Future<List<double>> Function(String path) extractWaveform;
  final String Function() _idFactory;

  Future<List<RecordingEntry>> recoverOrphanedRecordings(
    Iterable<RecordingEntry> knownEntries,
  ) async {
    final knownPaths = knownEntries
        .map((entry) => _pathKey(entry.filePath))
        .toSet();
    final recovered = <RecordingEntry>[];

    for (final file in await storage.managedRecordingFiles()) {
      final pathKey = _pathKey(file.path);
      if (knownPaths.contains(pathKey)) {
        continue;
      }

      final format = _formatForPath(file.path);
      if (format == null) {
        continue;
      }

      FileStat stat;
      try {
        stat = await file.stat();
      } on FileSystemException {
        continue;
      }
      if (stat.type != FileSystemEntityType.file) {
        continue;
      }

      var duration = Duration.zero;
      var waveform = const <double>[];
      try {
        duration = await probeDuration(file.path);
      } on Object {
        // A partially written or damaged file should still be surfaced so the
        // user can inspect, export, or delete the preserved managed copy.
      }
      try {
        waveform = await extractWaveform(file.path);
      } on Object {
        // Waveform extraction is best effort during crash/orphan recovery.
      }

      final timestamp = stat.modified;
      recovered.add(
        RecordingEntry(
          id: _idFactory(),
          title: p.basenameWithoutExtension(file.path),
          filePath: file.path,
          durationMs: duration.isNegative ? 0 : duration.inMilliseconds,
          sizeBytes: stat.size < 0 ? 0 : stat.size,
          format: format,
          bitRate: 0,
          sampleRate: 0,
          channels: 0,
          createdAt: timestamp,
          modifiedAt: timestamp,
          tags: const ['Recovered'],
          notes:
              'Recovered from SonicNest managed storage after library metadata was missing.',
          waveform: waveform,
        ),
      );
      knownPaths.add(pathKey);
    }

    return List.unmodifiable(recovered);
  }

  RecordingFormat? _formatForPath(String path) {
    final extension = p.extension(path).replaceFirst('.', '').toLowerCase();
    for (final format in RecordingFormat.values) {
      if (format.extension == extension) {
        return format;
      }
    }
    return null;
  }

  String _pathKey(String path) => p.normalize(p.absolute(path));
}
