import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sonic_nest/models/recording_settings.dart';
import 'package:sonic_nest/services/audio_import_service.dart';
import 'package:sonic_nest/services/audio_processor.dart';
import 'package:sonic_nest/services/storage_service.dart';

void main() {
  test('valid audio import returns probed managed metadata', () async {
    final storage = _FakeStorageService(
      importedPaths: const {'/picked/voice.wav': '/managed/voice.wav'},
      sizes: const {'/managed/voice.wav': 4096},
    );
    final processor = _FakeAudioProcessor(
      storage,
      durations: const {'/managed/voice.wav': Duration(seconds: 12)},
      waveforms: const {
        '/managed/voice.wav': [0.0, 0.5, 1.0, 0.25],
      },
    );
    final service = AudioImportService(storage: storage, processor: processor);

    final result = await service.importOne('/picked/voice.wav');

    expect(result.sourcePath, '/picked/voice.wav');
    expect(result.filePath, '/managed/voice.wav');
    expect(result.title, 'voice');
    expect(result.duration, const Duration(seconds: 12));
    expect(result.sizeBytes, 4096);
    expect(result.format, RecordingFormat.wav);
    expect(result.waveform, [0.0, 0.5, 1.0, 0.25]);
    expect(storage.deletedPaths, isEmpty);
  });

  test('probe failure removes the copied managed file', () async {
    final storage = _FakeStorageService(
      importedPaths: const {'/picked/broken.mp3': '/managed/broken.mp3'},
    );
    final processor = _FakeAudioProcessor(
      storage,
      probeFailures: const {'/managed/broken.mp3'},
    );
    final service = AudioImportService(storage: storage, processor: processor);

    await expectLater(
      service.importOne('/picked/broken.mp3'),
      throwsA(
        isA<AudioImportException>()
            .having(
              (error) => error.sourcePath,
              'sourcePath',
              '/picked/broken.mp3',
            )
            .having(
              (error) => error.message,
              'message',
              contains('Could not determine audio duration'),
            ),
      ),
    );

    expect(storage.deletedPaths, ['/managed/broken.mp3']);
  });

  test('waveform failure removes the copied managed file', () async {
    final storage = _FakeStorageService(
      importedPaths: const {'/picked/broken.flac': '/managed/broken.flac'},
    );
    final processor = _FakeAudioProcessor(
      storage,
      durations: const {'/managed/broken.flac': Duration(seconds: 3)},
      waveformFailures: const {'/managed/broken.flac'},
    );
    final service = AudioImportService(storage: storage, processor: processor);

    await expectLater(
      service.importOne('/picked/broken.flac'),
      throwsA(isA<AudioImportException>()),
    );

    expect(storage.deletedPaths, ['/managed/broken.flac']);
  });

  test('copy failure is reported without deleting an unrelated path', () async {
    final storage = _FakeStorageService(
      importFailures: const {'/picked/missing.ogg'},
    );
    final processor = _FakeAudioProcessor(storage);
    final service = AudioImportService(storage: storage, processor: processor);

    await expectLater(
      service.importOne('/picked/missing.ogg'),
      throwsA(
        isA<AudioImportException>().having(
          (error) => error.sourcePath,
          'sourcePath',
          '/picked/missing.ogg',
        ),
      ),
    );

    expect(storage.deletedPaths, isEmpty);
  });

  test(
    'cleanup failure does not escape as an unstructured exception',
    () async {
      final storage = _FakeStorageService(
        importedPaths: const {'/picked/broken.wav': '/managed/broken.wav'},
        deleteFailures: const {'/managed/broken.wav'},
      );
      final processor = _FakeAudioProcessor(
        storage,
        probeFailures: const {'/managed/broken.wav'},
      );
      final service = AudioImportService(storage: storage, processor: processor);

      await expectLater(
        service.importOne('/picked/broken.wav'),
        throwsA(
          isA<AudioImportException>()
              .having(
                (error) => error.sourcePath,
                'sourcePath',
                '/picked/broken.wav',
              )
              .having(
                (error) => error.message,
                'message',
                allOf(
                  contains('Could not determine audio duration'),
                  contains('Cleanup also failed'),
                ),
              ),
        ),
      );

      expect(storage.deletedPaths, ['/managed/broken.wav']);
    },
  );
}

class _FakeStorageService extends StorageService {
  _FakeStorageService({
    this.importedPaths = const {},
    this.sizes = const {},
    this.importFailures = const {},
    this.deleteFailures = const {},
  });

  final Map<String, String> importedPaths;
  final Map<String, int> sizes;
  final Set<String> importFailures;
  final Set<String> deleteFailures;
  final List<String> deletedPaths = [];

  @override
  Future<String> importFile(String sourcePath) async {
    if (importFailures.contains(sourcePath)) {
      throw FileSystemException('Selected audio file no longer exists.');
    }
    return importedPaths[sourcePath] ?? sourcePath;
  }

  @override
  Future<int> fileSize(String path) async => sizes[path] ?? 0;

  @override
  Future<void> deleteManagedAudioIfExists(String path) async {
    deletedPaths.add(path);
    if (deleteFailures.contains(path)) {
      throw FileSystemException('Injected cleanup failure.', path);
    }
  }
}

class _FakeAudioProcessor extends AudioProcessor {
  _FakeAudioProcessor(
    super.storage, {
    this.durations = const {},
    this.waveforms = const {},
    this.probeFailures = const {},
    this.waveformFailures = const {},
  });

  final Map<String, Duration> durations;
  final Map<String, List<double>> waveforms;
  final Set<String> probeFailures;
  final Set<String> waveformFailures;

  @override
  Future<Duration> probeDuration(String inputPath) async {
    if (probeFailures.contains(inputPath)) {
      throw const AudioProcessingException(
        'Could not determine audio duration.',
      );
    }
    return durations[inputPath] ?? Duration.zero;
  }

  @override
  Future<List<double>> extractWaveformEnvelope(
    String inputPath, {
    int points = 720,
  }) async {
    if (waveformFailures.contains(inputPath)) {
      throw const AudioProcessingException('Waveform extraction failed.');
    }
    return waveforms[inputPath] ?? const [];
  }
}
