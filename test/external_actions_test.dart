import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sonic_nest/services/external_actions.dart';

void main() {
  group('ExternalActions.copyFileToDirectoryCollisionSafe', () {
    late Directory root;
    late Directory destination;
    late ExternalActions actions;

    setUp(() async {
      root = await Directory.systemTemp.createTemp('sonicnest_external_copy_');
      destination = await Directory(p.join(root.path, 'exports')).create();
      actions = ExternalActions();
    });

    tearDown(() async {
      if (await root.exists()) {
        await root.delete(recursive: true);
      }
    });

    test('copies a file using its original basename', () async {
      final source = File(p.join(root.path, 'meeting.wav'));
      await source.writeAsBytes([1, 2, 3, 4]);

      final copiedPath = await actions.copyFileToDirectoryCollisionSafe(
        sourcePath: source.path,
        directoryPath: destination.path,
      );

      expect(p.basename(copiedPath), 'meeting.wav');
      expect(await File(copiedPath).readAsBytes(), [1, 2, 3, 4]);
      expect(await source.readAsBytes(), [1, 2, 3, 4]);
    });

    test(
      'uses numbered names instead of overwriting an existing file',
      () async {
        final source = File(p.join(root.path, 'lecture.mp3'));
        await source.writeAsBytes([7, 8, 9]);
        await File(p.join(destination.path, 'lecture.mp3')).writeAsBytes([1]);
        await File(p.join(destination.path, 'lecture (2).mp3'))
            .writeAsBytes([2]);

        final copiedPath = await actions.copyFileToDirectoryCollisionSafe(
          sourcePath: source.path,
          directoryPath: destination.path,
        );

        expect(p.basename(copiedPath), 'lecture (3).mp3');
        expect(await File(copiedPath).readAsBytes(), [7, 8, 9]);
        expect(
          await File(p.join(destination.path, 'lecture.mp3')).readAsBytes(),
          [1],
        );
        expect(
          await File(p.join(destination.path, 'lecture (2).mp3')).readAsBytes(),
          [2],
        );
      },
    );

    test(
      'uses a numbered name when a directory occupies the basename',
      () async {
        final source = File(p.join(root.path, 'session.wav'));
        await source.writeAsBytes([1, 4, 9]);
        final occupied = Directory(p.join(destination.path, 'session.wav'));
        await occupied.create();

        final copiedPath = await actions.copyFileToDirectoryCollisionSafe(
          sourcePath: source.path,
          directoryPath: destination.path,
        );

        expect(p.basename(copiedPath), 'session (2).wav');
        expect(await occupied.exists(), isTrue);
        expect(await File(copiedPath).readAsBytes(), [1, 4, 9]);
      },
    );

    test(
      'uses a numbered name when a broken symbolic link occupies the basename',
      () async {
        final source = File(p.join(root.path, 'linked.wav'));
        await source.writeAsBytes([2, 4, 6]);
        final reserved = p.join(destination.path, 'linked.wav');
        await Link(reserved).create(p.join(root.path, 'missing-target.wav'));

        final copiedPath = await actions.copyFileToDirectoryCollisionSafe(
          sourcePath: source.path,
          directoryPath: destination.path,
        );

        expect(p.basename(copiedPath), 'linked (2).wav');
        expect(
          await FileSystemEntity.type(reserved, followLinks: false),
          FileSystemEntityType.link,
        );
        expect(await File(copiedPath).readAsBytes(), [2, 4, 6]);
      },
      skip: Platform.isWindows,
    );

    test('rejects a missing source file', () async {
      expect(
        () => actions.copyFileToDirectoryCollisionSafe(
          sourcePath: p.join(root.path, 'missing.wav'),
          directoryPath: destination.path,
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('rejects an unavailable destination directory', () async {
      final source = File(p.join(root.path, 'voice.m4a'));
      await source.writeAsBytes([5]);

      expect(
        () => actions.copyFileToDirectoryCollisionSafe(
          sourcePath: source.path,
          directoryPath: p.join(root.path, 'gone'),
        ),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('ExternalActions.copyFilesToDirectoryCollisionSafe', () {
    late Directory root;
    late Directory destination;
    late ExternalActions actions;

    setUp(() async {
      root = await Directory.systemTemp.createTemp('sonicnest_batch_export_');
      destination = await Directory(p.join(root.path, 'exports')).create();
      actions = ExternalActions();
    });

    tearDown(() async {
      if (await root.exists()) {
        await root.delete(recursive: true);
      }
    });

    test('copies every available source and reports counts', () async {
      final first = File(p.join(root.path, 'first.wav'));
      final second = File(p.join(root.path, 'second.flac'));
      await first.writeAsBytes([1, 2]);
      await second.writeAsBytes([3, 4]);

      final result = await actions.copyFilesToDirectoryCollisionSafe(
        sourcePaths: [first.path, second.path],
        directoryPath: destination.path,
      );

      expect(result.copiedCount, 2);
      expect(result.failedCount, 0);
      expect(result.hasFailures, isFalse);
      expect(
        result.copiedPaths.map(p.basename),
        containsAll(['first.wav', 'second.flac']),
      );
    });

    test('keeps successful copies when another source is missing', () async {
      final valid = File(p.join(root.path, 'valid.m4a'));
      final missing = p.join(root.path, 'missing.m4a');
      await valid.writeAsBytes([9, 8, 7]);

      final result = await actions.copyFilesToDirectoryCollisionSafe(
        sourcePaths: [valid.path, missing],
        directoryPath: destination.path,
      );

      expect(result.copiedCount, 1);
      expect(result.failedCount, 1);
      expect(result.hasFailures, isTrue);
      expect(result.failures, contains(missing));
      expect(await File(result.copiedPaths.single).readAsBytes(), [9, 8, 7]);
    });

    test(
      'allocates collision-safe names independently across a batch',
      () async {
        final sourceOneDir = await Directory(p.join(root.path, 'one')).create();
        final sourceTwoDir = await Directory(p.join(root.path, 'two')).create();
        final first = File(p.join(sourceOneDir.path, 'voice.wav'));
        final second = File(p.join(sourceTwoDir.path, 'voice.wav'));
        await first.writeAsBytes([1]);
        await second.writeAsBytes([2]);

        final result = await actions.copyFilesToDirectoryCollisionSafe(
          sourcePaths: [first.path, second.path],
          directoryPath: destination.path,
        );

        expect(result.copiedCount, 2);
        expect(
          result.copiedPaths.map(p.basename),
          containsAll(['voice.wav', 'voice (2).wav']),
        );
        expect(
          await File(p.join(destination.path, 'voice.wav')).readAsBytes(),
          [1],
        );
        expect(
          await File(p.join(destination.path, 'voice (2).wav')).readAsBytes(),
          [2],
        );
      },
    );
  });
}
