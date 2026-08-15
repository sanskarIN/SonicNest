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
  late _MemoryMetadataStore metadata;
  final controllers = <AppController>[];

  setUp(() async {
    sandbox = await Directory.systemTemp.createTemp(
      'sonicnest-controller-recovery-test-',
    );
    documents = Directory('${sandbox.path}/documents');
    temporary = Directory('${sandbox.path}/temporary');
    await documents.create(recursive: true);
    await temporary.create(recursive: true);
    storage = StorageService(
      documentsDirectoryProvider: () async => documents,
      temporaryDirectoryProvider: () async => temporary,
    );
    metadata = _MemoryMetadataStore();
  });

  tearDown(() async {
    for (final controller in controllers.reversed) {
      controller.dispose();
    }
    controllers.clear();
    if (await sandbox.exists()) {
      await sandbox.delete(recursive: true);
    }
  });

  Future<AppController> createController() async {
    final processor = _RecoveryProcessor(storage);
    final controller = AppController(
      storage: storage,
      metadata: metadata,
      settingsService: _MemorySettingsService(),
      recorder: _NoopRecorderService(storage, processor),
      player: _RecoveryPlayerService(),
      processor: processor,
      external: ExternalActions(),
    );
    controllers.add(controller);
    await controller.initialize();
    expect(controller.errorMessage, isNull);
    expect(controller.initialized, isTrue);
    return controller;
  }

  Future<File> activeFile(String title, String extension) async {
    final path = await storage.uniqueRecordingPath(title, extension);
    final file = File(path);
    await file.writeAsBytes(const [1, 2, 3, 4], flush: true);
    return file;
  }

  Future<File> trashFile(String title, String extension) async {
    final path = await storage.uniqueTrashPath(title, extension);
    final file = File(path);
    await file.writeAsBytes(const [4, 3, 2, 1], flush: true);
    return file;
  }

  test('startup drops unsafe metadata and recovers active and Trash orphans', () async {
    final indexed = await activeFile('Indexed', 'wav');
    final indexedTrash = await trashFile('Indexed Trash', 'm4a');
    final activeOrphan = await activeFile('Active Orphan', 'mp3');
    final trashOrphan = await trashFile('Trash Orphan', 'flac');
    final unsupported = File('${(await storage.recordingsDirectory).path}/notes.txt');
    await unsupported.writeAsString('not an audio recording', flush: true);
    final external = File('${sandbox.path}/outside.wav');
    await external.writeAsBytes(const [9, 9, 9], flush: true);
    final missingPath = await storage.uniqueRecordingPath('Missing', 'wav');

    final now = DateTime.utc(2026, 8, 15, 12);
    metadata.entries = [
      _entry('indexed', indexed.path, RecordingFormat.wav, now),
      _entry(
        'indexed-trash',
        indexedTrash.path,
        RecordingFormat.m4a,
        now,
        trashedAt: now,
      ),
      _entry('external', external.path, RecordingFormat.wav, now),
      _entry('unsupported', unsupported.path, RecordingFormat.wav, now),
      _entry('missing', missingPath, RecordingFormat.wav, now),
    ];

    final controller = await createController();

    expect(controller.recordings, hasLength(4));
    expect(controller.recordings.map((entry) => entry.id), containsAll(['indexed', 'indexed-trash']));
    expect(controller.recordings.any((entry) => entry.filePath == external.path), isFalse);
    expect(controller.recordings.any((entry) => entry.filePath == unsupported.path), isFalse);
    expect(controller.recordings.any((entry) => entry.filePath == missingPath), isFalse);
    expect(await external.exists(), isTrue);
    expect(await unsupported.exists(), isTrue);

    final recoveredActive = controller.recordings.singleWhere(
      (entry) => entry.filePath == activeOrphan.path,
    );
    expect(recoveredActive.tags, contains('Recovered'));
    expect(recoveredActive.isTrashed, isFalse);
    expect(recoveredActive.durationMs, 1500);
    expect(recoveredActive.waveform, [0.0, 0.5, 1.0]);

    final recoveredTrash = controller.recordings.singleWhere(
      (entry) => entry.filePath == trashOrphan.path,
    );
    expect(recoveredTrash.tags, contains('Recovered'));
    expect(recoveredTrash.isTrashed, isTrue);
    expect(recoveredTrash.trashedAt, isNotNull);

    expect(metadata.savedSnapshots, hasLength(2));
    expect(metadata.savedSnapshots.first, hasLength(2));
    expect(metadata.savedSnapshots.last, hasLength(4));
  });

  test('restart does not create duplicate recovered entries', () async {
    final activeOrphan = await activeFile('Restart Orphan', 'opus');
    final trashOrphan = await trashFile('Restart Trash', 'aac');

    final first = await createController();
    expect(first.recordings, hasLength(2));
    expect(
      first.recordings.map((entry) => entry.filePath).toSet(),
      {activeOrphan.path, trashOrphan.path},
    );
    final firstIds = first.recordings.map((entry) => entry.id).toSet();
    final savesAfterFirstStartup = metadata.savedSnapshots.length;

    final second = await createController();

    expect(second.recordings, hasLength(2));
    expect(second.recordings.map((entry) => entry.id).toSet(), firstIds);
    expect(metadata.savedSnapshots.length, savesAfterFirstStartup);
  });
}

RecordingEntry _entry(
  String id,
  String path,
  RecordingFormat format,
  DateTime now, {
  DateTime? trashedAt,
}) {
  return RecordingEntry(
    id: id,
    title: id,
    filePath: path,
    durationMs: 100,
    sizeBytes: 4,
    format: format,
    bitRate: 0,
    sampleRate: 0,
    channels: 0,
    createdAt: now,
    modifiedAt: now,
    trashedAt: trashedAt,
  );
}

class _MemoryMetadataStore extends MetadataStore {
  _MemoryMetadataStore()
    : super(supportDirectoryProvider: () async => Directory.systemTemp);

  List<RecordingEntry> entries = [];
  final List<List<RecordingEntry>> savedSnapshots = [];

  @override
  Future<List<RecordingEntry>> load() async => List.of(entries);

  @override
  Future<void> save(List<RecordingEntry> entries) async {
    this.entries = List.of(entries);
    savedSnapshots.add(List.of(entries));
  }
}

class _MemorySettingsService extends SettingsService {
  @override
  Future<SettingsSnapshot> load() async => SettingsSnapshot.defaults();

  @override
  Future<void> save(SettingsSnapshot snapshot) async {}
}

class _RecoveryPlayerService extends PlayerService {
  @override
  Future<Duration> probeDuration(String path) async {
    return const Duration(milliseconds: 1500);
  }

  @override
  void dispose() {}
}

class _RecoveryProcessor extends AudioProcessor {
  _RecoveryProcessor(super.storage);

  @override
  Future<List<double>> extractWaveformEnvelope(
    String inputPath, {
    int points = 160,
  }) async {
    return const [0.0, 0.5, 1.0];
  }
}

class _NoopRecorderService extends RecorderService {
  _NoopRecorderService(StorageService storage, AudioProcessor processor)
    : super(storage, processor, BackgroundServiceBridge());

  @override
  void dispose() {}
}
