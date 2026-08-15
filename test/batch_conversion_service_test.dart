import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sonic_nest/models/recording_entry.dart';
import 'package:sonic_nest/models/recording_settings.dart';
import 'package:sonic_nest/services/audio_processor.dart';
import 'package:sonic_nest/services/batch_conversion_service.dart';
import 'package:sonic_nest/services/external_actions.dart';
import 'package:sonic_nest/services/storage_service.dart';

void main() {
  late Directory sandbox;
  late Directory documents;
  late Directory temporary;
  late StorageService storage;
  late _FakeBatchProcessor processor;
  late _FakeExternalActions external;
  late BatchConversionService service;

  setUp(() async {
    sandbox = await Directory.systemTemp.createTemp(
      'sonicnest-batch-conversion-test-',
    );
    documents = Directory('${sandbox.path}/documents');
    temporary = Directory('${sandbox.path}/temporary');
    await documents.create(recursive: true);
    await temporary.create(recursive: true);
    storage = StorageService(
      documentsDirectoryProvider: () async => documents,
      temporaryDirectoryProvider: () async => temporary,
    );
    processor = _FakeBatchProcessor(storage);
    external = _FakeExternalActions();
    service = BatchConversionService(
      processor: processor,
      storage: storage,
      external: external,
    );
  });

  tearDown(() async {
    if (await sandbox.exists()) {
      await sandbox.delete(recursive: true);
    }
  });

  test('isolates one conversion failure and continues with later files', () async {
    processor.failInputs.add('/input/first.wav');
    final registered = <String>[];
    final progress = <int>[];

    final result = await service.convert(
      entries: [
        _entry('first', '/input/first.wav'),
        _entry('second', '/input/second.wav'),
      ],
      format: RecordingFormat.mp3,
      fallbackSettings: RecordingSettings.defaults(),
      registerOutput: ({
        required path,
        required title,
        required format,
        required markers,
      }) async {
        registered.add(path);
      },
      onProgress: (completed, total) => progress.add(completed),
    );

    expect(result.total, 2);
    expect(result.completed, 2);
    expect(result.successes, 1);
    expect(result.conversionFailureCount, 1);
    expect(result.conversionFailures.single.title, 'first');
    expect(result.stopped, isFalse);
    expect(registered, hasLength(1));
    expect(progress, [1, 2]);
  });

  test('registration failure removes only the generated managed output', () async {
    String? generatedPath;

    final result = await service.convert(
      entries: [_entry('voice', '/input/voice.wav')],
      format: RecordingFormat.flac,
      fallbackSettings: RecordingSettings.defaults(),
      registerOutput: ({
        required path,
        required title,
        required format,
        required markers,
      }) async {
        generatedPath = path;
        throw StateError('Injected metadata registration failure.');
      },
    );

    expect(result.successes, 0);
    expect(result.conversionFailureCount, 1);
    expect(generatedPath, isNotNull);
    expect(await File(generatedPath!).exists(), isFalse);
  });

  test('failed registration never deletes a caller-external output path', () async {
    final externalOutput = File('${sandbox.path}/external-output.mp3');
    await externalOutput.writeAsBytes(const [1, 2, 3], flush: true);
    processor.externalOutputs['/input/external.wav'] = externalOutput.path;

    final result = await service.convert(
      entries: [_entry('external', '/input/external.wav')],
      format: RecordingFormat.mp3,
      fallbackSettings: RecordingSettings.defaults(),
      registerOutput: ({
        required path,
        required title,
        required format,
        required markers,
      }) async {
        throw StateError('Injected registration failure.');
      },
    );

    expect(result.conversionFailureCount, 1);
    expect(await externalOutput.exists(), isTrue);
    expect(await externalOutput.readAsBytes(), [1, 2, 3]);
  });

  test('external-copy failure does not invalidate a registered conversion', () async {
    final registered = <String>[];
    external.failSourcesContaining.add('first MP3');

    final result = await service.convert(
      entries: [
        _entry('first', '/input/first.wav'),
        _entry('second', '/input/second.wav'),
      ],
      format: RecordingFormat.mp3,
      fallbackSettings: RecordingSettings.defaults(),
      exportDirectory: '/exports',
      registerOutput: ({
        required path,
        required title,
        required format,
        required markers,
      }) async {
        registered.add(path);
      },
    );

    expect(result.successes, 2);
    expect(result.conversionFailures, isEmpty);
    expect(result.externalCopies, 1);
    expect(result.exportFailureCount, 1);
    expect(result.exportFailures.single.title, 'first');
    expect(registered, hasLength(2));
  });

  test('stop request after progress finishes current file then stops', () async {
    var stop = false;

    final result = await service.convert(
      entries: [
        _entry('one', '/input/one.wav'),
        _entry('two', '/input/two.wav'),
        _entry('three', '/input/three.wav'),
      ],
      format: RecordingFormat.ogg,
      fallbackSettings: RecordingSettings.defaults(),
      registerOutput: ({
        required path,
        required title,
        required format,
        required markers,
      }) async {},
      shouldStop: () => stop,
      onProgress: (completed, total) {
        if (completed == 1) {
          stop = true;
        }
      },
    );

    expect(result.stopped, isTrue);
    expect(result.completed, 1);
    expect(result.successes, 1);
    expect(processor.calls, hasLength(1));
  });

  test('pre-existing stop request performs no conversion work', () async {
    final result = await service.convert(
      entries: [_entry('one', '/input/one.wav')],
      format: RecordingFormat.wav,
      fallbackSettings: RecordingSettings.defaults(),
      registerOutput: ({
        required path,
        required title,
        required format,
        required markers,
      }) async {},
      shouldStop: () => true,
    );

    expect(result.stopped, isTrue);
    expect(result.completed, 0);
    expect(result.successes, 0);
    expect(processor.calls, isEmpty);
  });

  test('source technical metadata overrides fallback conversion settings', () async {
    final source = _entry(
      'source',
      '/input/source.wav',
      bitRate: 256000,
      sampleRate: 96000,
      channels: 2,
    );

    await service.convert(
      entries: [source],
      format: RecordingFormat.flac,
      fallbackSettings: RecordingSettings.defaults(),
      registerOutput: ({
        required path,
        required title,
        required format,
        required markers,
      }) async {},
    );

    final call = processor.calls.single;
    expect(call.bitRate, 256000);
    expect(call.sampleRate, 96000);
    expect(call.channels, 2);
  });
}

