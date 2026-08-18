import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/recording_settings.dart';

class UnsupportedSettingsSchemaException implements Exception {
  const UnsupportedSettingsSchemaException(this.schemaVersion);

  final int schemaVersion;

  @override
  String toString() =>
      'UnsupportedSettingsSchemaException: settings schema '
      '$schemaVersion is not supported by this SonicNest build.';
}

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
  static const _snapshotKey = 'settings_snapshot_v1';
  static const _snapshotSchemaVersion = 1;

  // Legacy per-field keys remain readable so existing installations migrate
  // without losing preferences. New writes use the single snapshot above so a
  // failed multi-key update cannot leave a partially new settings state.
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

    final rawSnapshot = prefs.get(_snapshotKey);
    if (rawSnapshot is String) {
      try {
        final decoded = jsonDecode(rawSnapshot);
        if (decoded is Map<String, dynamic>) {
          final schemaVersion = decoded['schemaVersion'];
          if (schemaVersion is int && schemaVersion != _snapshotSchemaVersion) {
            throw UnsupportedSettingsSchemaException(schemaVersion);
          }
          if (schemaVersion == _snapshotSchemaVersion) {
            return _decodeValues(
              defaults: defaults,
              recordingValue: decoded['recording'],
              themeValue: decoded['themeMode'],
              speedValue: decoded['defaultPlaybackSpeed'],
              skipValue: decoded['skipIntervalSeconds'],
              skipSilenceValue: decoded['skipSilence'],
              confirmDeleteValue: decoded['confirmDelete'],
              reducedMotionValue: decoded['reducedMotion'],
            );
          }
        }
      } on UnsupportedSettingsSchemaException {
        rethrow;
      } catch (_) {
        // Fall through to the legacy keys. They are retained as a migration
        // safety net for installations whose canonical snapshot is damaged.
      }
    }

    return _decodeValues(
      defaults: defaults,
      recordingValue: prefs.get(_recordingKey),
      themeValue: prefs.get(_themeKey),
      speedValue: prefs.get(_speedKey),
      skipValue: prefs.get(_skipKey),
      skipSilenceValue: prefs.get(_skipSilenceKey),
      confirmDeleteValue: prefs.get(_confirmDeleteKey),
      reducedMotionValue: prefs.get(_reducedMotionKey),
    );
  }

  SettingsSnapshot _decodeValues({
    required SettingsSnapshot defaults,
    required Object? recordingValue,
    required Object? themeValue,
    required Object? speedValue,
    required Object? skipValue,
    required Object? skipSilenceValue,
    required Object? confirmDeleteValue,
    required Object? reducedMotionValue,
  }) {
    RecordingSettings recording = defaults.recording;
    Object? decodedRecording = recordingValue;
    if (recordingValue is String) {
      try {
        decodedRecording = jsonDecode(recordingValue);
      } catch (_) {
        decodedRecording = null;
      }
    }
    if (decodedRecording is Map) {
      try {
        recording = RecordingSettings.fromJson(
          Map<String, dynamic>.from(decodedRecording),
        );
      } catch (_) {
        recording = defaults.recording;
      }
    }

    final themeName = themeValue is String ? themeValue : null;
    final theme =
        ThemeMode.values.where((mode) => mode.name == themeName).firstOrNull ??
        defaults.themeMode;

    final storedPlaybackSpeed = speedValue is num && speedValue.isFinite
        ? speedValue.toDouble()
        : null;
    final storedSkipInterval = skipValue is int ? skipValue : null;

    bool boolValue(Object? value, bool fallback) =>
        value is bool ? value : fallback;

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
      skipSilence: boolValue(skipSilenceValue, defaults.skipSilence),
      confirmDelete: boolValue(confirmDeleteValue, defaults.confirmDelete),
      reducedMotion: boolValue(reducedMotionValue, defaults.reducedMotion),
    );
  }

  Future<void> save(SettingsSnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = <String, Object>{
      'schemaVersion': _snapshotSchemaVersion,
      'recording': snapshot.recording.toJson(),
      'themeMode': snapshot.themeMode.name,
      'defaultPlaybackSpeed': snapshot.defaultPlaybackSpeed,
      'skipIntervalSeconds': snapshot.skipIntervalSeconds,
      'skipSilence': snapshot.skipSilence,
      'confirmDelete': snapshot.confirmDelete,
      'reducedMotion': snapshot.reducedMotion,
    };
    final stored = await prefs.setString(_snapshotKey, jsonEncode(payload));
    if (!stored) {
      throw StateError('Shared preferences rejected settings persistence.');
    }
  }
}

extension _IterableFirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
