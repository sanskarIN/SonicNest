import 'package:flutter_test/flutter_test.dart';
import 'package:sonic_nest/models/qa_evidence.dart';

void main() {
  test('status updates do not move the QA session clock backwards', () {
    final startedAt = DateTime.utc(2026, 8, 19, 8);
    final firstUpdate = startedAt.add(const Duration(minutes: 10));
    var session = QaEvidenceSession.fresh(startedAt).withStatus(
      checkId: 'first',
      status: QaEvidenceStatus.passed,
      changedAt: firstUpdate,
    );

    session = session.withStatus(
      checkId: 'second',
      status: QaEvidenceStatus.failed,
      changedAt: startedAt.add(const Duration(minutes: 5)),
    );

    expect(session.updatedAtUtc, firstUpdate);
    expect(session.resultFor('second')?.updatedAtUtc, firstUpdate);
  });

  test('resetting a check after a backward clock shift stays monotonic', () {
    final startedAt = DateTime.utc(2026, 8, 19, 8);
    final firstUpdate = startedAt.add(const Duration(minutes: 10));
    var session = QaEvidenceSession.fresh(startedAt).withStatus(
      checkId: 'check',
      status: QaEvidenceStatus.blocked,
      changedAt: firstUpdate,
    );

    session = session.withStatus(
      checkId: 'check',
      status: QaEvidenceStatus.notRun,
      changedAt: startedAt.add(const Duration(minutes: 2)),
    );

    expect(session.updatedAtUtc, firstUpdate);
    expect(session.statusFor('check'), QaEvidenceStatus.notRun);
  });
}
