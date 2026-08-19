import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sonic_nest/models/qa_evidence.dart';
import 'package:sonic_nest/services/qa_evidence_import_service.dart';
import 'package:sonic_nest/services/qa_evidence_report_service.dart';

void main() {
  const importer = QaEvidenceImportService();
  const reporter = QaEvidenceReportService();
  final startedAt = DateTime.utc(2026, 8, 19, 11);

  Map<String, dynamic> assessedBundle() {
    final session = QaEvidenceSession.fresh(startedAt).withStatus(
      checkId: 'android_microphone_permission',
      status: QaEvidenceStatus.passed,
      changedAt: startedAt.add(const Duration(minutes: 2)),
    );
    return jsonDecode(
      reporter
          .build(
            generatedAt: startedAt.add(const Duration(minutes: 3)),
            session: session,
          )
          .toPrettyJson(),
    ) as Map<String, dynamic>;
  }

  test('rejects a session result whose status contradicts the check list', () {
    final bundle = assessedBundle();
    final session = bundle['session'] as Map<String, dynamic>;
    final results = session['results'] as Map<String, dynamic>;
    final result =
        results['android_microphone_permission'] as Map<String, dynamic>;
    result['status'] = QaEvidenceStatus.failed.name;

    expect(
      () => importer.mergeBundle(
        source: jsonEncode(bundle),
        currentSession: QaEvidenceSession.fresh(startedAt),
      ),
      throwsA(
        isA<QaEvidenceImportException>().having(
          (error) => error.message,
          'message',
          contains('does not match the assessed check list'),
        ),
      ),
    );
  });

  test('rejects a missing assessed session result', () {
    final bundle = assessedBundle();
    final session = bundle['session'] as Map<String, dynamic>;
    final results = session['results'] as Map<String, dynamic>;
    results.clear();

    expect(
      () => importer.mergeBundle(
        source: jsonEncode(bundle),
        currentSession: QaEvidenceSession.fresh(startedAt),
      ),
      throwsA(
        isA<QaEvidenceImportException>().having(
          (error) => error.message,
          'message',
          contains('session results do not match'),
        ),
      ),
    );
  });
}
