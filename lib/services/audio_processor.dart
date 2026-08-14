import 'dart:io';
import 'dart:math' as math;

import 'package:ffmpeg_kit_flutter_new_audio/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_audio/return_code.dart';

import '../core/constants.dart';
import '../models/recording_settings.dart';
import 'storage_service.dart';

class AudioProcessingException implements Exception {
  const AudioProcessingException(this.message);
  final String message;
  @override
  String toString() => 'AudioProcessingException: $message';
}

class AudioProcessor {
  AudioProcessor(this._storage);
  final StorageService _storage;

  String _q(String value) => '"${value.replaceAll('\\', '\\\\').replaceAll('"', '\\"')}"';

  Future<void> _run(String command) async {
    final session = await FFmpegKit.execute(command);
    final code = await session.getReturnCode();
    if (!ReturnCode.isSuccess(code)) {
      final output = await session.getOutput();
      throw AudioProcessingException(output?.trim().isNotEmpty == true
          ? output!.trim()
          : 'FFmpeg processing failed.');
    }
  }

  String _codecArgs(RecordingFormat format, int bitRate) => switch (format) {
        RecordingFormat.mp3 => '-codec:a libmp3lame -b:a ${bitRate ~/ 1000}k',
        RecordingFormat.ogg => '-codec:a libvorbis -q:a 5',
        RecordingFormat.aac => '-codec:a aac -b:a ${bitRate ~/ 1000}k -f adts',
        RecordingFormat.m4a => '-codec:a aac -b:a ${bitRate ~/ 1000}k',
        RecordingFormat.flac => '-codec:a flac',
        RecordingFormat.opus => '-codec:a libopus -b:a ${bitRate ~/ 1000}k',
        RecordingFormat.wav => '-codec:a pcm_s16le',
      };

  Future<List<double>> extractWaveformEnvelope(
    String inputPath, {
    int points = AppConstants.maxWaveformSamples,
  }) async {
    if (points <= 0) return const [];
    final pcmPath = await _storage.uniqueTempPath('waveform_envelope', 'pcm');
    try {
      await _run(
        '-y -i ${_q(inputPath)} -vn -ac 1 -ar 8000 -f s16le ${_q(pcmPath)}',
      );
      final pcm = File(pcmPath);
      if (!await pcm.exists()) return const [];
      final length = await pcm.length();
      if (length < 2) return const [];

      final sampleCount = length ~/ 2;
      final envelopePoints = math.min(points, sampleCount);
      var bytesPerBin = (length / envelopePoints).ceil();
      if (bytesPerBin.isOdd) bytesPerBin++;
      bytesPerBin = math.max(2, bytesPerBin);

      final result = <double>[];
      final handle = await pcm.open();
      try {
        for (var offset = 0; offset < length && result.length < envelopePoints; offset += bytesPerBin) {
          await handle.setPosition(offset);
          final remaining = length - offset;
          final bytes = await handle.read(math.min(bytesPerBin, remaining));
          var peak = 0;
          for (var index = 0; index + 1 < bytes.length; index += 2) {
            var value = bytes[index] | (bytes[index + 1] << 8);
            if (value >= 0x8000) value -= 0x10000;
            peak = math.max(peak, value.abs());
          }
          result.add((peak / 32768.0).clamp(0.0, 1.0).toDouble());
        }
      } finally {
        await handle.close();
      }
      return result;
    } finally {
      await _storage.deleteIfExists(pcmPath);
    }
  }

  Future<String> transcode({
    required String inputPath,
    required String outputTitle,
    required RecordingFormat format,
    required int bitRate,
    required int sampleRate,
    required int channels,
  }) async {
    final output = await _storage.uniqueRecordingPath(outputTitle, format.extension);
    final args = _codecArgs(format, bitRate);
    await _run('-y -i ${_q(inputPath)} -vn -ar $sampleRate -ac $channels $args ${_q(output)}');
    if (!await File(output).exists()) {
      throw const AudioProcessingException('Output file was not created.');
    }
    return output;
  }

