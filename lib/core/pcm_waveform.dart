import 'dart:math' as math;

/// Returns the normalized peak amplitude of little-endian signed 16-bit PCM.
///
/// An incomplete trailing byte is ignored. The result is always in the range
/// 0.0–1.0 and can be stored directly in SonicNest waveform envelopes.
double pcm16LePeak(List<int> bytes) {
  var peak = 0;
  for (var index = 0; index + 1 < bytes.length; index += 2) {
    var value = bytes[index] | (bytes[index + 1] << 8);
    if (value >= 0x8000) value -= 0x10000;
    peak = math.max(peak, value.abs());
  }
  return (peak / 32768.0).clamp(0.0, 1.0).toDouble();
}
