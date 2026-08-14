import 'package:record/record.dart';

import '../core/naming_template.dart';

enum RecordingFormat { m4a, wav, flac, opus, mp3, ogg, aac }

enum QualityPreset {
  speech,
  meeting,
  lecture,
  interview,
  podcast,
  music,
  highQuality,
  lossless,
  smallFile,
  custom,
}

extension RecordingFormatX on RecordingFormat {
  String get label => switch (this) {
        RecordingFormat.m4a => 'M4A / AAC',
        RecordingFormat.wav => 'WAV',
        RecordingFormat.flac => 'FLAC',
        RecordingFormat.opus => 'Opus',
        RecordingFormat.mp3 => 'MP3',
        RecordingFormat.ogg => 'OGG / Vorbis',
        RecordingFormat.aac => 'AAC',
      };

  String get extension => switch (this) {
        RecordingFormat.m4a => 'm4a',
        RecordingFormat.wav => 'wav',
        RecordingFormat.flac => 'flac',
        RecordingFormat.opus => 'opus',
        RecordingFormat.mp3 => 'mp3',
        RecordingFormat.ogg => 'ogg',
        RecordingFormat.aac => 'aac',
      };

  bool get needsTranscode =>
      this == RecordingFormat.mp3 ||
      this == RecordingFormat.ogg ||
      this == RecordingFormat.aac;

  AudioEncoder get nativeEncoder => switch (this) {
        RecordingFormat.m4a => AudioEncoder.aacLc,
        RecordingFormat.wav => AudioEncoder.wav,
        RecordingFormat.flac => AudioEncoder.flac,
        RecordingFormat.opus => AudioEncoder.opus,
        RecordingFormat.mp3 || RecordingFormat.ogg || RecordingFormat.aac =>
          AudioEncoder.wav,
      };
}

class RecordingSettings {
  const RecordingSettings({
    required this.format,
    required this.preset,
    required this.bitRate,
    required this.sampleRate,
    required this.channels,
    required this.autoGain,
    required this.echoCancel,
    required this.noiseSuppress,
    required this.namingPrefix,
    required this.namingTemplate,
    required this.namingSuffix,
    required this.namingCategory,
    required this.countdownSeconds,
    required this.keepScreenAwake,
  });

  factory RecordingSettings.defaults() =>
      RecordingSettings.forPreset(QualityPreset.speech);

  factory RecordingSettings.forPreset(QualityPreset preset) {
    return switch (preset) {
      QualityPreset.speech => const RecordingSettings(
          format: RecordingFormat.m4a,
          preset: QualityPreset.speech,
          bitRate: 96000,
          sampleRate: 44100,
          channels: 1,
          autoGain: true,
          echoCancel: true,
          noiseSuppress: true,
          namingPrefix: 'Recording',
          namingTemplate: defaultRecordingNameTemplate,
          namingSuffix: '',
          namingCategory: 'Speech',
          countdownSeconds: 0,
          keepScreenAwake: false,
        ),
      QualityPreset.meeting || QualityPreset.lecture || QualityPreset.interview =>
        RecordingSettings(
          format: RecordingFormat.m4a,
          preset: preset,
          bitRate: 128000,
          sampleRate: 48000,
          channels: 1,
          autoGain: true,
          echoCancel: true,
          noiseSuppress: true,
          namingPrefix: 'Recording',
          namingTemplate: defaultRecordingNameTemplate,
          namingSuffix: '',
          namingCategory: switch (preset) {
            QualityPreset.meeting => 'Meeting',
            QualityPreset.lecture => 'Lecture',
            QualityPreset.interview => 'Interview',
            _ => 'Recording',
          },
          countdownSeconds: 0,
          keepScreenAwake: false,
        ),
      QualityPreset.podcast => const RecordingSettings(
          format: RecordingFormat.m4a,
          preset: QualityPreset.podcast,
          bitRate: 192000,
          sampleRate: 48000,
          channels: 2,
          autoGain: false,
          echoCancel: false,
          noiseSuppress: true,
          namingPrefix: 'Podcast',
          namingTemplate: defaultRecordingNameTemplate,
          namingSuffix: '',
          namingCategory: 'Podcast',
          countdownSeconds: 3,
          keepScreenAwake: true,
        ),
      QualityPreset.music || QualityPreset.highQuality => RecordingSettings(
          format: RecordingFormat.flac,
          preset: preset,
          bitRate: 320000,
          sampleRate: 48000,
          channels: 2,
          autoGain: false,
          echoCancel: false,
          noiseSuppress: false,
          namingPrefix: 'Audio',
          namingTemplate: defaultRecordingNameTemplate,
          namingSuffix: '',
          namingCategory: preset == QualityPreset.music ? 'Music' : 'High Quality',
          countdownSeconds: 0,
          keepScreenAwake: true,
        ),
      QualityPreset.lossless => const RecordingSettings(
          format: RecordingFormat.flac,
          preset: QualityPreset.lossless,
          bitRate: 320000,
          sampleRate: 96000,
          channels: 2,
          autoGain: false,
          echoCancel: false,
          noiseSuppress: false,
          namingPrefix: 'Lossless',
          namingTemplate: defaultRecordingNameTemplate,
          namingSuffix: '',
          namingCategory: 'Lossless',
          countdownSeconds: 0,
          keepScreenAwake: true,
        ),
      QualityPreset.smallFile => const RecordingSettings(
          format: RecordingFormat.opus,
          preset: QualityPreset.smallFile,
          bitRate: 64000,
          sampleRate: 48000,
          channels: 1,
          autoGain: true,
          echoCancel: true,
          noiseSuppress: true,
          namingPrefix: 'Recording',
          namingTemplate: defaultRecordingNameTemplate,
          namingSuffix: '',
          namingCategory: 'Small File',
          countdownSeconds: 0,
          keepScreenAwake: false,
        ),
      QualityPreset.custom => const RecordingSettings(
          format: RecordingFormat.m4a,
          preset: QualityPreset.custom,
          bitRate: 128000,
          sampleRate: 44100,
          channels: 1,
          autoGain: false,
          echoCancel: false,
          noiseSuppress: false,
          namingPrefix: 'Recording',
          namingTemplate: defaultRecordingNameTemplate,
          namingSuffix: '',
          namingCategory: '',
          countdownSeconds: 0,
          keepScreenAwake: false,
        ),
    };
  }

