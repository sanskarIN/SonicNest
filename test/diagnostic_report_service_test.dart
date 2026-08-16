import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sonic_nest/models/recording_settings.dart';
import 'package:sonic_nest/services/diagnostic_report_service.dart';
import 'package:sonic_nest/services/settings_service.dart';
import 'package:sonic_nest/services/storage_service.dart';

void main() {
  group('DiagnosticReportService', () {
    const service = DiagnosticReportService();

    DiagnosticReport buildReport({StorageStats? storageStats}) {
      final recording = RecordingSettings.forPreset(QualityPreset.podcast)
          .copyWith(
            namingPrefix: 'PRIVATE_PREFIX_DO_NOT_EXPORT',
            namingTemplate: 'PRIVATE_TEMPLATE_DO_NOT_EXPORT',
            namingSuffix: 'PRIVATE_SUFFIX_DO_NOT_EXPORT',
            namingCategory: 'PRIVATE_CATEGORY_DO_NOT_EXPORT',
          );
      final settings = SettingsSnapshot.defaults().copyWith(
        recording: recording,
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
      expect((decoded['app'] as Map<String, dynamic>)['name'], 'SonicNest');
      expect((decoded['app'] as Map<String, dynamic>)['version'], '0.1.0+1');
      expect(
        (decoded['library'] as Map<String, dynamic>)['savedRecordings'],
        12,
      );
      expect(
        (decoded['storage'] as Map<String, dynamic>)['totalManagedBytes'],
        1250,
      );
      expect(
        (decoded['recorder'] as Map<String, dynamic>)['selectedInput'],
        'custom',
      );
      expect(
        ((decoded['settings'] as Map<String, dynamic>)['recording']
            as Map<String, dynamic>)['preset'],
        'podcast',
      );
    });

    test('explicitly declares every privacy-sensitive field as excluded', () {
      final privacy =
          buildReport().toJsonObject()['privacy'] as Map<String, Object?>;

      expect(
        privacy,
        equals(const {
          'containsRecordingContent': false,
          'containsRecordingTitles': false,
          'containsFilePaths': false,
          'containsNotesTagsOrBookmarks': false,
          'containsInputDeviceNames': false,
        }),
      );
    });

    test('does not serialize private naming text or recording metadata', () {
      final report = buildReport();
      final json = report.toPrettyJson();
      final markdown = report.toMarkdown();

      for (final secret in const [
        'PRIVATE_PREFIX_DO_NOT_EXPORT',
        'PRIVATE_TEMPLATE_DO_NOT_EXPORT',
        'PRIVATE_SUFFIX_DO_NOT_EXPORT',
        'PRIVATE_CATEGORY_DO_NOT_EXPORT',
      ]) {
        expect(json, isNot(contains(secret)));
        expect(markdown, isNot(contains(secret)));
      }
      expect(json, isNot(contains('namingPrefix')));
      expect(json, isNot(contains('namingTemplate')));
      expect(json, isNot(contains('namingSuffix')));
      expect(json, isNot(contains('namingCategory')));
      expect(markdown, contains('Recording content: not included'));
      expect(markdown, contains('Input-device names: not included'));
    });

    test(
      'represents failed storage and input probes without inventing values',
      () {
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
      },
    );
  });
}
