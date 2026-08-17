import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sonic_nest/models/recording_settings.dart';
import 'package:sonic_nest/services/settings_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('invalid persisted playback values fall back safely', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'playback_speed': 99.0,
      'skip_interval': -10,
    });

    final snapshot = await SettingsService().load();

    expect(snapshot.defaultPlaybackSpeed, 1.0);
    expect(snapshot.skipIntervalSeconds, 10);
  });

  test('settings save and load roundtrip preserves supported values', () async {
    final service = SettingsService();
    final snapshot = SettingsSnapshot.defaults().copyWith(
      recording: RecordingSettings.forPreset(QualityPreset.podcast),
      themeMode: ThemeMode.dark,
      defaultPlaybackSpeed: 1.5,
      skipIntervalSeconds: 30,
      skipSilence: true,
      confirmDelete: false,
      reducedMotion: true,
    );

    await service.save(snapshot);
    final restored = await service.load();

    expect(restored.recording.preset, QualityPreset.podcast);
    expect(restored.themeMode, ThemeMode.dark);
    expect(restored.defaultPlaybackSpeed, 1.5);
    expect(restored.skipIntervalSeconds, 30);
    expect(restored.skipSilence, isTrue);
    expect(restored.confirmDelete, isFalse);
    expect(restored.reducedMotion, isTrue);
  });
}
