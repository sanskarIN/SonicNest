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

    test('uses numbered names instead of overwriting an existing file', () async {
      final source = File(p.join(root.path, 'lecture.mp3'));
      await source.writeAsBytes([7, 8, 9]);
      await File(p.join(destination.path, 'lecture.mp3')).writeAsBytes([1]);
      await File(p.join(destination.path, 'lecture (2).mp3')).writeAsBytes([2]);

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
    });

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
}
