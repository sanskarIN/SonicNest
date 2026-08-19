import 'package:flutter_test/flutter_test.dart';
import 'package:sonic_nest/models/qa_evidence.dart';

void main() {
  final startedAt = DateTime.utc(2026, 8, 16, 7, 30);

  test('merge accepts only newer allowed assessed results', () {
    final currentAt = startedAt.add(const Duration(minutes: 20));
    var current = QaEvidenceSession.fresh(startedAt).withStatus(
      checkId: 'same',
      status: QaEvidenceStatus.passed,
      changedAt: currentAt,
    );
    current = current.withStatus(
      checkId: 'newer_current',
      status: QaEvidenceStatus.failed,
      changedAt: currentAt.add(const Duration(minutes: 1)),
    );

    final importedStart = startedAt.subtract(const Duration(hours: 1));
    final merged = current.mergingNewerResults(
      candidates: {
        'same': QaCheckResult(
          status: QaEvidenceStatus.blocked,
          updatedAtUtc: currentAt,
        ),
        'newer_current': QaCheckResult(
          status: QaEvidenceStatus.passed,
          updatedAtUtc: currentAt.subtract(const Duration(minutes: 1)),
        ),
        'added': QaCheckResult(
          status: QaEvidenceStatus.passed,
          updatedAtUtc: currentAt.add(const Duration(minutes: 5)),
        ),
        'stale_id': QaCheckResult(
          status: QaEvidenceStatus.failed,
          updatedAtUtc: currentAt.add(const Duration(minutes: 6)),
        ),
        'not_run': QaCheckResult(
          status: QaEvidenceStatus.notRun,
          updatedAtUtc: currentAt.add(const Duration(minutes: 7)),
        ),
      },
      allowedCheckIds: const {'same', 'newer_current', 'added', 'not_run'},
      candidateStartedAtUtc: importedStart,
    );

    expect(merged.statusFor('same'), QaEvidenceStatus.passed);
    expect(merged.statusFor('newer_current'), QaEvidenceStatus.failed);
    expect(merged.statusFor('added'), QaEvidenceStatus.passed);
    expect(merged.statusFor('stale_id'), QaEvidenceStatus.notRun);
    expect(merged.statusFor('not_run'), QaEvidenceStatus.notRun);
    expect(merged.startedAtUtc, importedStart);
    expect(merged.updatedAtUtc, currentAt.add(const Duration(minutes: 5)));
  });

  test('merge leaves the session untouched when no candidate is newer', () {
    final changedAt = startedAt.add(const Duration(minutes: 5));
    final current = QaEvidenceSession.fresh(startedAt).withStatus(
      checkId: 'check',
      status: QaEvidenceStatus.passed,
      changedAt: changedAt,
    );

    final merged = current.mergingNewerResults(
      candidates: {
        'check': QaCheckResult(
          status: QaEvidenceStatus.failed,
          updatedAtUtc: changedAt.subtract(const Duration(seconds: 1)),
        ),
      },
      allowedCheckIds: const {'check'},
      candidateStartedAtUtc: startedAt.subtract(const Duration(days: 1)),
    );

    expect(identical(merged, current), isTrue);
  });
}
