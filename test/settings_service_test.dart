import 'dart:convert';

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

  test('wrong-type legacy preference values fall back safely', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'recording_settings': 7,
      'theme_mode': 42,
      'playback_speed': 'fast',
      'skip_interval': 'ten',
      'skip_silence': 'yes',
      'confirm_delete': 1,
      'reduced_motion': <String>['no'],
    });

    final snapshot = await SettingsService().load();

    expect(snapshot.recording, isA<RecordingSettings>());
    expect(snapshot.themeMode, ThemeMode.system);
    expect(snapshot.defaultPlaybackSpeed, 1.0);
    expect(snapshot.skipIntervalSeconds, 10);
    expect(snapshot.skipSilence, isFalse);
    expect(snapshot.confirmDelete, isTrue);
    expect(snapshot.reducedMotion, isFalse);
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

  test('new save writes one canonical coherent settings snapshot', () async {
    final service = SettingsService();
    final snapshot = SettingsSnapshot.defaults().copyWith(
      themeMode: ThemeMode.dark,
      defaultPlaybackSpeed: 1.75,
      skipIntervalSeconds: 15,
      skipSilence: true,
      confirmDelete: false,
      reducedMotion: true,
    );

    await service.save(snapshot);
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('settings_snapshot_v1');

    expect(raw, isNotNull);
    final decoded = jsonDecode(raw!) as Map<String, dynamic>;
    expect(decoded['schemaVersion'], 1);
    expect(decoded['themeMode'], 'dark');
    expect(decoded['defaultPlaybackSpeed'], 1.75);
    expect(decoded['skipIntervalSeconds'], 15);
    expect(decoded['skipSilence'], isTrue);
    expect(decoded['confirmDelete'], isFalse);
    expect(decoded['reducedMotion'], isTrue);
    expect(decoded['recording'], isA<Map<String, dynamic>>());

    expect(prefs.containsKey('theme_mode'), isFalse);
    expect(prefs.containsKey('playback_speed'), isFalse);
    expect(prefs.containsKey('skip_interval'), isFalse);
  });

  test('canonical snapshot takes precedence over stale legacy keys', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'settings_snapshot_v1': jsonEncode(<String, Object>{
        'schemaVersion': 1,
        'recording': RecordingSettings.forPreset(
          QualityPreset.interview,
        ).toJson(),
        'themeMode': 'dark',
        'defaultPlaybackSpeed': 1.5,
        'skipIntervalSeconds': 30,
        'skipSilence': true,
        'confirmDelete': false,
        'reducedMotion': true,
      }),
      'theme_mode': 'light',
      'playback_speed': 0.5,
      'skip_interval': 5,
      'skip_silence': false,
      'confirm_delete': true,
      'reduced_motion': false,
    });

    final snapshot = await SettingsService().load();

    expect(snapshot.recording.preset, QualityPreset.interview);
    expect(snapshot.themeMode, ThemeMode.dark);
    expect(snapshot.defaultPlaybackSpeed, 1.5);
    expect(snapshot.skipIntervalSeconds, 30);
    expect(snapshot.skipSilence, isTrue);
    expect(snapshot.confirmDelete, isFalse);
    expect(snapshot.reducedMotion, isTrue);
  });

  test('damaged canonical snapshot falls back to legacy preferences', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'settings_snapshot_v1': '{not valid json',
      'theme_mode': 'dark',
      'playback_speed': 1.25,
      'skip_interval': 15,
      'skip_silence': true,
      'confirm_delete': false,
      'reduced_motion': true,
    });

    final snapshot = await SettingsService().load();

    expect(snapshot.themeMode, ThemeMode.dark);
    expect(snapshot.defaultPlaybackSpeed, 1.25);
    expect(snapshot.skipIntervalSeconds, 15);
    expect(snapshot.skipSilence, isTrue);
    expect(snapshot.confirmDelete, isFalse);
    expect(snapshot.reducedMotion, isTrue);
  });
}
