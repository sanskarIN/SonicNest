import 'package:flutter_test/flutter_test.dart';
import 'package:sonic_nest/core/naming_template.dart';
import 'package:sonic_nest/models/recording_settings.dart';

void main() {
  test('settings JSON roundtrip is stable', () {
    final original = RecordingSettings.forPreset(QualityPreset.podcast).copyWith(
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
    final restored = RecordingSettings.fromJson({
      'namingPrefix': 'Legacy',
    });

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

  test('transcoded formats are marked correctly', () {
    expect(RecordingFormat.mp3.needsTranscode, isTrue);
    expect(RecordingFormat.ogg.needsTranscode, isTrue);
    expect(RecordingFormat.aac.needsTranscode, isTrue);
    expect(RecordingFormat.wav.needsTranscode, isFalse);
  });
}