  Future<String> trim({
    required String inputPath,
    required String outputTitle,
    required RecordingFormat format,
    required Duration start,
    required Duration end,
    required int bitRate,
  }) async {
    if (start.isNegative || end <= start) {
      throw const AudioProcessingException('Trim range is invalid.');
    }
    final output = await _storage.uniqueRecordingPath(outputTitle, format.extension);
    final args = _codecArgs(format, bitRate);
    final startSeconds = start.inMilliseconds / 1000;
    final durationSeconds = (end - start).inMilliseconds / 1000;
    await _run('-y -ss $startSeconds -i ${_q(inputPath)} -t $durationSeconds -vn $args ${_q(output)}');
    return output;
  }

  Future<List<String>> split({
    required String inputPath,
    required String outputTitle,
    required RecordingFormat format,
    required Duration at,
    required int bitRate,
  }) async {
    if (at <= Duration.zero) {
      throw const AudioProcessingException('Split point must be greater than zero.');
    }
    final first = await _storage.uniqueRecordingPath('$outputTitle Part 1', format.extension);
    final second = await _storage.uniqueRecordingPath('$outputTitle Part 2', format.extension);
    final args = _codecArgs(format, bitRate);
    final seconds = at.inMilliseconds / 1000;
    await _run('-y -i ${_q(inputPath)} -t $seconds -vn $args ${_q(first)}');
    await _run('-y -ss $seconds -i ${_q(inputPath)} -vn $args ${_q(second)}');
    return [first, second];
  }

  Future<String> merge({
    required List<String> inputPaths,
    required String outputTitle,
    required RecordingFormat format,
    required int bitRate,
  }) async {
    if (inputPaths.length < 2) {
      throw const AudioProcessingException('Choose at least two files to merge.');
    }
    final output = await _storage.uniqueRecordingPath(outputTitle, format.extension);
    final temp = await _storage.uniqueTempPath('sonicnest_concat', 'txt');
    final listFile = File(temp);
    await listFile.writeAsString(inputPaths
        .map((path) => "file '${path.replaceAll("'", "'\\''")}'")
        .join('\n'));
    try {
      final args = _codecArgs(format, bitRate);
      await _run('-y -f concat -safe 0 -i ${_q(temp)} -vn $args ${_q(output)}');
      return output;
    } finally {
      await _storage.deleteIfExists(temp);
    }
  }

  Future<String> normalize({
    required String inputPath,
    required String outputTitle,
    required RecordingFormat format,
    required int bitRate,
  }) =>
      _filter(
        inputPath: inputPath,
        outputTitle: outputTitle,
        format: format,
        bitRate: bitRate,
        audioFilter: 'loudnorm=I=-16:LRA=11:TP=-1.5',
      );

  Future<String> fade({
    required String inputPath,
    required String outputTitle,
    required RecordingFormat format,
    required int bitRate,
    Duration fadeIn = const Duration(seconds: 1),
    Duration fadeOutStart = const Duration(seconds: 1),
    Duration fadeOutDuration = const Duration(seconds: 1),
  }) {
    final inSeconds = fadeIn.inMilliseconds / 1000;
    final outStart = fadeOutStart.inMilliseconds / 1000;
    final outDuration = fadeOutDuration.inMilliseconds / 1000;
    return _filter(
      inputPath: inputPath,
      outputTitle: outputTitle,
      format: format,
      bitRate: bitRate,
      audioFilter: 'afade=t=in:st=0:d=$inSeconds,afade=t=out:st=$outStart:d=$outDuration',
    );
  }

  Future<String> removeSilence({
    required String inputPath,
    required String outputTitle,
    required RecordingFormat format,
    required int bitRate,
  }) =>
      _filter(
        inputPath: inputPath,
        outputTitle: outputTitle,
        format: format,
        bitRate: bitRate,
        audioFilter:
            'silenceremove=start_periods=1:start_duration=0.2:start_threshold=-45dB:stop_periods=-1:stop_duration=0.6:stop_threshold=-45dB',
      );

  Future<String> _filter({
    required String inputPath,
    required String outputTitle,
    required RecordingFormat format,
    required int bitRate,
    required String audioFilter,
  }) async {
    final output = await _storage.uniqueRecordingPath(outputTitle, format.extension);
    final args = _codecArgs(format, bitRate);
    await _run('-y -i ${_q(inputPath)} -vn -af ${_q(audioFilter)} $args ${_q(output)}');
    return output;
  }
}
