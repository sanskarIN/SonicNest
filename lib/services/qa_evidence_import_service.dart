import 'dart:convert';

import '../core/constants.dart';
import '../models/qa_check_catalog.dart';
import '../models/qa_evidence.dart';
import 'qa_evidence_report_service.dart';

class QaEvidenceImportException implements Exception {
  const QaEvidenceImportException(this.message);

  final String message;

  @override
  String toString() => 'QaEvidenceImportException: $message';
}

class QaEvidenceImportResult {
  const QaEvidenceImportResult({
    required this.mergedSession,
    required this.sourceGeneratedAtUtc,
    required this.sourceAssessedChecks,
    required this.addedChecks,
    required this.updatedChecks,
    required this.ignoredChecks,
  });

  final QaEvidenceSession mergedSession;
  final DateTime sourceGeneratedAtUtc;
  final int sourceAssessedChecks;
  final int addedChecks;
  final int updatedChecks;
  final int ignoredChecks;

  int get changedChecks => addedChecks + updatedChecks;
  bool get hasChanges => changedChecks > 0;
}

class QaEvidenceImportService {
  const QaEvidenceImportService();

  static const _privacyKeys = <String>{
    'containsRecordingContent',
    'containsRecordingTitles',
    'containsFilePaths',
    'containsNotesTagsOrBookmarks',
    'containsInputDeviceNames',
    'containsFreeFormTesterNotes',
  };

  QaEvidenceImportResult mergeBundle({
    required String source,
    required QaEvidenceSession currentSession,
  }) {
    final root = _decodeRoot(source);
    if (root['schemaVersion'] != QaEvidenceBundle.schemaVersion) {
      throw const QaEvidenceImportException(
        'The evidence bundle schema is unsupported by this SonicNest build.',
      );
    }

    final generatedAt = _timestamp(root['generatedAtUtc'], 'generatedAtUtc');
    _validateApp(root['app']);
    _validatePrivacy(root['privacy']);

    final session = _map(root['session'], 'session');
    if (session['schemaVersion'] != QaEvidenceSession.schemaVersion) {
      throw const QaEvidenceImportException(
        'The evidence session schema is unsupported by this SonicNest build.',
      );
    }
    final startedAt = _timestamp(session['startedAtUtc'], 'session.startedAtUtc');
    final updatedAt = _timestamp(session['updatedAtUtc'], 'session.updatedAtUtc');
    if (updatedAt.isBefore(startedAt)) {
      throw const QaEvidenceImportException(
        'The evidence session update time is before its start time.',
      );
    }
    if (generatedAt.isBefore(updatedAt)) {
      throw const QaEvidenceImportException(
        'The evidence bundle was generated before its latest session update.',
      );
    }

    final rawChecks = root['checks'];
    if (rawChecks is! List) {
      throw const QaEvidenceImportException(
        'The evidence bundle does not contain a valid checks list.',
      );
    }

    final definitions = {
      for (final definition in QaCheckCatalog.checks)
        definition.id: definition,
    };
    final seenIds = <String>{};
    final importedResults = <String, QaCheckResult>{};
    var passed = 0;
    var failed = 0;
    var blocked = 0;
    var notRun = 0;

    for (var index = 0; index < rawChecks.length; index++) {
      final check = _map(rawChecks[index], 'checks[$index]');
      final id = check['id'];
      if (id is! String || id.isEmpty) {
        throw QaEvidenceImportException(
          'checks[$index] does not contain a valid check ID.',
        );
      }
      final definition = definitions[id];
      if (definition == null) {
        throw QaEvidenceImportException(
          'The evidence bundle contains an unknown check ID: $id.',
        );
      }
      if (!seenIds.add(id)) {
        throw QaEvidenceImportException(
          'The evidence bundle contains the check ID more than once: $id.',
        );
      }
      if (check['category'] != definition.categoryId ||
          check['requiresPhysicalTarget'] != definition.requiresPhysicalTarget ||
          check['requiresExternalTooling'] != definition.requiresExternalTooling) {
        throw QaEvidenceImportException(
          'The evidence definition for $id does not match the current QA catalog.',
        );
      }

      final status = QaEvidenceStatus.tryParse(check['status']);
      if (status == null) {
        throw QaEvidenceImportException(
          'The evidence status for $id is invalid.',
        );
      }
      final rawTimestamp = check['updatedAtUtc'];
      if (status == QaEvidenceStatus.notRun) {
        if (rawTimestamp != null) {
          throw QaEvidenceImportException(
            'Not-run evidence for $id must not carry a result timestamp.',
          );
        }
        notRun++;
        continue;
      }

      final resultTimestamp = _timestamp(
        rawTimestamp,
        'checks[$index].updatedAtUtc',
      );
      if (resultTimestamp.isBefore(startedAt) ||
          resultTimestamp.isAfter(updatedAt)) {
        throw QaEvidenceImportException(
          'The evidence timestamp for $id falls outside the session timeline.',
        );
      }
      importedResults[id] = QaCheckResult(
        status: status,
        updatedAtUtc: resultTimestamp,
      );
      if (status == QaEvidenceStatus.passed) {
        passed++;
      } else if (status == QaEvidenceStatus.failed) {
        failed++;
      } else if (status == QaEvidenceStatus.blocked) {
        blocked++;
      }
    }

    if (seenIds.length != QaCheckCatalog.checkIds.length ||
        !seenIds.containsAll(QaCheckCatalog.checkIds)) {
      throw const QaEvidenceImportException(
        'The evidence bundle does not contain the complete current QA catalog.',
      );
    }

    final assessed = passed + failed + blocked;
    _validateSummary(
      root['summary'],
      total: QaCheckCatalog.checks.length,
      assessed: assessed,
      passed: passed,
      failed: failed,
      blocked: blocked,
      notRun: notRun,
    );

    var added = 0;
    var updated = 0;
    var ignored = 0;
    for (final entry in importedResults.entries) {
      final current = currentSession.resultFor(entry.key);
      if (current == null) {
        added++;
      } else if (entry.value.updatedAtUtc.isAfter(current.updatedAtUtc)) {
        updated++;
      } else {
        ignored++;
      }
    }

    final merged = currentSession.mergingNewerResults(
      candidates: importedResults,
      allowedCheckIds: QaCheckCatalog.checkIds,
      candidateStartedAtUtc: startedAt,
    );

    return QaEvidenceImportResult(
      mergedSession: merged,
      sourceGeneratedAtUtc: generatedAt,
      sourceAssessedChecks: assessed,
      addedChecks: added,
      updatedChecks: updated,
      ignoredChecks: ignored,
    );
  }

