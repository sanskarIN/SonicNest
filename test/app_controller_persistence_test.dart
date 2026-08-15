import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sonic_nest/controllers/app_controller.dart';
import 'package:sonic_nest/models/recording_entry.dart';
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
  late StorageService storage;
  late FakeMetadataStore metadata;
  late FakeSettingsService settingsService;
  late AppController controller;
  var controllerInitialized = false;

  setUp(() async {
    sandbox = await Directory.systemTemp.createTemp(
      'sonicnest-controller-persistence-test-',
    );
    documents = Directory('${sandbox.path}/documents');
    temporary = Directory('${sandbox.path}/temporary');
    await documents.create(recursive: true);
    await temporary.create(recursive: true);
    storage = StorageService(
      documentsDirectoryProvider: () async => documents,
      temporaryDirectoryProvider: () async => temporary,
    );
    metadata = FakeMetadataStore();
    settingsService = FakeSettingsService();
  });

  tearDown(() async {
    if (controllerInitialized) {
      controller.dispose();
      controllerInitialized = false;
    }
    if (await sandbox.exists()) {
      await sandbox.delete(recursive: true);
    }
  });

  Future<AppController> createController({
    StorageService? storageOverride,
    List<RecordingEntry> entries = const [],
    RecorderService Function(StorageService storage, AudioProcessor processor)?
    recorderFactory,
  }) async {
    final selectedStorage = storageOverride ?? storage;
    metadata.entries = List.of(entries);
    final processor = AudioProcessor(selectedStorage);
    final recorder = recorderFactory?.call(selectedStorage, processor) ??
        RecorderService(
          selectedStorage,
          processor,
          BackgroundServiceBridge(),
        );
    controller = AppController(
      storage: selectedStorage,
      metadata: metadata,
      settingsService: settingsService,
      recorder: recorder,
      player: PlayerService(),
      processor: processor,
      external: ExternalActions(),
    );
    controllerInitialized = true;
    await controller.initialize();
    expect(controller.errorMessage, isNull);
    expect(controller.initialized, isTrue);
    return controller;
  }

  Future<RecordingEntry> createActiveEntry(
    String id, {
    StorageService? storageOverride,
  }) async {
    final selectedStorage = storageOverride ?? storage;
    final path = await selectedStorage.uniqueRecordingPath(id, 'wav');
    final file = File(path);
    await file.writeAsBytes(const [1, 2, 3, 4], flush: true);
    return _entry(id: id, path: file.path);
  }

  Future<RecordingEntry> createTrashedEntry(String id) async {
    final path = await storage.uniqueTrashPath(id, 'wav');
    final file = File(path);
    await file.writeAsBytes(const [5, 6, 7, 8], flush: true);
    return _entry(
      id: id,
      path: file.path,
      trashedAt: DateTime.utc(2026, 8, 15),
    );
  }

  test('single metadata edit rolls back when persistence fails', () async {
    final entry = await createActiveEntry('favorite');
    final app = await createController(entries: [entry]);
    metadata.failSaves = true;

    await expectLater(
      app.toggleFavorite(app.recordings.single),
      throwsA(isA<FileSystemException>()),
    );

    expect(app.recordings.single.favorite, isFalse);
    expect(app.recordings.single.id, entry.id);
  });

  test('batch metadata edit rolls every target back on save failure', () async {
    final first = await createActiveEntry('first');
    final second = await createActiveEntry('second');
    final app = await createController(entries: [first, second]);
    metadata.failSaves = true;

    await expectLater(
      app.setFavoriteForEntries(app.recordings, true),
      throwsA(isA<FileSystemException>()),
    );

    expect(app.recordings, hasLength(2));
    expect(app.recordings.every((entry) => !entry.favorite), isTrue);
  });

  test('stopped recording stays on disk when metadata save fails', () async {
    final path = await storage.uniqueRecordingPath('Stopped', 'wav');
    final file = File(path);
    final result = RecorderResult(
      path: path,
      title: 'Stopped',
      duration: const Duration(seconds: 2),
      settings: RecordingSettings.defaults(),
      waveform: const [0.0, 0.5, 1.0],
      markers: const [],
    );
    final app = await createController(
      recorderFactory: (storage, processor) =>
          FakeStopRecorderService(storage, processor, result),
    );

    // The completed file must appear after startup. Creating it before
    // initialize() would intentionally exercise orphan recovery instead of
    // stop-time metadata rollback.
    await file.writeAsBytes(const [9, 8, 7, 6], flush: true);
    metadata.failSaves = true;

    await expectLater(
      app.stopRecording(),
      throwsA(isA<FileSystemException>()),
    );

    expect(app.recordings, isEmpty);
    expect(app.selectedRecording, isNull);
    expect(await file.exists(), isTrue);
    expect(
      await storage.isManagedAudioPath(file.path, includeTrash: false),
      isTrue,
    );
  });

  test('rename restores original file and metadata when save fails', () async {
    final entry = await createActiveEntry('original');
    final originalPath = entry.filePath;
    final app = await createController(entries: [entry]);
    metadata.failSaves = true;

    await expectLater(
      app.renameRecording(app.recordings.single, 'Renamed'),
      throwsA(isA<FileSystemException>()),
    );

    expect(await File(originalPath).exists(), isTrue);
    expect(app.recordings.single.filePath, originalPath);
    expect(app.recordings.single.title, 'original');
    final directory = await storage.recordingsDirectory;
    expect(
      directory
          .listSync()
          .whereType<File>()
          .where((file) => file.path != originalPath),
      isEmpty,
    );
  });

  test('move to Trash restores original file when metadata save fails', () async {
    final entry = await createActiveEntry('trash-rollback');
    final originalPath = entry.filePath;
    final app = await createController(entries: [entry]);
    metadata.failSaves = true;

    await expectLater(
      app.moveToTrash(app.recordings.single),
      throwsA(isA<FileSystemException>()),
    );

    expect(await File(originalPath).exists(), isTrue);
    expect(app.recordings.single.filePath, originalPath);
    expect(app.recordings.single.isTrashed, isFalse);
    expect((await storage.trashDirectory).listSync(), isEmpty);
  });

  test('restore returns file to Trash when metadata save fails', () async {
    final entry = await createTrashedEntry('restore-rollback');
    final trashPath = entry.filePath;
    final app = await createController(entries: [entry]);
    metadata.failSaves = true;

    await expectLater(
      app.restore(app.recordings.single),
      throwsA(isA<FileSystemException>()),
    );

    expect(await File(trashPath).exists(), isTrue);
    expect(app.recordings.single.filePath, trashPath);
    expect(app.recordings.single.isTrashed, isTrue);
    expect((await storage.recordingsDirectory).listSync(), isEmpty);
  });

  test('permanent delete never removes file if metadata removal fails', () async {
    final entry = await createActiveEntry('delete-save-failure');
    final app = await createController(entries: [entry]);
    metadata.failSaves = true;

    await expectLater(
      app.permanentlyDelete(app.recordings.single),
      throwsA(isA<FileSystemException>()),
    );

    expect(await File(entry.filePath).exists(), isTrue);
    expect(app.recordings.map((item) => item.id), [entry.id]);
  });

  test('failed managed file deletion restores persisted metadata', () async {
    final guardedStorage = FailingDeleteStorageService(
      documentsDirectoryProvider: () async => documents,
      temporaryDirectoryProvider: () async => temporary,
    );
    final entry = await createActiveEntry(
      'delete-file-failure',
      storageOverride: guardedStorage,
    );
    final app = await createController(
      storageOverride: guardedStorage,
      entries: [entry],
    );
    metadata.savedSnapshots.clear();

    await expectLater(
      app.permanentlyDelete(app.recordings.single),
      throwsA(isA<FileSystemException>()),
    );

    expect(await File(entry.filePath).exists(), isTrue);
    expect(app.recordings.map((item) => item.id), [entry.id]);
    expect(metadata.savedSnapshots, hasLength(2));
    expect(metadata.savedSnapshots.first, isEmpty);
    expect(metadata.savedSnapshots.last.map((item) => item.id), [entry.id]);
  });

  test('settings snapshot rolls back when settings persistence fails', () async {
    final app = await createController();
    final original = app.settings;
    final changed = original.copyWith(defaultPlaybackSpeed: 1.75);
    settingsService.failSaves = true;

    await expectLater(
      app.updateSettings(changed),
      throwsA(isA<FileSystemException>()),
    );

    expect(app.settings.defaultPlaybackSpeed, original.defaultPlaybackSpeed);
    expect(app.settings.themeMode, original.themeMode);
  });
}

