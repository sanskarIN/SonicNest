import 'dart:typed_data';

/// Returns the duration represented by complete little-endian PCM16 frames.
///
/// Browser capture duration is derived from the bytes that will actually be
/// written to the WAV file instead of relying on a UI timer that can drift or
/// be affected by pause/resume scheduling.
Duration pcm16Duration(
  Uint8List pcm, {
  required int sampleRate,
  required int channels,
}) {
  final blockAlign = _validatePcm16Format(
    pcm,
    sampleRate: sampleRate,
    channels: channels,
  );
  final frameCount = pcm.length ~/ blockAlign;
  final microseconds =
      frameCount * Duration.microsecondsPerSecond ~/ sampleRate;
  return Duration(microseconds: microseconds);
}

/// Wraps little-endian signed PCM16 samples in a standard RIFF/WAVE container.
///
/// Browser recording uses the `record` package's PCM16 stream. Keeping the WAV
/// container writer in pure Dart makes it usable on every SonicNest target and
/// independently testable without browser or filesystem APIs.
Uint8List pcm16ToWav(
  Uint8List pcm, {
  required int sampleRate,
  required int channels,
}) {
  final blockAlign = _validatePcm16Format(
    pcm,
    sampleRate: sampleRate,
    channels: channels,
  );

  const bitsPerSample = 16;
  final byteRate = sampleRate * blockAlign;
  final dataLength = pcm.length;
  final output = Uint8List(44 + dataLength);
  final header = ByteData.sublistView(output);

  void writeAscii(int offset, String value) {
    for (var index = 0; index < value.length; index++) {
      output[offset + index] = value.codeUnitAt(index);
    }
  }

  writeAscii(0, 'RIFF');
  header.setUint32(4, 36 + dataLength, Endian.little);
  writeAscii(8, 'WAVE');
  writeAscii(12, 'fmt ');
  header.setUint32(16, 16, Endian.little);
  header.setUint16(20, 1, Endian.little);
  header.setUint16(22, channels, Endian.little);
  header.setUint32(24, sampleRate, Endian.little);
  header.setUint32(28, byteRate, Endian.little);
  header.setUint16(32, blockAlign, Endian.little);
  header.setUint16(34, bitsPerSample, Endian.little);
  writeAscii(36, 'data');
  header.setUint32(40, dataLength, Endian.little);
  output.setRange(44, output.length, pcm);

  return output;
}

int _validatePcm16Format(
  Uint8List pcm, {
  required int sampleRate,
  required int channels,
}) {
  if (sampleRate <= 0) {
    throw ArgumentError.value(sampleRate, 'sampleRate', 'must be positive');
  }
  if (channels != 1 && channels != 2) {
    throw ArgumentError.value(channels, 'channels', 'must be 1 or 2');
  }

  const bytesPerSample = 2;
  final blockAlign = channels * bytesPerSample;
  if (pcm.length % blockAlign != 0) {
    throw ArgumentError.value(
      pcm.length,
      'pcm.length',
      'PCM16 data must contain complete channel frames',
    );
  }
  return blockAlign;
}