RecordingEntry _entry(
  String title,
  String path, {
  int bitRate = 0,
  int sampleRate = 0,
  int channels = 0,
}) {
  final now = DateTime.utc(2026, 8, 15, 12);
  return RecordingEntry(
    id: title,
    title: title,
    filePath: path,
    durationMs: 1000,
    sizeBytes: 10,
    format: RecordingFormat.wav,
    bitRate: bitRate,
    sampleRate: sampleRate,
    channels: channels,
    createdAt: now,
    modifiedAt: now,
  );
}

class _TranscodeCall {
  const _TranscodeCall({
    required this.inputPath,
    required this.bitRate,
    required this.sampleRate,
    required this.channels,
  });

  final String inputPath;
  final int bitRate;
  final int sampleRate;
  final int channels;
}

class _FakeBatchProcessor extends AudioProcessor {
  _FakeBatchProcessor(this.storage) : super(storage);

  final StorageService storage;
  final Set<String> failInputs = {};
  final Map<String, String> externalOutputs = {};
  final List<_TranscodeCall> calls = [];

  @override
  Future<String> transcode({
    required String inputPath,
    required String outputTitle,
    required RecordingFormat format,
    required int bitRate,
    required int sampleRate,
    required int channels,
  }) async {
    calls.add(
      _TranscodeCall(
        inputPath: inputPath,
        bitRate: bitRate,
        sampleRate: sampleRate,
        channels: channels,
      ),
    );
    if (failInputs.contains(inputPath)) {
      throw const AudioProcessingException('Injected transcode failure.');
    }
    final external = externalOutputs[inputPath];
    if (external != null) {
      return external;
    }
    final path = await storage.uniqueRecordingPath(outputTitle, format.extension);
    await File(path).writeAsBytes(const [8, 6, 7, 5, 3, 0, 9], flush: true);
    return path;
  }
}

class _FakeExternalActions extends ExternalActions {
  final Set<String> failSourcesContaining = {};
  final List<String> copiedSources = [];

  @override
  Future<String> copyFileToDirectoryCollisionSafe({
    required String sourcePath,
    required String directoryPath,
  }) async {
    for (final fragment in failSourcesContaining) {
      if (sourcePath.contains(fragment)) {
        throw StateError('Injected external copy failure.');
      }
    }
    copiedSources.add(sourcePath);
    return '$directoryPath/${sourcePath.split('/').last}';
  }
}
