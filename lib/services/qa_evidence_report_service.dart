import 'dart:convert';

import '../core/constants.dart';
import '../models/qa_check_catalog.dart';
import '../models/qa_evidence.dart';
import 'diagnostic_report_service.dart';

class QaEvidenceBundle {
  const QaEvidenceBundle._({
    required this.generatedAtUtc,
    required this.session,
    required this.diagnostics,
  });

  static const schemaVersion = 1;

  final DateTime generatedAtUtc;
  final QaEvidenceSession session;
  final DiagnosticReport? diagnostics;

  int count(QaEvidenceStatus status) => QaCheckCatalog.checks
      .where((check) => session.statusFor(check.id) == status)
      .length;

  int get totalChecks => QaCheckCatalog.checks.length;
  int get passedChecks => count(QaEvidenceStatus.passed);
  int get failedChecks => count(QaEvidenceStatus.failed);
  int get blockedChecks => count(QaEvidenceStatus.blocked);
  int get notRunChecks => count(QaEvidenceStatus.notRun);
  int get assessedChecks => totalChecks - notRunChecks;

  Map<String, Object?> toJsonObject() => {
    'schemaVersion': schemaVersion,
    'generatedAtUtc': generatedAtUtc.toUtc().toIso8601String(),
    'privacy': const {
      'containsRecordingContent': false,
      'containsRecordingTitles': false,
      'containsFilePaths': false,
      'containsNotesTagsOrBookmarks': false,
      'containsInputDeviceNames': false,
      'containsFreeFormTesterNotes': false,
    },
    'app': {
      'name': AppConstants.appName,
      'version': AppConstants.appVersionWithBuild,
    },
    'summary': {
      'totalChecks': totalChecks,
      'assessedChecks': assessedChecks,
      'passed': passedChecks,
      'failed': failedChecks,
      'blocked': blockedChecks,
      'notRun': notRunChecks,
      'allPassed': passedChecks == totalChecks,
    },
    'session': {
      'schemaVersion': QaEvidenceSession.schemaVersion,
      'startedAtUtc': session.startedAtUtc.toUtc().toIso8601String(),
      'updatedAtUtc': session.updatedAtUtc.toUtc().toIso8601String(),
    },
    'checks': [
      for (final definition in QaCheckCatalog.checks) _checkJson(definition),
    ],
    if (diagnostics != null) 'diagnostics': diagnostics!.toJsonObject(),
  };

  Map<String, Object?> _checkJson(QaCheckDefinition definition) {
    final result = session.resultFor(definition.id);
    return {
      'id': definition.id,
      'category': definition.categoryId,
      'status': session.statusFor(definition.id).name,
      'updatedAtUtc': result?.updatedAtUtc.toUtc().toIso8601String(),
      'requiresPhysicalTarget': definition.requiresPhysicalTarget,
      'requiresExternalTooling': definition.requiresExternalTooling,
    };
  }

  String toPrettyJson() =>
      const JsonEncoder.withIndent('  ').convert(toJsonObject());

  String toMarkdown() {
    final buffer = StringBuffer()
      ..writeln('# ${AppConstants.appName} Manual QA Evidence')
      ..writeln()
      ..writeln('Generated (UTC): ${generatedAtUtc.toUtc().toIso8601String()}')
      ..writeln('App version: ${AppConstants.appVersionWithBuild}')
      ..writeln(
        'Session started (UTC): ${session.startedAtUtc.toUtc().toIso8601String()}',
      )
      ..writeln(
        'Session updated (UTC): ${session.updatedAtUtc.toUtc().toIso8601String()}',
      )
      ..writeln()
      ..writeln('## Privacy')
      ..writeln()
      ..writeln('- Recording content: not included')
      ..writeln('- Recording titles and file paths: not included')
      ..writeln('- Notes, tags, bookmarks, and naming text: not included')
      ..writeln('- Input-device names: not included')
      ..writeln('- Free-form tester notes: not collected')
      ..writeln()
      ..writeln('## Summary')
      ..writeln()
      ..writeln('- Total checks: $totalChecks')
      ..writeln('- Assessed: $assessedChecks')
      ..writeln('- Passed: $passedChecks')
      ..writeln('- Failed: $failedChecks')
      ..writeln('- Blocked: $blockedChecks')
      ..writeln('- Not run: $notRunChecks');

    for (final category in QaCheckCatalog.categories) {
      buffer
        ..writeln()
        ..writeln('## ${category.evidenceLabel}')
        ..writeln();
      for (final definition in QaCheckCatalog.checksForCategory(category.id)) {
        final result = session.resultFor(definition.id);
        final status = session.statusFor(definition.id);
        buffer.write('- ${_statusMarker(status)} ${definition.evidenceLabel}');
        if (result != null) {
          buffer.write(
            ' — updated ${result.updatedAtUtc.toUtc().toIso8601String()}',
          );
        }
        buffer.writeln();
      }
    }

    final diagnosticReport = diagnostics;
    if (diagnosticReport != null) {
      buffer
        ..writeln()
        ..writeln('---')
        ..writeln()
        ..writeln('## Attached privacy-safe diagnostics')
        ..writeln()
        ..writeln(
          'The following diagnostic snapshot was collected by SonicNest and contains only the fields allowed by the Diagnostics & QA privacy contract.',
        )
        ..writeln()
        ..writeln('```json')
        ..writeln(diagnosticReport.toPrettyJson())
        ..writeln('```');
    }

    return buffer.toString();
  }

  static String _statusMarker(QaEvidenceStatus status) {
    switch (status) {
      case QaEvidenceStatus.notRun:
        return '[NOT RUN]';
      case QaEvidenceStatus.passed:
        return '[PASS]';
      case QaEvidenceStatus.failed:
        return '[FAIL]';
      case QaEvidenceStatus.blocked:
        return '[BLOCKED]';
    }
  }
}

class QaEvidenceReportService {
  const QaEvidenceReportService();

  QaEvidenceBundle build({
    required DateTime generatedAt,
    required QaEvidenceSession session,
    DiagnosticReport? diagnostics,
  }) {
    return QaEvidenceBundle._(
      generatedAtUtc: generatedAt.toUtc(),
      session: session.keepingOnly(QaCheckCatalog.checkIds),
      diagnostics: diagnostics,
    );
  }
}