  Map<String, Object?> _decodeRoot(String source) {
    Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException catch (error) {
      throw QaEvidenceImportException(
        'The selected file is not valid JSON: ${error.message}',
      );
    }
    return _map(decoded, 'root');
  }

  void _validateApp(Object? value) {
    final app = _map(value, 'app');
    if (app['name'] != AppConstants.appName) {
      throw const QaEvidenceImportException(
        'The selected evidence file was not produced for SonicNest.',
      );
    }
    if (app['version'] != AppConstants.appVersionWithBuild) {
      throw QaEvidenceImportException(
        'Evidence from app version ${app['version']} cannot be merged into ${AppConstants.appVersionWithBuild}.',
      );
    }
  }

  void _validatePrivacy(Object? value) {
    final privacy = _map(value, 'privacy');
    for (final key in _privacyKeys) {
      if (privacy[key] != false) {
        throw QaEvidenceImportException(
          'The evidence privacy contract is invalid for $key.',
        );
      }
    }
  }

  void _validateSummary(
    Object? value, {
    required int total,
    required int assessed,
    required int passed,
    required int failed,
    required int blocked,
    required int notRun,
  }) {
    final summary = _map(value, 'summary');
    final expected = <String, Object>{
      'totalChecks': total,
      'assessedChecks': assessed,
      'passed': passed,
      'failed': failed,
      'blocked': blocked,
      'notRun': notRun,
      'allPassed': passed == total,
    };
    for (final entry in expected.entries) {
      if (summary[entry.key] != entry.value) {
        throw QaEvidenceImportException(
          'The evidence summary is inconsistent for ${entry.key}.',
        );
      }
    }
  }

  Map<String, Object?> _map(Object? value, String field) {
    if (value is! Map) {
      throw QaEvidenceImportException('$field must be a JSON object.');
    }
    try {
      return Map<String, Object?>.from(value);
    } on TypeError {
      throw QaEvidenceImportException(
        '$field contains a non-string JSON object key.',
      );
    }
  }

  DateTime _timestamp(Object? value, String field) {
    if (value is! String) {
      throw QaEvidenceImportException('$field must be a timestamp string.');
    }
    final parsed = DateTime.tryParse(value);
    if (parsed == null || !parsed.isUtc) {
      throw QaEvidenceImportException(
        '$field must include an explicit UTC offset.',
      );
    }
    return parsed.toUtc();
  }
}