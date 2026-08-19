import 'package:flutter_test/flutter_test.dart';
import 'package:sonic_nest/models/qa_evidence.dart';
import 'package:sonic_nest/services/qa_evidence_import_service.dart';
import 'package:sonic_nest/services/qa_evidence_report_service.dart';

void main() {
  const importer = QaEvidenceImportService();
  const reporter = QaEvidenceReportService();

  test('valid same-version bundle adds and updates only newer evidence', () {
    final currentStart = DateTime.utc(2026, 8, 19, 8);
    var current = QaEvidenceSession.fresh(currentStart);
    current = current.withStatus(
      checkId: 'android_microphone_permission',
      status: QaEvidenceStatus.failed,
      changedAt: DateTime.utc(2026, 8, 19, 8, 10),
    );

    var imported = QaEvidenceSession.fresh(DateTime.utc(2026, 8, 19, 7));
    imported = imported.withStatus(
      checkId: 'android_microphone_permission',
      status: QaEvidenceStatus.passed,
      changedAt: DateTime.utc(2026, 8, 19, 8, 20),
    );
    imported = imported.withStatus(
      checkId: 'talkback_audit',
      status: QaEvidenceStatus.blocked,
      changedAt: DateTime.utc(2026, 8, 19, 8, 30),
    );
    final bundle = reporter.build(
      generatedAt: DateTime.utc(2026, 8, 19, 8, 35),
      session: imported,
    );

    final result = importer.mergeBundle(
      source: bundle.toPrettyJson(),
      currentSession: current,
    );

    expect(result.sourceAssessedChecks, 2);
    expect(result.addedChecks, 1);
    expect(result.updatedChecks, 1);
    expect(result.ignoredChecks, 0);
    expect(result.changedChecks, 2);
    expect(result.hasChanges, isTrue);
    expect(
      result.mergedSession.statusFor('android_microphone_permission'),
      QaEvidenceStatus.passed,
    );
    expect(
      result.mergedSession.statusFor('talkback_audit'),
      QaEvidenceStatus.blocked,
    );
    expect(result.mergedSession.startedAtUtc, DateTime.utc(2026, 8, 19, 7));
    expect(result.mergedSession.updatedAtUtc, DateTime.utc(2026, 8, 19, 8, 30));
  });

  test('older imported evidence never overwrites newer local evidence', () {
    final startedAt = DateTime.utc(2026, 8, 19, 8);
    final current = QaEvidenceSession.fresh(startedAt).withStatus(
      checkId: 'talkback_audit',
      status: QaEvidenceStatus.passed,
      changedAt: DateTime.utc(2026, 8, 19, 9),
    );
    final imported = QaEvidenceSession.fresh(startedAt).withStatus(
      checkId: 'talkback_audit',
      status: QaEvidenceStatus.failed,
      changedAt: DateTime.utc(2026, 8, 19, 8, 30),
    );
    final bundle = reporter.build(
      generatedAt: DateTime.utc(2026, 8, 19, 8, 40),
      session: imported,
    );

    final result = importer.mergeBundle(
      source: bundle.toPrettyJson(),
      currentSession: current,
    );

    expect(result.addedChecks, 0);
    expect(result.updatedChecks, 0);
    expect(result.ignoredChecks, 1);
    expect(result.hasChanges, isFalse);
    expect(
      result.mergedSession.statusFor('talkback_audit'),
      QaEvidenceStatus.passed,
    );
    expect(identical(result.mergedSession, current), isTrue);
  });

  test('imported not-run state never clears local assessed evidence', () {
    final startedAt = DateTime.utc(2026, 8, 19, 8);
    final current = QaEvidenceSession.fresh(startedAt).withStatus(
      checkId: 'windows_microphone_capture',
      status: QaEvidenceStatus.passed,
      changedAt: DateTime.utc(2026, 8, 19, 8, 5),
    );
    final imported = QaEvidenceSession.fresh(DateTime.utc(2026, 8, 19, 7));
    final bundle = reporter.build(
      generatedAt: DateTime.utc(2026, 8, 19, 8, 10),
      session: imported,
    );

    final result = importer.mergeBundle(
      source: bundle.toPrettyJson(),
      currentSession: current,
    );

    expect(result.sourceAssessedChecks, 0);
    expect(result.changedChecks, 0);
    expect(
      result.mergedSession.statusFor('windows_microphone_capture'),
      QaEvidenceStatus.passed,
    );
    expect(identical(result.mergedSession, current), isTrue);
  });
}