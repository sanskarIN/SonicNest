import 'package:path/path.dart' as p;

import '../models/recording_settings.dart';
import 'audio_processor.dart';
import 'storage_service.dart';

class ImportedAudioData {
  const ImportedAudioData({
    required this.sourcePath,
    required this.filePath,
    required this.title,
    required this.duration,
    required this.sizeBytes,
    required this.format,
    required this.waveform,
  });

  final String sourcePath;
  final String filePath;
  final String title;
  final Duration duration;
  final int sizeBytes;
  final RecordingFormat format;
  final List<double> waveform;
}

class AudioImportException implements Exception {
  const AudioImportException({required this.sourcePath, required this.message});

  final String sourcePath;
  final String message;

  @override
  String toString() => 'AudioImportException: $message';
}

class AudioImportService {
  const AudioImportService({required this.storage, required this.processor});

  final StorageService storage;
  final AudioProcessor processor;

  Future<ImportedAudioData> importOne(String sourcePath) async {
    String? importedPath;
    try {
      importedPath = await storage.importFile(sourcePath);
      final extension = p
          .extension(importedPath)
          .replaceFirst('.', '')
          .toLowerCase();
      final format =
          RecordingFormat.values
              .where((candidate) => candidate.extension == extension)
              .firstOrNull ??
          RecordingFormat.m4a;
      final duration = await processor.probeDuration(importedPath);
      final waveform = await processor.extractWaveformEnvelope(importedPath);
      final sizeBytes = await storage.fileSize(importedPath);
      return ImportedAudioData(
        sourcePath: sourcePath,
        filePath: importedPath,
        title: p.basenameWithoutExtension(importedPath),
        duration: duration,
        sizeBytes: sizeBytes,
        format: format,
        waveform: waveform,
      );
    } catch (error) {
      Object? cleanupError;
      if (importedPath != null) {
        try {
          await storage.deleteIfExists(importedPath);
        } catch (error) {
          cleanupError = error;
        }
      }
      final cleanupMessage = cleanupError == null
          ? ''
          : ' Cleanup also failed: $cleanupError';
      throw AudioImportException(
        sourcePath: sourcePath,
        message: '$error$cleanupMessage',
      );
    }
  }
}

extension _IterableFirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
