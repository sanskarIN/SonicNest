import 'package:flutter_test/flutter_test.dart';
import 'package:sonic_nest/models/qa_evidence.dart';

void main() {
  test('rejects a persisted QA session whose timeline moves backwards', () {
    final fallback = DateTime.utc(2026, 8, 16, 8);
    final decoded = QaEvidenceSession.fromJson(
      '{"schemaVersion":1,"startedAtUtc":"2026-08-16T08:00:00Z","updatedAtUtc":"2026-08-16T07:59:59Z","results":{}}',
      fallbackNow: fallback,
    );

    expect(decoded.startedAtUtc, fallback);
    expect(decoded.updatedAtUtc, fallback);
    expect(decoded.results, isEmpty);
  });

  test('drops persisted results outside the declared session timeline', () {
    final decoded = QaEvidenceSession.fromJson(
      '{"schemaVersion":1,"startedAtUtc":"2026-08-16T08:00:00Z","updatedAtUtc":"2026-08-16T09:00:00Z","results":{"too_early":{"status":"passed","updatedAtUtc":"2026-08-16T07:59:59Z"},"valid":{"status":"failed","updatedAtUtc":"2026-08-16T08:30:00Z"},"too_late":{"status":"blocked","updatedAtUtc":"2026-08-16T09:00:01Z"}}}',
      fallbackNow: DateTime.utc(2030),
    );

    expect(decoded.results.keys, ['valid']);
    expect(decoded.statusFor('valid'), QaEvidenceStatus.failed);
  });
}