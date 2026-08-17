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
  static const _supportedPlaybackSpeeds = <double>[
    .5,
    .75,
    1.0,
    1.25,
    1.5,
    1.75,
    2.0,
  ];
  static const _supportedSkipIntervals = <int>{5, 10, 15, 30};

  Future<SettingsSnapshot> load() async {
    final prefs = await SharedPreferences.getInstance();
    final defaults = SettingsSnapshot.defaults();

    Object? stored(String key) => prefs.get(key);
    bool storedBool(String key, bool fallback) {
      final value = stored(key);
      return value is bool ? value : fallback;
    }

    RecordingSettings recording = defaults.recording;
    final rawRecordingValue = stored(_recordingKey);
    if (rawRecordingValue is String) {
      try {
        final decoded = jsonDecode(rawRecordingValue);
        if (decoded is Map<String, dynamic>) {
          recording = RecordingSettings.fromJson(decoded);
        }
      } catch (_) {
        recording = defaults.recording;
      }
    }

    final themeValue = stored(_themeKey);
    final themeName = themeValue is String ? themeValue : null;
    final theme =
        ThemeMode.values.where((mode) => mode.name == themeName).firstOrNull ??
        defaults.themeMode;

    final speedValue = stored(_speedKey);
    final storedPlaybackSpeed = speedValue is num && speedValue.isFinite
        ? speedValue.toDouble()
        : null;
    final skipValue = stored(_skipKey);
    final storedSkipInterval = skipValue is int ? skipValue : null;

    return SettingsSnapshot(
      recording: recording,
      themeMode: theme,
      defaultPlaybackSpeed:
          _supportedPlaybackSpeeds.contains(storedPlaybackSpeed)
          ? storedPlaybackSpeed!
          : defaults.defaultPlaybackSpeed,
      skipIntervalSeconds: _supportedSkipIntervals.contains(storedSkipInterval)
          ? storedSkipInterval!
          : defaults.skipIntervalSeconds,
      skipSilence: storedBool(_skipSilenceKey, defaults.skipSilence),
      confirmDelete: storedBool(_confirmDeleteKey, defaults.confirmDelete),
      reducedMotion: storedBool(_reducedMotionKey, defaults.reducedMotion),
    );
  }

  Future<void> save(SettingsSnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    final results = await Future.wait<bool>([
      prefs.setString(_recordingKey, jsonEncode(snapshot.recording.toJson())),
      prefs.setString(_themeKey, snapshot.themeMode.name),
      prefs.setDouble(_speedKey, snapshot.defaultPlaybackSpeed),
      prefs.setInt(_skipKey, snapshot.skipIntervalSeconds),
      prefs.setBool(_skipSilenceKey, snapshot.skipSilence),
      prefs.setBool(_confirmDeleteKey, snapshot.confirmDelete),
      prefs.setBool(_reducedMotionKey, snapshot.reducedMotion),
    ]);
    if (results.any((stored) => !stored)) {
      throw StateError('Shared preferences rejected settings persistence.');
    }
  }
}

extension _IterableFirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
