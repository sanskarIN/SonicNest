import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/recording_settings.dart';

class SettingsSnapshot {
  const SettingsSnapshot({
    required this.recording,
    required this.themeMode,
    required this.defaultPlaybackSpeed,
    required this.skipIntervalSeconds,
    required this.skipSilence,
    required this.confirmDelete,
    required this.reducedMotion,
  });

  factory SettingsSnapshot.defaults() => SettingsSnapshot(
    recording: RecordingSettings.defaults(),
    themeMode: ThemeMode.system,
    defaultPlaybackSpeed: 1,
    skipIntervalSeconds: 10,
    skipSilence: false,
    confirmDelete: true,
    reducedMotion: false,
  );

  final RecordingSettings recording;
  final ThemeMode themeMode;
  final double defaultPlaybackSpeed;
  final int skipIntervalSeconds;
  final bool skipSilence;
  final bool confirmDelete;
  final bool reducedMotion;

  SettingsSnapshot copyWith({
    RecordingSettings? recording,
    ThemeMode? themeMode,
    double? defaultPlaybackSpeed,
    int? skipIntervalSeconds,
    bool? skipSilence,
    bool? confirmDelete,
    bool? reducedMotion,
  }) {
    return SettingsSnapshot(
      recording: recording ?? this.recording,
      themeMode: themeMode ?? this.themeMode,
      defaultPlaybackSpeed: defaultPlaybackSpeed ?? this.defaultPlaybackSpeed,
      skipIntervalSeconds: skipIntervalSeconds ?? this.skipIntervalSeconds,
      skipSilence: skipSilence ?? this.skipSilence,
      confirmDelete: confirmDelete ?? this.confirmDelete,
      reducedMotion: reducedMotion ?? this.reducedMotion,
    );
  }
}

class SettingsService {
  static const _recordingKey = 'recording_settings';
  static const _themeKey = 'theme_mode';
  static const _speedKey = 'playback_speed';
  static const _skipKey = 'skip_interval';
  static const _skipSilenceKey = 'skip_silence';
  static const _confirmDeleteKey = 'confirm_delete';
  static const _reducedMotionKey = 'reduced_motion';

  Future<SettingsSnapshot> load() async {
    final prefs = await SharedPreferences.getInstance();
    final defaults = SettingsSnapshot.defaults();
    RecordingSettings recording = defaults.recording;
    final rawRecording = prefs.getString(_recordingKey);
    if (rawRecording != null) {
      try {
        recording = RecordingSettings.fromJson(
          jsonDecode(rawRecording) as Map<String, dynamic>,
        );
      } catch (_) {
        recording = defaults.recording;
      }
    }
    final themeName = prefs.getString(_themeKey);
    final theme =
        ThemeMode.values.where((mode) => mode.name == themeName).firstOrNull ??
        defaults.themeMode;
    return SettingsSnapshot(
      recording: recording,
      themeMode: theme,
      defaultPlaybackSpeed:
          prefs.getDouble(_speedKey) ?? defaults.defaultPlaybackSpeed,
      skipIntervalSeconds:
          prefs.getInt(_skipKey) ?? defaults.skipIntervalSeconds,
      skipSilence: prefs.getBool(_skipSilenceKey) ?? defaults.skipSilence,
      confirmDelete: prefs.getBool(_confirmDeleteKey) ?? defaults.confirmDelete,
      reducedMotion: prefs.getBool(_reducedMotionKey) ?? defaults.reducedMotion,
    );
  }

  Future<void> save(SettingsSnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_recordingKey, jsonEncode(snapshot.recording.toJson())),
      prefs.setString(_themeKey, snapshot.themeMode.name),
      prefs.setDouble(_speedKey, snapshot.defaultPlaybackSpeed),
      prefs.setInt(_skipKey, snapshot.skipIntervalSeconds),
      prefs.setBool(_skipSilenceKey, snapshot.skipSilence),
      prefs.setBool(_confirmDeleteKey, snapshot.confirmDelete),
      prefs.setBool(_reducedMotionKey, snapshot.reducedMotion),
    ]);
  }
}

extension _IterableFirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
