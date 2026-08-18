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

    test('protects Windows reserved device names with suffixes', () {
      expect(sanitizeFileStem('CON.notes'), '_CON.notes');
      expect(sanitizeFileStem('com1.session'), '_com1.session');
      expect(sanitizeFileStem('LPT9.archive'), '_LPT9.archive');
    });

    test('uses a safe fallback for empty names', () {
      expect(sanitizeFileStem('   ...   '), 'Recording');
    });

    test('sanitizes a caller-provided fallback too', () {
      expect(sanitizeFileStem('...', fallback: 'CON'), '_CON');
      expect(sanitizeFileStem('...', fallback: '...'), 'Recording');
    });

    test('caps very long ASCII names', () {
      final longName = List<String>.filled(300, 'a').join();
      expect(sanitizeFileStem(longName).runes.length, 120);
    });

    test('caps Unicode names without splitting surrogate pairs', () {
      final longName = List<String>.filled(121, '🎙️').join();
      final result = sanitizeFileStem(longName);

      expect(result.runes.length, 120);
      expect(result.contains('\uFFFD'), isFalse);
      expect(result.runes.every((rune) => rune != 0xD83C && rune != 0xDFA4), isTrue);
    });

    test('keeps Unicode recording names intact when below the cap', () {
      expect(
        sanitizeFileStem('हिंदी बैठक 🎙️ 你好'),
        'हिंदी बैठक 🎙️ 你好',
      );
    });
  });

  test('replaceExtension preserves the stem', () {
    expect(
      replaceExtension('/tmp/My Recording.wav', 'mp3'),
      '/tmp/My Recording.mp3',
    );
  });
}