  factory RecordingSettings.fromJson(Map<String, dynamic> json) {
    T enumValue<T extends Enum>(List<T> values, String? name, T fallback) {
      return values.where((value) => value.name == name).firstOrNull ?? fallback;
    }

    return RecordingSettings(
      format: enumValue(
        RecordingFormat.values,
        json['format'] as String?,
        RecordingFormat.m4a,
      ),
      preset: enumValue(
        QualityPreset.values,
        json['preset'] as String?,
        QualityPreset.custom,
      ),
      bitRate: (json['bitRate'] as num?)?.toInt() ?? 128000,
      sampleRate: (json['sampleRate'] as num?)?.toInt() ?? 44100,
      channels: ((json['channels'] as num?)?.toInt() ?? 1).clamp(1, 2).toInt(),
      autoGain: json['autoGain'] as bool? ?? false,
      echoCancel: json['echoCancel'] as bool? ?? false,
      noiseSuppress: json['noiseSuppress'] as bool? ?? false,
      namingPrefix: json['namingPrefix'] as String? ?? 'Recording',
      namingTemplate:
          json['namingTemplate'] as String? ?? defaultRecordingNameTemplate,
      namingSuffix: json['namingSuffix'] as String? ?? '',
      namingCategory: json['namingCategory'] as String? ?? '',
      countdownSeconds:
          ((json['countdownSeconds'] as num?)?.toInt() ?? 0).clamp(0, 10).toInt(),
      keepScreenAwake: json['keepScreenAwake'] as bool? ?? false,
    );
  }

  final RecordingFormat format;
  final QualityPreset preset;
  final int bitRate;
  final int sampleRate;
  final int channels;
  final bool autoGain;
  final bool echoCancel;
  final bool noiseSuppress;
  final String namingPrefix;
  final String namingTemplate;
  final String namingSuffix;
  final String namingCategory;
  final int countdownSeconds;
  final bool keepScreenAwake;

  RecordingSettings copyWith({
    RecordingFormat? format,
    QualityPreset? preset,
    int? bitRate,
    int? sampleRate,
    int? channels,
    bool? autoGain,
    bool? echoCancel,
    bool? noiseSuppress,
    String? namingPrefix,
    String? namingTemplate,
    String? namingSuffix,
    String? namingCategory,
    int? countdownSeconds,
    bool? keepScreenAwake,
  }) {
    return RecordingSettings(
      format: format ?? this.format,
      preset: preset ?? this.preset,
      bitRate: bitRate ?? this.bitRate,
      sampleRate: sampleRate ?? this.sampleRate,
      channels: channels ?? this.channels,
      autoGain: autoGain ?? this.autoGain,
      echoCancel: echoCancel ?? this.echoCancel,
      noiseSuppress: noiseSuppress ?? this.noiseSuppress,
      namingPrefix: namingPrefix ?? this.namingPrefix,
      namingTemplate: namingTemplate ?? this.namingTemplate,
      namingSuffix: namingSuffix ?? this.namingSuffix,
      namingCategory: namingCategory ?? this.namingCategory,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      keepScreenAwake: keepScreenAwake ?? this.keepScreenAwake,
    );
  }

  Map<String, Object> toJson() => {
        'format': format.name,
        'preset': preset.name,
        'bitRate': bitRate,
        'sampleRate': sampleRate,
        'channels': channels,
        'autoGain': autoGain,
        'echoCancel': echoCancel,
        'noiseSuppress': noiseSuppress,
        'namingPrefix': namingPrefix,
        'namingTemplate': namingTemplate,
        'namingSuffix': namingSuffix,
        'namingCategory': namingCategory,
        'countdownSeconds': countdownSeconds,
        'keepScreenAwake': keepScreenAwake,
      };
}

extension _IterableFirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
