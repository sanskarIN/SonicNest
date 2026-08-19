import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sonic_nest/models/qa_evidence.dart';
import 'package:sonic_nest/services/qa_evidence_import_service.dart';
import 'package:sonic_nest/services/qa_evidence_report_service.dart';

void main() {
  const importer = QaEvidenceImportService();
  const reporter = QaEvidenceReportService();
  final startedAt = DateTime.utc(2026, 8, 19, 9);

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

  test('rejects malformed JSON before any merge is attempted', () {
    expect(
      () => importer.mergeBundle(
        source: '{not-json',
        currentSession: QaEvidenceSession.fresh(startedAt),
      ),
      throwsA(
        isA<QaEvidenceImportException>().having(
          (error) => error.message,
          'message',
          contains('not valid JSON'),
        ),
      ),
    );
  });

  test('rejects a bundle generated before its latest session update', () {
    final bundle = validBundle();
    bundle['generatedAtUtc'] = startedAt.add(const Duration(minutes: 4)).toIso8601String();

    expect(
      () => importer.mergeBundle(
        source: jsonEncode(bundle),
        currentSession: QaEvidenceSession.fresh(startedAt),
      ),
      throwsA(
        isA<QaEvidenceImportException>().having(
          (error) => error.message,
          'message',
          contains('generated before its latest session update'),
        ),
      ),
    );
  });

  test('rejects tampered catalog metadata even when the check ID is valid', () {
    final bundle = validBundle();
    final checks = bundle['checks'] as List<dynamic>;
    final first = checks.first as Map<String, dynamic>;
    first['requiresPhysicalTarget'] = !(first['requiresPhysicalTarget'] as bool);

    expect(
      () => importer.mergeBundle(
        source: jsonEncode(bundle),
        currentSession: QaEvidenceSession.fresh(startedAt),
      ),
      throwsA(
        isA<QaEvidenceImportException>().having(
          (error) => error.message,
          'message',
          contains('does not match the current QA catalog'),
        ),
      ),
    );
  });
}
