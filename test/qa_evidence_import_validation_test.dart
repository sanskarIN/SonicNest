import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sonic_nest/models/qa_evidence.dart';
import 'package:sonic_nest/services/qa_evidence_import_service.dart';
import 'package:sonic_nest/services/qa_evidence_report_service.dart';

void main() {
  const importer = QaEvidenceImportService();
  const reporter = QaEvidenceReportService();
  final startedAt = DateTime.utc(2026, 8, 19, 8);

  Map<String, dynamic> validBundle() {
    final session = QaEvidenceSession.fresh(startedAt).withStatus(
      checkId: 'android_microphone_permission',
      status: QaEvidenceStatus.passed,
      changedAt: startedAt.add(const Duration(minutes: 5)),
    );
    return jsonDecode(
          reporter
              .build(
                generatedAt: startedAt.add(const Duration(minutes: 10)),
                session: session,
              )
              .toPrettyJson(),
        )
        as Map<String, dynamic>;
  }

  QaEvidenceSession current() => QaEvidenceSession.fresh(startedAt);

  test('rejects evidence from another application version', () {
    final bundle = validBundle();
    final app = bundle['app'] as Map<String, dynamic>;
    app['version'] = '9.9.9+9';

    expect(
      () => importer.mergeBundle(
        source: jsonEncode(bundle),
        currentSession: current(),
      ),
      throwsA(isA<QaEvidenceImportException>()),
    );
  });

  test('rejects evidence whose privacy contract is weakened', () {
    final bundle = validBundle();
    final privacy = bundle['privacy'] as Map<String, dynamic>;
    privacy['containsRecordingContent'] = true;

    expect(
      () => importer.mergeBundle(
        source: jsonEncode(bundle),
        currentSession: current(),
      ),
      throwsA(isA<QaEvidenceImportException>()),
    );
  });

  test('rejects incomplete current-catalog evidence', () {
    final bundle = validBundle();
    final checks = bundle['checks'] as List<dynamic>;
    checks.removeLast();

    expect(
      () => importer.mergeBundle(
        source: jsonEncode(bundle),
        currentSession: current(),
      ),
      throwsA(isA<QaEvidenceImportException>()),
    );
  });

  test('rejects duplicate current-catalog check IDs', () {
    final bundle = validBundle();
    final checks = bundle['checks'] as List<dynamic>;
    checks[1] = Map<String, dynamic>.from(checks.first as Map);

    expect(
      () => importer.mergeBundle(
        source: jsonEncode(bundle),
        currentSession: current(),
      ),
      throwsA(isA<QaEvidenceImportException>()),
    );
  });

  test('rejects inconsistent evidence summary counts', () {
    final bundle = validBundle();
    final summary = bundle['summary'] as Map<String, dynamic>;
    summary['passed'] = 99;

    expect(
      () => importer.mergeBundle(
        source: jsonEncode(bundle),
        currentSession: current(),
      ),
      throwsA(isA<QaEvidenceImportException>()),
    );
  });

  test('rejects assessed timestamps outside the session timeline', () {
    final bundle = validBundle();
    final session = bundle['session'] as Map<String, dynamic>;
    final checks = bundle['checks'] as List<dynamic>;
    final first = checks.first as Map<String, dynamic>;
    first['updatedAtUtc'] = startedAt.subtract(const Duration(seconds: 1)).toIso8601String();
    session['updatedAtUtc'] = startedAt.add(const Duration(minutes: 5)).toIso8601String();

    expect(
      () => importer.mergeBundle(
        source: jsonEncode(bundle),
        currentSession: current(),
      ),
      throwsA(isA<QaEvidenceImportException>()),
    );
  });
}
