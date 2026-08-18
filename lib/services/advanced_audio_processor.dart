import 'dart:io';

import 'package:ffmpeg_kit_flutter_new_audio/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_audio/return_code.dart';

import '../models/recording_settings.dart';
import 'storage_service.dart';

class AdvancedAudioProcessingException implements Exception {
  const AdvancedAudioProcessingException(this.message);

  final String message;

  @override
  String toString() => 'AdvancedAudioProcessingException: $message';
}

class AdvancedAudioProcessor {
  AdvancedAudioProcessor(this._storage);

  final StorageService _storage;

  String _q(String value) =>
      '"${value.replaceAll('\\', '\\\\').replaceAll('"', '\\"')}"';

  String _codecArgs(RecordingFormat format, int bitRate) => switch (format) {
    RecordingFormat.mp3 => '-codec:a libmp3lame -b:a ${bitRate ~/ 1000}k',
    RecordingFormat.ogg => '-codec:a libvorbis -q:a 5',
    RecordingFormat.aac => '-codec:a aac -b:a ${bitRate ~/ 1000}k -f adts',
    RecordingFormat.m4a => '-codec:a aac -b:a ${bitRate ~/ 1000}k',
    RecordingFormat.flac => '-codec:a flac',
    RecordingFormat.opus => '-codec:a libopus -b:a ${bitRate ~/ 1000}k',
    RecordingFormat.wav => '-codec:a pcm_s16le',
  };

  Future<void> _run(String command) async {
    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();
    if (!ReturnCode.isSuccess(returnCode)) {
      final output = await session.getOutput();
      throw AdvancedAudioProcessingException(
        output?.trim().isNotEmpty == true
            ? output!.trim()
            : 'Audio processing failed.',
      );
    }
  }

  Future<T> _withOutputCleanup<T>(
    String output,
    Future<T> Function() operation,
  ) async {
    try {
      return await operation();
    } catch (_) {
      try {
        await _storage.deleteManagedAudioIfExists(output);
      } on FileSystemException {
        // Preserve the processing failure as the primary error.
      }
      rethrow;
    }
  }

  Future<String> cutSelection({
    required String inputPath,
    required String outputTitle,
    required RecordingFormat format,
    required Duration start,
    required Duration end,
    required int bitRate,
  }) async {
    if (start.isNegative || end <= start) {
      throw const AdvancedAudioProcessingException('Cut range is invalid.');
    }
    final output = await _storage.uniqueRecordingPath(
      outputTitle,
      format.extension,
    );
    final startSeconds = start.inMilliseconds / 1000;
    final endSeconds = end.inMilliseconds / 1000;
    final filter =
        '[0:a]atrim=0:$startSeconds,asetpts=PTS-STARTPTS[a0];'
        '[0:a]atrim=start=$endSeconds,asetpts=PTS-STARTPTS[a1];'
        '[a0][a1]concat=n=2:v=0:a=1[out]';
    return _withOutputCleanup(output, () async {
      await _run(
        '-y -i ${_q(inputPath)} -filter_complex "$filter" -map "[out]" '
        '${_codecArgs(format, bitRate)} ${_q(output)}',
      );
      return _requireOutput(output);
    });
  }

  Future<String> insertSilence({
    required String inputPath,
    required String outputTitle,
    required RecordingFormat format,
    required Duration at,
    required Duration silenceDuration,
    required int bitRate,
    required int sampleRate,
    required int channels,
  }) async {
    if (at.isNegative || silenceDuration <= Duration.zero) {
      throw const AdvancedAudioProcessingException(
        'Silence insertion values are invalid.',
      );
    }
    final output = await _storage.uniqueRecordingPath(
      outputTitle,
      format.extension,
    );
    final atSeconds = at.inMilliseconds / 1000;
    final silenceSeconds = silenceDuration.inMilliseconds / 1000;
    final channelLayout = channels <= 1 ? 'mono' : 'stereo';
    final filter =
        '[0:a]atrim=0:$atSeconds,asetpts=PTS-STARTPTS[a0];'
        'anullsrc=r=$sampleRate:cl=$channelLayout:d=$silenceSeconds[s];'
        '[0:a]atrim=start=$atSeconds,asetpts=PTS-STARTPTS[a1];'
        '[a0][s][a1]concat=n=3:v=0:a=1[out]';
    return _withOutputCleanup(output, () async {
      await _run(
        '-y -i ${_q(inputPath)} -filter_complex "$filter" -map "[out]" '
        '${_codecArgs(format, bitRate)} ${_q(output)}',
      );
      return _requireOutput(output);
    });
  }

