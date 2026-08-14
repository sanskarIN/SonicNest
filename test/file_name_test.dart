import 'package:flutter_test/flutter_test.dart';
import 'package:sonic_nest/core/file_name.dart';

void main() {
  group('sanitizeFileStem', () {
    test('removes characters unsafe on common filesystems', () {
      expect(
        sanitizeFileStem('Lecture: AI/ML? <final>'),
        'Lecture_ AI_ML_ _final_',
      );
    });

    test('protects Windows reserved names', () {
      expect(sanitizeFileStem('CON'), '_CON');
      expect(sanitizeFileStem('lpt1'), '_lpt1');
    });

    test('uses a safe fallback for empty names', () {
      expect(sanitizeFileStem('   ...   '), 'Recording');
    });

    test('caps very long names', () {
      final longName = List<String>.filled(300, 'a').join();
      expect(sanitizeFileStem(longName).length, 120);
    });
  });

  test('replaceExtension preserves the stem', () {
    expect(
      replaceExtension('/tmp/My Recording.wav', 'mp3'),
      '/tmp/My Recording.mp3',
    );
  });
}