RecordingEntry _entry({
  required String id,
  required String path,
  DateTime? trashedAt,
}) {
  final now = DateTime.utc(2026, 8, 15, 10);
  return RecordingEntry(
    id: id,
    title: id,
    filePath: path,
    durationMs: 1000,
    sizeBytes: 4,
    format: RecordingFormat.wav,
    bitRate: 0,
    sampleRate: 48000,
    channels: 1,
    createdAt: now,
    modifiedAt: now,
    trashedAt: trashedAt,
  );
}

class FakeMetadataStore extends MetadataStore {
  FakeMetadataStore()
    : super(supportDirectoryProvider: () async => Directory.systemTemp);

  List<RecordingEntry> entries = [];
  bool failSaves = false;
  final List<List<RecordingEntry>> savedSnapshots = [];

  @override
  Future<List<RecordingEntry>> load() async => List.of(entries);

  @override
  Future<void> save(List<RecordingEntry> entries) async {
    if (failSaves) {
      throw const FileSystemException('Injected metadata persistence failure.');
    }
    savedSnapshots.add(List.of(entries));
  }
}

class FakeSettingsService extends SettingsService {
  SettingsSnapshot snapshot = SettingsSnapshot.defaults();
  bool failSaves = false;

  @override
  Future<SettingsSnapshot> load() async => snapshot;

  @override
  Future<void> save(SettingsSnapshot snapshot) async {
    if (failSaves) {
      throw const FileSystemException('Injected settings persistence failure.');
    }
    this.snapshot = snapshot;
  }
}

class FailingDeleteStorageService extends StorageService {
  FailingDeleteStorageService({
    required super.documentsDirectoryProvider,
    required super.temporaryDirectoryProvider,
  });

  @override
  Future<void> deleteManagedAudioIfExists(String path) async {
    throw FileSystemException('Injected managed file deletion failure.', path);
  }
}

class FakeStopRecorderService extends RecorderService {
  FakeStopRecorderService(
    StorageService storage,
    AudioProcessor processor,
    this.result,
  ) : super(storage, processor, BackgroundServiceBridge());

  final RecorderResult result;

  @override
  Future<RecorderResult> stop() async => result;
}
