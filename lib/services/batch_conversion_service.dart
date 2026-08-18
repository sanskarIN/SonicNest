import '../models/recording_entry.dart';
import '../models/recording_settings.dart';
import 'audio_processor.dart';
import 'external_actions.dart';
import 'storage_service.dart';

typedef BatchOutputRegistrar = Future<void> Function({
  required String path,
  required String title,
  required RecordingFormat format,
  required List<RecordingMarker> markers,
});

typedef BatchStopPredicate = bool Function();
typedef BatchProgressCallback = void Function(int completed, int total);

class BatchConversionIssue {
  const BatchConversionIssue({required this.title, required this.error});

  final String title;
  final Object error;

  @override
  String toString() => '$title: $error';
}

class BatchConversionResult {
  const BatchConversionResult({
    required this.total,
    required this.completed,
    required this.successes,
    required this.externalCopies,
    required this.conversionFailures,
    required this.exportFailures,
    required this.stopped,
  });

  final int total;
  final int completed;
  final int successes;
  final int externalCopies;
  final List<BatchConversionIssue> conversionFailures;
  final List<BatchConversionIssue> exportFailures;
  final bool stopped;

  int get conversionFailureCount => conversionFailures.length;
  int get exportFailureCount => exportFailures.length;
}

class BatchConversionService {
  const BatchConversionService({
    required this.processor,
    required this.storage,
    required this.external,
  });

  final AudioProcessor processor;
  final StorageService storage;
  final ExternalActions external;

  Future<BatchConversionResult> convert({
    required List<RecordingEntry> entries,
    required RecordingFormat format,
    required RecordingSettings fallbackSettings,
    required BatchOutputRegistrar registerOutput,
    String? exportDirectory,
    BatchStopPredicate? shouldStop,
    BatchProgressCallback? onProgress,
  }) async {
    final conversionFailures = <BatchConversionIssue>[];
    final exportFailures = <BatchConversionIssue>[];
    var completed = 0;
    var successes = 0;
    var externalCopies = 0;
    var stopped = false;

    for (final entry in entries) {
      if (shouldStop?.call() == true) {
        stopped = true;
        break;
      }

      String? output;
      try {
        final title = '${entry.title} ${format.label}';
        output = await processor.transcode(
          inputPath: entry.filePath,
          outputTitle: title,
          format: format,
          bitRate: entry.bitRate > 0 ? entry.bitRate : fallbackSettings.bitRate,
          sampleRate: entry.sampleRate > 0
              ? entry.sampleRate
              : fallbackSettings.sampleRate,
          channels: entry.channels > 0
              ? entry.channels
              : fallbackSettings.channels,
        );
        await registerOutput(
          path: output,
          title: title,
          format: format,
          markers: entry.markers,
        );
        successes++;

        if (exportDirectory != null) {
          try {
            await external.copyFileToDirectoryCollisionSafe(
              sourcePath: output,
              directoryPath: exportDirectory,
            );
            externalCopies++;
          } catch (error) {
            exportFailures.add(
              BatchConversionIssue(title: entry.title, error: error),
            );
          }
        }
      } catch (error) {
        if (output != null) {
          try {
            if (await storage.isManagedAudioPath(
              output,
              includeTrash: false,
            )) {
              await storage.deleteManagedAudioIfExists(output);
            }
          } catch (_) {
            // Rollback cleanup is best effort. Preserve the conversion or
            // registration failure as the per-file result and continue.
          }
        }
        conversionFailures.add(
          BatchConversionIssue(title: entry.title, error: error),
        );
      } finally {
        completed++;
        onProgress?.call(completed, entries.length);
      }

      if (shouldStop?.call() == true) {
        stopped = true;
        break;
      }
    }

    return BatchConversionResult(
      total: entries.length,
      completed: completed,
      successes: successes,
      externalCopies: externalCopies,
      conversionFailures: List.unmodifiable(conversionFailures),
      exportFailures: List.unmodifiable(exportFailures),
      stopped: stopped,
    );
  }
}
