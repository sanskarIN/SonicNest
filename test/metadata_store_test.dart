import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sonic_nest/models/recording_entry.dart';
import 'package:sonic_nest/models/recording_settings.dart';
import 'package:sonic_nest/services/metadata_store.dart';

void main() {
  late Directory supportDirectory;
  late File metadataFile;
  final fixedClock = DateTime.utc(2026, 8, 14, 12, 30);

  setUp(() async {
    supportDirectory = await Directory.systemTemp.createTemp(
      'sonicnest-metadata-test-',
    );
    metadataFile = File(
      p.join(supportDirectory.path, 'SonicNest', 'recordings.json'),
    );
  });

  tearDown(() async {
    if (await supportDirectory.exists()) {
      await supportDirectory.delete(recursive: true);
    }
  });

  MetadataStore createStore() => MetadataStore(
    supportDirectoryProvider: () async => supportDirectory,
    clock: () => fixedClock,
  );

  test('invalid JSON is preserved and reset to a valid empty store', () async {
    await metadataFile.parent.create(recursive: true);
    await metadataFile.writeAsString('{not-json');

    final entries = await createStore().load();

    expect(entries, isEmpty);
    final backup = File(
      '${metadataFile.path}.corrupt.${fixedClock.millisecondsSinceEpoch}',
    );
    expect(await backup.exists(), isTrue);
    expect(await backup.readAsString(), '{not-json');

    final resetDocument = jsonDecode(await metadataFile.readAsString()) as Map;
    expect(resetDocument['recordings'], isEmpty);
    expect(await File('${metadataFile.path}.bak').exists(), isFalse);
    expect(await File('${metadataFile.path}.tmp').exists(), isFalse);
  });

  test(
    'corrupt primary is not copied repeatedly after recovery reset',
    () async {
      await metadataFile.parent.create(recursive: true);
      await metadataFile.writeAsString('{not-json');
      final store = createStore();

      await store.load();
      await store.load();

      final corruptCopies = metadataFile.parent
          .listSync()
          .whereType<File>()
          .where((file) => p.basename(file.path).contains('.corrupt.'))
          .toList(growable: false);
      expect(corruptCopies, hasLength(1));
    },
  );

  test(
    'structurally invalid recordings payload is preserved then reset',
    () async {
      await metadataFile.parent.create(recursive: true);
      await metadataFile.writeAsString(
        jsonEncode(<String, Object>{
          'schemaVersion': 1,
          'recordings': 'not-a-list',
        }),
      );

      final entries = await createStore().load();

      expect(entries, isEmpty);
      final backup = File(
        '${metadataFile.path}.corrupt.${fixedClock.millisecondsSinceEpoch}',
      );
      expect(await backup.exists(), isTrue);
      final resetDocument =
          jsonDecode(await metadataFile.readAsString()) as Map;
      expect(resetDocument['recordings'], isEmpty);
    },
  );

  test('one malformed record cannot hide valid library entries', () async {
    await metadataFile.parent.create(recursive: true);
    final valid = _entry(1).toJson();
    await metadataFile.writeAsString(
      jsonEncode(<String, Object>{
        'schemaVersion': 1,
        'recordings': <Object?>[
          valid,
          'not-a-record',
          <String, Object?>{'id': 44, 'filePath': false, 'tags': 'not-a-list'},
          <String, Object?>{
            'id': 'second-valid',
            'filePath': '/audio/second.wav',
            'title': 77,
            'durationMs': 'bad',
            'markers': <Object?>[
              <String, Object?>{'positionMs': 'bad', 'label': 12},
            ],
          },
        ],
      }),
    );

    final entries = await createStore().load();

    expect(entries, hasLength(2));
    expect(entries.map((entry) => entry.id), ['recording-1', 'second-valid']);
    expect(entries.last.title, 'Recording');
    expect(entries.last.durationMs, 0);
    expect(entries.last.markers.single.label, 'Marker');
  });

  test(
    'duplicate ids and duplicate file paths keep only first records',
    () async {
      await metadataFile.parent.create(recursive: true);
      final first = _entry(1).toJson();
      final duplicateId = _entry(2).toJson()..['id'] = 'recording-1';
      final duplicatePath = _entry(3).toJson()
        ..['filePath'] = '/audio/recording-1.wav';
      await metadataFile.writeAsString(
        jsonEncode(<String, Object>{
          'schemaVersion': 1,
          'recordings': <Object>[
            first,
            duplicateId,
            duplicatePath,
            _entry(4).toJson(),
          ],
        }),
      );

      final entries = await createStore().load();

      expect(entries.map((entry) => entry.id), ['recording-1', 'recording-4']);
      expect(entries.map((entry) => entry.filePath), [
        '/audio/recording-1.wav',
        '/audio/recording-4.wav',
      ]);
    },
  );

  test('missing primary metadata recovers an interrupted backup', () async {
    final store = createStore();
    await store.save([_entry(7)]);
    final backup = File('${metadataFile.path}.bak');
    await metadataFile.rename(backup.path);

    final restored = await createStore().load();

    expect(restored, hasLength(1));
    expect(restored.single.id, 'recording-7');
    expect(await metadataFile.exists(), isTrue);
    expect(await backup.exists(), isFalse);
  });

  test('corrupt primary metadata falls back to a valid backup', () async {
    final store = createStore();
    await store.save([_entry(9)]);
    final backup = File('${metadataFile.path}.bak');
    await metadataFile.copy(backup.path);
    await metadataFile.writeAsString('{broken-primary');

    final restored = await createStore().load();

    expect(restored, hasLength(1));
    expect(restored.single.id, 'recording-9');
    expect(await backup.exists(), isFalse);
    expect(jsonDecode(await metadataFile.readAsString()), isA<Map>());
    final corruptCopy = File(
      '${metadataFile.path}.corrupt.${fixedClock.millisecondsSinceEpoch}',
    );
    expect(await corruptCopy.exists(), isTrue);
    expect(await corruptCopy.readAsString(), '{broken-primary');
  });

  test('corrupt primary and backup are both preserved before reset', () async {
    await metadataFile.parent.create(recursive: true);
    await metadataFile.writeAsString('{broken-primary');
    final backup = File('${metadataFile.path}.bak');
    await backup.writeAsString('{broken-backup');

    final restored = await createStore().load();

    expect(restored, isEmpty);
    final firstCorrupt = File(
      '${metadataFile.path}.corrupt.${fixedClock.millisecondsSinceEpoch}',
    );
    final secondCorrupt = File(
      '${metadataFile.path}.bak.corrupt.${fixedClock.millisecondsSinceEpoch}',
    );
    expect(await firstCorrupt.readAsString(), '{broken-primary');
    expect(await secondCorrupt.readAsString(), '{broken-backup');
    expect(await backup.exists(), isFalse);
    final resetDocument = jsonDecode(await metadataFile.readAsString()) as Map;
    expect(resetDocument['recordings'], isEmpty);
  });

  test('unsupported metadata schema is preserved without rewrite', () async {
    await metadataFile.parent.create(recursive: true);
    final original = jsonEncode(<String, Object>{
      'schemaVersion': 999,
      'recordings': <Object>[_entry(5).toJson()],
    });
    await metadataFile.writeAsString(original);

    await expectLater(
      createStore().load(),
      throwsA(isA<UnsupportedMetadataSchemaException>()),
    );

    expect(await metadataFile.readAsString(), original);
    expect(await File('${metadataFile.path}.bak').exists(), isFalse);
    expect(
      metadataFile.parent.listSync().whereType<File>().where(
        (file) => p.basename(file.path).contains('.corrupt.'),
      ),
      isEmpty,
    );
  });

  test('malformed metadata schema type is preserved then reset', () async {
    await metadataFile.parent.create(recursive: true);
    await metadataFile.writeAsString(
      jsonEncode(<String, Object>{
        'schemaVersion': '1',
        'recordings': <Object>[_entry(6).toJson()],
      }),
    );

    final entries = await createStore().load();

    expect(entries, isEmpty);
    final corruptCopy = File(
      '${metadataFile.path}.corrupt.${fixedClock.millisecondsSinceEpoch}',
    );
    expect(await corruptCopy.exists(), isTrue);
    final reset = jsonDecode(await metadataFile.readAsString()) as Map;
    expect(reset['schemaVersion'], 1);
    expect(reset['recordings'], isEmpty);
  });

  test('save and load roundtrip supports thousands of entries', () async {
    const entryCount = 3000;
    final original = List<RecordingEntry>.generate(
      entryCount,
      (index) => _entry(index),
      growable: false,
    );
    final store = createStore();

    await store.save(original);
    final restored = await store.load();

    expect(restored, hasLength(entryCount));
    expect(restored.first.id, 'recording-0');
    expect(restored[1499].id, 'recording-1499');
    expect(restored.last.id, 'recording-2999');
    expect(restored.last.title, 'Recording 2999');
    expect(await metadataFile.exists(), isTrue);
    expect(await File('${metadataFile.path}.bak').exists(), isFalse);
    expect(await File('${metadataFile.path}.tmp').exists(), isFalse);
  });
}

RecordingEntry _entry(int index) {
  final createdAt = DateTime.utc(2026, 8, 14).add(Duration(seconds: index));
  return RecordingEntry(
    id: 'recording-$index',
    title: 'Recording $index',
    filePath: '/audio/recording-$index.wav',
    durationMs: 1000 + index,
    sizeBytes: 4096 + index,
    format: RecordingFormat.wav,
    bitRate: 0,
    sampleRate: 48000,
    channels: 1,
    createdAt: createdAt,
    modifiedAt: createdAt,
    tags: index.isEven ? const ['test', 'even'] : const ['test'],
    waveform: const [0.0, 0.25, 0.5, 0.25, 0.0],
  );
}
