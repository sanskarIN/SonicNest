import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sonic_nest/core/wav_encoder.dart';

void main() {
  test('pcm16ToWav writes a valid mono PCM header and payload', () {
    final pcm = Uint8List.fromList(<int>[0x00, 0x00, 0xFF, 0x7F]);
    final wav = pcm16ToWav(pcm, sampleRate: 44100, channels: 1);
    final header = ByteData.sublistView(wav);

    expect(String.fromCharCodes(wav.sublist(0, 4)), 'RIFF');
    expect(header.getUint32(4, Endian.little), 40);
    expect(String.fromCharCodes(wav.sublist(8, 12)), 'WAVE');
    expect(String.fromCharCodes(wav.sublist(12, 16)), 'fmt ');
    expect(header.getUint16(20, Endian.little), 1);
    expect(header.getUint16(22, Endian.little), 1);
    expect(header.getUint32(24, Endian.little), 44100);
    expect(header.getUint32(28, Endian.little), 88200);
    expect(header.getUint16(32, Endian.little), 2);
    expect(header.getUint16(34, Endian.little), 16);
    expect(String.fromCharCodes(wav.sublist(36, 40)), 'data');
    expect(header.getUint32(40, Endian.little), pcm.length);
    expect(wav.sublist(44), pcm);
  });

  test('pcm16ToWav writes stereo byte rate and block alignment', () {
    final wav = pcm16ToWav(
      Uint8List.fromList(<int>[0, 0, 1, 0, 2, 0, 3, 0]),
      sampleRate: 48000,
      channels: 2,
    );
    final header = ByteData.sublistView(wav);

    expect(header.getUint16(22, Endian.little), 2);
    expect(header.getUint32(24, Endian.little), 48000);
    expect(header.getUint32(28, Endian.little), 192000);
    expect(header.getUint16(32, Endian.little), 4);
  });

  test('pcm16Duration derives duration from complete mono frames', () {
    final pcm = Uint8List(16000 * 2);

    expect(
      pcm16Duration(pcm, sampleRate: 16000, channels: 1),
      const Duration(seconds: 1),
    );
  });

  test('pcm16Duration derives duration from complete stereo frames', () {
    final pcm = Uint8List(48000 * 2 * 2);

    expect(
      pcm16Duration(pcm, sampleRate: 48000, channels: 2),
      const Duration(seconds: 1),
    );
  });

  test('PCM helpers reject invalid format metadata and partial frames', () {
    expect(
      () => pcm16ToWav(Uint8List(2), sampleRate: 0, channels: 1),
      throwsArgumentError,
    );
    expect(
      () => pcm16ToWav(Uint8List(2), sampleRate: 44100, channels: 3),
      throwsArgumentError,
    );
    expect(
      () => pcm16ToWav(Uint8List(1), sampleRate: 44100, channels: 1),
      throwsArgumentError,
    );
    expect(
      () => pcm16ToWav(Uint8List(2), sampleRate: 44100, channels: 2),
      throwsArgumentError,
    );
    expect(
      () => pcm16Duration(Uint8List(2), sampleRate: 44100, channels: 2),
      throwsArgumentError,
    );
  });
}
