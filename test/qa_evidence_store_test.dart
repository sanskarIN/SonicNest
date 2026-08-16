import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sonic_nest/models/qa_evidence.dart';
import 'package:sonic_nest/services/qa_evidence_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('QaEvidenceStore', () {
    const store = QaEvidenceStore();
    final now = DateTime.utc(2026, 8, 16, 8, 30);

    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('persists and reloads known catalog results', () async {
      final session = QaEvidenceSession.fresh(now).withStatus(
        checkId: 'talkback_audit',
        status: QaEvidenceStatus.passed,
        changedAt: now.add(const Duration(minutes: 1)),
      );

      await store.save(session);
      final loaded = await store.load(now: DateTime.utc(2030));

      expect(loaded.startedAtUtc, now);
      expect(loaded.statusFor('talkback_audit'), QaEvidenceStatus.passed);
    });

    test('drops unknown check IDs on load', () async {
      final raw = jsonEncode({
        'schemaVersion': 1,
        'startedAtUtc': now.toIso8601String(),
        'updatedAtUtc': now.toIso8601String(),
        'results': {
          'talkback_audit': {
            'status': 'passed',
            'updatedAtUtc': now.toIso8601String(),
          },
          'removed_future_or_stale_check': {
            'status': 'failed',
            'updatedAtUtc': now.toIso8601String(),
          },
        },
      });
      SharedPreferences.setMockInitialValues({QaEvidenceStore.storageKey: raw});

      final loaded = await store.load(now: now);

      expect(loaded.results.containsKey('talkback_audit'), isTrue);
      expect(
        loaded.results.containsKey('removed_future_or_stale_check'),
        isFalse,
      );
    });

    test('malformed persisted JSON becomes a fresh session', () async {
      SharedPreferences.setMockInitialValues({
        QaEvidenceStore.storageKey: 'definitely-not-json',
      });

      final loaded = await store.load(now: now);

      expect(loaded.startedAtUtc, now);
      expect(loaded.updatedAtUtc, now);
      expect(loaded.results, isEmpty);
    });

    test('reset clears persisted statuses and starts a new session', () async {
      final session = QaEvidenceSession.fresh(now).withStatus(
        checkId: 'windows_secondary_click',
        status: QaEvidenceStatus.failed,
        changedAt: now.add(const Duration(minutes: 1)),
      );
      await store.save(session);

      final resetAt = now.add(const Duration(hours: 1));
      final reset = await store.reset(now: resetAt);
      final reloaded = await store.load(now: resetAt);

      expect(reset.startedAtUtc, resetAt);
      expect(reset.results, isEmpty);
      expect(reloaded.startedAtUtc, resetAt);
      expect(reloaded.results, isEmpty);
    });
  });
}
