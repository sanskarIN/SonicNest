import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sonicnest/models/recording_settings.dart';
import 'package:sonicnest/services/diagnostic_report_service.dart';
import 'package:sonicnest/services/settings_service.dart';
import 'package:sonicnest/services/storage_service.dart';

void main() {
  group('DiagnosticReportService', () {
    const service = DiagnosticReportService();

    DiagnosticReport buildReport({StorageStats? storageStats}) {
      final settings = SettingsSnapshot.defaults().copyWith(
        recording: RecordingSettings.forPreset(QualityPreset.podcast),
        themeMode: ThemeMode.dark,
        defaultPlaybackSpeed: 1.25,
        skipIntervalSeconds: 15,
        skipSilence: true,
        confirmDelete: true,
        reducedMotion: true,
      );
      return service.build(
        generatedAt: DateTime.utc(2026, 8, 16, 6, 30),
        appVersion: '0.1.0+1',
        platform: 'android',
        operatingSystemVersion: 'Android test build',
        localeName: 'en_IN',
        dartVersion: '3.test',
        processorCount: 8,
        savedRecordings: 12,
        trashRecordings: 2,
        favoriteRecordings: 4,
        pinnedRecordings: 3,
        storageStats:
            storageStats ??
            const StorageStats(
              recordingsBytes: 1000,
              trashBytes: 200,
              temporaryBytes: 50,
              recordingCount: 12,
              trashCount: 2,
              temporaryFileCount: 1,
            ),
        storageProbeSucceeded: true,
        recorderStatus: 'idle',
        inputDeviceCount: 3,
        inputProbeSucceeded: true,
        customInputSelected: true,
        settings: settings,
      );
    }

    test('serializes deterministic machine-readable sections', () {
      final report = buildReport();
      final decoded = jsonDecode(report.toPrettyJson()) as Map<String, dynamic>;

      expect(decoded['schemaVersion'], DiagnosticReport.schemaVersion);
      expect(decoded['generatedAtUtc'], '2026-08-16T06:30:00.000Z');
      expect((decoded['app'] as Map<String, dynamic>)['version'], '0.1.0+1');
      expect((decoded['library'] as Map<String, dynamic>)['savedRecordings'], 12);
      expect((decoded['storage'] as Map<String, dynamic>)['totalManagedBytes'], 1250);
      expect((decoded['recorder'] as Map<String, dynamic>)['selectedInput'], 'custom');
      expect(
        ((decoded['settings'] as Map<String, dynamic>)['recording']
            as Map<String, dynamic>)['preset'],
        'podcast',
      );
    });

    test('explicitly excludes user recording content and device names', () {
      final report = buildReport();
      final json = report.toPrettyJson();
      final markdown = report.toMarkdown();

      expect(json, isNot(contains('recordingTitle')));
      expect(json, isNot(contains('filePath')));
      expect(json, isNot(contains('inputDeviceName')));
      expect(json, isNot(contains('namingPrefix')));
      expect(json, isNot(contains('namingTemplate')));
      expect(markdown, contains('Recording content: not included'));
      expect(markdown, contains('Input-device names: not included'));
    });

    test('represents failed storage and input probes without inventing values', () {
      final settings = SettingsSnapshot.defaults();
      final report = service.build(
        generatedAt: DateTime.utc(2026, 8, 16),
        appVersion: '0.1.0+1',
        platform: 'linux',
        operatingSystemVersion: 'test',
        localeName: 'en_US',
        dartVersion: 'test',
        processorCount: 2,
        savedRecordings: 0,
        trashRecordings: 0,
        favoriteRecordings: 0,
        pinnedRecordings: 0,
        storageStats: null,
        storageProbeSucceeded: false,
        recorderStatus: 'idle',
        inputDeviceCount: null,
        inputProbeSucceeded: false,
        customInputSelected: false,
        settings: settings,
      );
      final decoded = report.toJsonObject();
      final storage = decoded['storage'] as Map<String, Object?>;
      final recorder = decoded['recorder'] as Map<String, Object?>;

      expect(storage['probeSucceeded'], isFalse);
      expect(storage['totalManagedBytes'], isNull);
      expect(recorder['inputProbeSucceeded'], isFalse);
      expect(recorder['inputDeviceCount'], isNull);
      expect(report.toMarkdown(), contains('unavailable'));
    });
  });
}
