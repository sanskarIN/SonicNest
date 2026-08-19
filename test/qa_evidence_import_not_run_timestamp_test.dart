import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sonic_nest/models/qa_evidence.dart';
import 'package:sonic_nest/services/qa_evidence_import_service.dart';
import 'package:sonic_nest/services/qa_evidence_report_service.dart';

void main() {
  test('not-run imported checks cannot carry stale result timestamps', () {
    const importer = QaEvidenceImportService();
    const reporter = QaEvidenceReportService();
    final startedAt = DateTime.utc(2026, 8, 19, 10);
    final bundle = jsonDecode(
      reporter
          .build(
            generatedAt: startedAt.add(const Duration(minutes: 1)),
            session: QaEvidenceSession.fresh(startedAt),
          )
          .toPrettyJson(),
    ) as Map<String, dynamic>;
    final checks = bundle['checks'] as List<dynamic>;
    final first = checks.first as Map<String, dynamic>;
    expect(first['status'], QaEvidenceStatus.notRun.name);
    first['updatedAtUtc'] = startedAt.toIso8601String();

    expect(
      () => importer.mergeBundle(
        source: jsonEncode(bundle),
        currentSession: QaEvidenceSession.fresh(startedAt),
      ),
      throwsA(
        isA<QaEvidenceImportException>().having(
          (error) => error.message,
          'message',
          contains('must not carry a result timestamp'),
        ),
      ),
    );
  });
}
