import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sonic_nest/models/qa_check_catalog.dart';
import 'package:sonic_nest/models/qa_evidence.dart';
import 'package:sonic_nest/models/recording_settings.dart';
import 'package:sonic_nest/services/diagnostic_report_service.dart';
import 'package:sonic_nest/services/qa_evidence_report_service.dart';
import 'package:sonic_nest/services/settings_service.dart';
import 'package:sonic_nest/services/storage_service.dart';

void main() {
  group('QaEvidenceReportService', () {
    const service = QaEvidenceReportService();
    final startedAt = DateTime.utc(2026, 8, 16, 9);

    DiagnosticReport diagnosticReport() {
      final recording = RecordingSettings.forPreset(QualityPreset.podcast)
          .copyWith(
            namingPrefix: 'PRIVATE_QA_PREFIX_DO_NOT_EXPORT',
            namingTemplate: 'PRIVATE_QA_TEMPLATE_DO_NOT_EXPORT',
            namingSuffix: 'PRIVATE_QA_SUFFIX_DO_NOT_EXPORT',
            namingCategory: 'PRIVATE_QA_CATEGORY_DO_NOT_EXPORT',
          );
      final settings = SettingsSnapshot.defaults().copyWith(
        recording: recording,
        themeMode: ThemeMode.dark,
      );
      return const DiagnosticReportService().build(
        generatedAt: DateTime.utc(2026, 8, 16, 9, 5),
        appVersion: '0.1.0+1',
        platform: 'android',
        operatingSystemVersion: 'Android test build',
        localeName: 'en_IN',
        dartVersion: 'test',
        processorCount: 8,
        savedRecordings: 2,
        trashRecordings: 1,
        favoriteRecordings: 1,
        pinnedRecordings: 0,
        storageStats: const StorageStats(
          recordingsBytes: 100,
          trashBytes: 20,
          temporaryBytes: 5,
          recordingCount: 2,
          trashCount: 1,
          temporaryFileCount: 1,
        ),
        storageProbeSucceeded: true,
        recorderStatus: 'idle',
        inputDeviceCount: 2,
        inputProbeSucceeded: true,
        customInputSelected: false,
        settings: settings,
      );
    }

    QaEvidenceSession sampleSession() {
      var session = QaEvidenceSession.fresh(startedAt);
      session = session.withStatus(
        checkId: 'android_microphone_permission',
        status: QaEvidenceStatus.passed,
        changedAt: startedAt.add(const Duration(minutes: 1)),
      );
      session = session.withStatus(
        checkId: 'talkback_audit',
        status: QaEvidenceStatus.failed,
        changedAt: startedAt.add(const Duration(minutes: 2)),
      );
      session = session.withStatus(
        checkId: 'recording_multi_hour',
        status: QaEvidenceStatus.blocked,
        changedAt: startedAt.add(const Duration(minutes: 3)),
      );
      return session;
    }

    test('serializes every catalog check with deterministic summary counts', () {
      final bundle = service.build(
        generatedAt: DateTime.utc(2026, 8, 16, 9, 30),
        session: sampleSession(),
      );
      final decoded = jsonDecode(bundle.toPrettyJson()) as Map<String, dynamic>;
      final summary = decoded['summary'] as Map<String, dynamic>;
      final checks = decoded['checks'] as List<dynamic>;

      expect(decoded['schemaVersion'], QaEvidenceBundle.schemaVersion);
      expect(summary['totalChecks'], QaCheckCatalog.checks.length);
      expect(summary['assessedChecks'], 3);
      expect(summary['passed'], 1);
      expect(summary['failed'], 1);
      expect(summary['blocked'], 1);
      expect(summary['notRun'], QaCheckCatalog.checks.length - 3);
      expect(summary['allPassed'], isFalse);
      expect(checks.length, QaCheckCatalog.checks.length);
    });

    test('declares the evidence bundle privacy boundary explicitly', () {
      final bundle = service.build(
        generatedAt: startedAt,
        session: sampleSession(),
      );
      final privacy = bundle.toJsonObject()['privacy'] as Map<String, Object?>;

      expect(
        privacy,
        equals(const {
          'containsRecordingContent': false,
          'containsRecordingTitles': false,
          'containsFilePaths': false,
          'containsNotesTagsOrBookmarks': false,
          'containsInputDeviceNames': false,
          'containsFreeFormTesterNotes': false,
        }),
      );
    });

    test('can attach diagnostics without leaking private naming text', () {
      final bundle = service.build(
        generatedAt: startedAt,
        session: sampleSession(),
        diagnostics: diagnosticReport(),
      );
      final json = bundle.toPrettyJson();
      final markdown = bundle.toMarkdown();

      for (final secret in const [
        'PRIVATE_QA_PREFIX_DO_NOT_EXPORT',
        'PRIVATE_QA_TEMPLATE_DO_NOT_EXPORT',
        'PRIVATE_QA_SUFFIX_DO_NOT_EXPORT',
        'PRIVATE_QA_CATEGORY_DO_NOT_EXPORT',
      ]) {
        expect(json, isNot(contains(secret)));
        expect(markdown, isNot(contains(secret)));
      }
      expect(json, contains('"diagnostics"'));
      expect(markdown, contains('Attached privacy-safe diagnostics'));
      expect(markdown, contains('[PASS]'));
      expect(markdown, contains('[FAIL]'));
      expect(markdown, contains('[BLOCKED]'));
      expect(markdown, contains('[NOT RUN]'));
      expect(markdown, contains('Free-form tester notes: not collected'));
    });

    test('filters stale session IDs from exported evidence', () {
      var session = sampleSession();
      session = session.withStatus(
        checkId: 'stale_removed_check',
        status: QaEvidenceStatus.failed,
        changedAt: startedAt.add(const Duration(minutes: 4)),
      );

      final json = service
          .build(generatedAt: startedAt, session: session)
          .toPrettyJson();

      expect(json, isNot(contains('stale_removed_check')));
    });
  });
}