  Future<String> adjustVolume({
    required String inputPath,
    required String outputTitle,
    required RecordingFormat format,
    required int bitRate,
    required double gainDb,
  }) async {
    final boundedGain = gainDb.clamp(-24.0, 24.0).toDouble();
    return _filteredCopy(
      inputPath: inputPath,
      outputTitle: outputTitle,
      format: format,
      bitRate: bitRate,
      audioFilter: 'volume=${boundedGain}dB',
    );
  }

  Future<String> highPass({
    required String inputPath,
    required String outputTitle,
    required RecordingFormat format,
    required int bitRate,
    required int frequencyHz,
  }) {
    final frequency = frequencyHz.clamp(20, 5000);
    return _filteredCopy(
      inputPath: inputPath,
      outputTitle: outputTitle,
      format: format,
      bitRate: bitRate,
      audioFilter: 'highpass=f=$frequency',
    );
  }

  Future<String> lowPass({
    required String inputPath,
    required String outputTitle,
    required RecordingFormat format,
    required int bitRate,
    required int frequencyHz,
  }) {
    final frequency = frequencyHz.clamp(1000, 22000);
    return _filteredCopy(
      inputPath: inputPath,
      outputTitle: outputTitle,
      format: format,
      bitRate: bitRate,
      audioFilter: 'lowpass=f=$frequency',
    );
  }

  Future<String> compressor({
    required String inputPath,
    required String outputTitle,
    required RecordingFormat format,
    required int bitRate,
  }) {
    return _filteredCopy(
      inputPath: inputPath,
      outputTitle: outputTitle,
      format: format,
      bitRate: bitRate,
      audioFilter: 'acompressor=threshold=-18dB:ratio=3:attack=20:release=250:makeup=2dB',
    );
  }

  Future<String> limiter({
    required String inputPath,
    required String outputTitle,
    required RecordingFormat format,
    required int bitRate,
  }) {
    return _filteredCopy(
      inputPath: inputPath,
      outputTitle: outputTitle,
      format: format,
      bitRate: bitRate,
      audioFilter: 'alimiter=limit=0.95:attack=5:release=50',
    );
  }

  Future<String> noiseCleanup({
    required String inputPath,
    required String outputTitle,
    required RecordingFormat format,
    required int bitRate,
  }) {
    return _filteredCopy(
      inputPath: inputPath,
      outputTitle: outputTitle,
      format: format,
      bitRate: bitRate,
      audioFilter: 'afftdn=nr=10:nf=-45',
    );
  }

  Future<String> _filteredCopy({
    required String inputPath,
    required String outputTitle,
    required RecordingFormat format,
    required int bitRate,
    required String audioFilter,
  }) async {
    final output = await _storage.uniqueRecordingPath(
      outputTitle,
      format.extension,
    );
    return _withOutputCleanup(output, () async {
      await _run(
        '-y -i ${_q(inputPath)} -vn -filter:a "$audioFilter" '
        '${_codecArgs(format, bitRate)} ${_q(output)}',
      );
      return _requireOutput(output);
    });
  }

  Future<String> _requireOutput(String path) async {
    if (!await File(path).exists() || await File(path).length() == 0) {
      throw const AdvancedAudioProcessingException(
        'The processed audio file was not created.',
      );
    }
    return path;
  }
}
