import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sonic_nest/controllers/app_controller.dart';
import 'package:sonic_nest/models/recording_settings.dart';
import 'package:sonic_nest/services/audio_processor.dart';
import 'package:sonic_nest/services/background_service_bridge.dart';
import 'package:sonic_nest/services/external_actions.dart';
import 'package:sonic_nest/services/metadata_store.dart';
import 'package:sonic_nest/services/player_service.dart';
import 'package:sonic_nest/services/recorder_service.dart';
import 'package:sonic_nest/services/settings_service.dart';
import 'package:sonic_nest/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory sandbox;
  late Directory documents;
  late Directory temporary;
  late Directory support;
  late StorageService storage;
  late AppController controller;

  setUp(() async {
    sandbox = await Directory.systemTemp.createTemp(
      'sonicnest-output-safety-test-',
    );
    documents = Directory('${sandbox.path}/documents');
    temporary = Directory('${sandbox.path}/temporary');
    support = Directory('${sandbox.path}/support');
    await documents.create(recursive: true);
    await temporary.create(recursive: true);
    await support.create(recursive: true);

    storage = StorageService(
      documentsDirectoryProvider: () async => documents,
      temporaryDirectoryProvider: () async => temporary,
    );
    final processor = AudioProcessor(storage);
    controller = AppController(
      storage: storage,
      metadata: MetadataStore(supportDirectoryProvider: () async => support),
      settingsService: _FakeSettingsService(),
      recorder: RecorderService(
        storage,
        processor,
        BackgroundServiceBridge(),
      ),
      player: _ProbeFailurePlayerService(),
      processor: processor,
      external: ExternalActions(),
    );
    await controller.initialize();
    expect(controller.initialized, isTrue);
    expect(controller.errorMessage, isNull);
  });

  tearDown(() async {
    controller.dispose();
    if (await sandbox.exists()) {
      await sandbox.delete(recursive: true);
    }
  });

  test('failed processed registration never deletes an external path', () async {
    final external = File('${sandbox.path}/external.wav');
    await external.writeAsBytes(const [1, 2, 3, 4], flush: true);

    await expectLater(
      controller.addProcessedFile(
        external.path,
        title: 'External',
        format: RecordingFormat.wav,
      ),
      throwsA(isA<FormatException>()),
    );

    expect(await external.exists(), isTrue);
    expect(controller.recordings, isEmpty);
  });

  test('failed processed registration cleans a managed active output', () async {
    final managedPath = await storage.uniqueRecordingPath('Generated', 'wav');
    final managed = File(managedPath);
    await managed.writeAsBytes(const [5, 6, 7, 8], flush: true);

    await expectLater(
      controller.addProcessedFile(
        managed.path,
        title: 'Generated',
        format: RecordingFormat.wav,
      ),
      throwsA(isA<FormatException>()),
    );

    expect(await managed.exists(), isFalse);
    expect(controller.recordings, isEmpty);
  });
}

class _ProbeFailurePlayerService extends PlayerService {
  @override
  Future<Duration> probeDuration(String path) async {
    throw const FormatException('Injected media probe failure.');
  }
}

class _FakeSettingsService extends SettingsService {
  @override
  Future<SettingsSnapshot> load() async => SettingsSnapshot.defaults();

  @override
  Future<void> save(SettingsSnapshot snapshot) async {}
}
