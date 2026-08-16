import 'package:flutter_test/flutter_test.dart';
import 'package:sonic_nest/models/qa_evidence.dart';

void main() {
  group('QaEvidenceSession', () {
    final startedAt = DateTime.utc(2026, 8, 16, 7, 30);

    test('starts with every unknown check represented as not run', () {
      final session = QaEvidenceSession.fresh(startedAt);

      expect(session.startedAtUtc, startedAt);
      expect(session.updatedAtUtc, startedAt);
      expect(session.results, isEmpty);
      expect(session.statusFor('any-check'), QaEvidenceStatus.notRun);
    });

    test('records status changes and removes explicit not-run values', () {
      final passedAt = startedAt.add(const Duration(minutes: 5));
      final resetAt = startedAt.add(const Duration(minutes: 10));
      final passed = QaEvidenceSession.fresh(startedAt).withStatus(
        checkId: 'android_microphone_permission',
        status: QaEvidenceStatus.passed,
        changedAt: passedAt,
      );

      expect(
        passed.statusFor('android_microphone_permission'),
        QaEvidenceStatus.passed,
      );
      expect(
        passed.resultFor('android_microphone_permission')?.updatedAtUtc,
        passedAt,
      );

      final reset = passed.withStatus(
        checkId: 'android_microphone_permission',
        status: QaEvidenceStatus.notRun,
        changedAt: resetAt,
      );
      expect(
        reset.statusFor('android_microphone_permission'),
        QaEvidenceStatus.notRun,
      );
      expect(reset.results, isEmpty);
      expect(reset.updatedAtUtc, resetAt);
    });

    test('round-trips valid results through JSON', () {
      final changedAt = startedAt.add(const Duration(minutes: 3));
      final original = QaEvidenceSession.fresh(startedAt).withStatus(
        checkId: 'talkback_audit',
        status: QaEvidenceStatus.blocked,
        changedAt: changedAt,
      );

      final decoded = QaEvidenceSession.fromJson(
        original.toJson(),
        fallbackNow: DateTime.utc(2030),
      );

      expect(decoded.startedAtUtc, startedAt);
      expect(decoded.updatedAtUtc, changedAt);
      expect(decoded.statusFor('talkback_audit'), QaEvidenceStatus.blocked);
      expect(decoded.resultFor('talkback_audit')?.updatedAtUtc, changedAt);
    });

    test('falls back safely for malformed or unsupported sessions', () {
      final fallback = DateTime.utc(2026, 8, 16, 8);
      final malformed = QaEvidenceSession.fromJson(
        '{not-json',
        fallbackNow: fallback,
      );
      final unsupported = QaEvidenceSession.fromJson(
        '{"schemaVersion":99,"startedAtUtc":"2026-01-01T00:00:00Z","updatedAtUtc":"2026-01-01T00:00:00Z","results":{}}',
        fallbackNow: fallback,
      );

      expect(malformed.startedAtUtc, fallback);
      expect(malformed.results, isEmpty);
      expect(unsupported.startedAtUtc, fallback);
      expect(unsupported.results, isEmpty);
    });

    test(
      'keepingOnly removes stale catalog IDs without changing timestamps',
      () {
        final changedAt = startedAt.add(const Duration(minutes: 2));
        var session = QaEvidenceSession.fresh(startedAt).withStatus(
          checkId: 'valid',
          status: QaEvidenceStatus.passed,
          changedAt: changedAt,
        );
        session = session.withStatus(
          checkId: 'stale',
          status: QaEvidenceStatus.failed,
          changedAt: changedAt,
        );

        final filtered = session.keepingOnly({'valid'});

        expect(filtered.results.keys, ['valid']);
        expect(filtered.startedAtUtc, startedAt);
        expect(filtered.updatedAtUtc, changedAt);
      },
    );
  });
}
