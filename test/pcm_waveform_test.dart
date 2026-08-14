import 'package:flutter_test/flutter_test.dart';
import 'package:sonic_nest/core/pcm_waveform.dart';

void main() {
  group('pcm16LePeak', () {
    test('returns zero for silence and empty input', () {
      expect(pcm16LePeak(const []), 0);
      expect(pcm16LePeak(const [0, 0, 0, 0]), 0);
    });

    test('normalizes positive full-scale PCM', () {
      expect(pcm16LePeak(const [0xff, 0x7f]), closeTo(32767 / 32768, 0.00001));
    });

    test('normalizes negative full-scale PCM', () {
      expect(pcm16LePeak(const [0x00, 0x80]), 1.0);
    });

    test('uses the largest absolute sample', () {
      final peak = pcm16LePeak(const [0xe8, 0x03, 0x30, 0xf8, 0x10, 0x27]);
      expect(peak, closeTo(10000 / 32768, 0.00001));
    });

    test('ignores an incomplete trailing byte', () {
      expect(pcm16LePeak(const [0x00, 0x40, 0xff]), 0.5);
    });
  });
}
