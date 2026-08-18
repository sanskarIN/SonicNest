import 'package:flutter_test/flutter_test.dart';
import 'package:sonic_nest/core/naming_template.dart';
import 'package:sonic_nest/models/recording_settings.dart';

void main() {
  test('settings JSON roundtrip is stable', () {
    final original = RecordingSettings.forPreset(QualityPreset.podcast)
        .copyWith(
          format: RecordingFormat.mp3,
          namingPrefix: 'Studio',
          namingTemplate: '{category}_{prefix}_{sequence}_{suffix}',
          namingCategory: 'Podcast',
          namingSuffix: 'Final',
        );
    final restored = RecordingSettings.fromJson(original.toJson());

    expect(restored.format, RecordingFormat.mp3);
    expect(restored.preset, QualityPreset.podcast);
    expect(restored.bitRate, original.bitRate);
    expect(restored.sampleRate, original.sampleRate);
    expect(restored.channels, original.channels);
    expect(restored.namingPrefix, 'Studio');
    expect(restored.namingTemplate, '{category}_{prefix}_{sequence}_{suffix}');
    expect(restored.namingCategory, 'Podcast');
    expect(restored.namingSuffix, 'Final');
  });

  test('legacy settings use safe smart-naming defaults', () {
    final restored = RecordingSettings.fromJson({'namingPrefix': 'Legacy'});

    expect(restored.namingPrefix, 'Legacy');
    expect(restored.namingTemplate, defaultRecordingNameTemplate);
    expect(restored.namingCategory, isEmpty);
    expect(restored.namingSuffix, isEmpty);
  });

  test('deserialization bounds channels and countdown', () {
    final restored = RecordingSettings.fromJson({
      'channels': 9,
      'countdownSeconds': 100,
    });
    expect(restored.channels, 2);
    expect(restored.countdownSeconds, 10);
  });

  test('deserialization rejects unsupported and malformed values', () {
    final restored = RecordingSettings.fromJson({
      'format': 42,
      'preset': false,
      'bitRate': -1,
      'sampleRate': 12345,
      'channels': 'stereo',
      'autoGain': 'yes',
      'namingPrefix': 9,
      'countdownSeconds': 'seven',
      'keepScreenAwake': 'true',
    });

    expect(restored.format, RecordingFormat.m4a);
    expect(restored.preset, QualityPreset.custom);
    expect(restored.bitRate, 128000);
    expect(restored.sampleRate, 44100);
    expect(restored.channels, 1);
    expect(restored.autoGain, isFalse);
    expect(restored.namingPrefix, 'Recording');
    expect(restored.countdownSeconds, 0);
    expect(restored.keepScreenAwake, isFalse);
  });

  test('deserialization rejects fractional integer fields', () {
    final restored = RecordingSettings.fromJson({
      'bitRate': 192000.5,
      'sampleRate': 48000.5,
      'channels': 2.5,
      'countdownSeconds': 7.5,
    });

    expect(restored.bitRate, 128000);
    expect(restored.sampleRate, 44100);
    expect(restored.channels, 1);
    expect(restored.countdownSeconds, 0);
  });

  test('transcoded formats are marked correctly', () {
    expect(RecordingFormat.mp3.needsTranscode, isTrue);
    expect(RecordingFormat.ogg.needsTranscode, isTrue);
    expect(RecordingFormat.aac.needsTranscode, isTrue);
    expect(RecordingFormat.wav.needsTranscode, isFalse);
  });
}
