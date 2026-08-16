import 'package:shared_preferences/shared_preferences.dart';

import '../models/qa_check_catalog.dart';
import '../models/qa_evidence.dart';

class QaEvidenceStore {
  const QaEvidenceStore();

  static const storageKey = 'sonicnest.qaEvidenceSession.v1';

  Future<QaEvidenceSession> load({DateTime? now}) async {
    final fallbackNow = now ?? DateTime.now();
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(storageKey);
    if (encoded == null || encoded.trim().isEmpty) {
      return QaEvidenceSession.fresh(fallbackNow);
    }
    return QaEvidenceSession.fromJson(
      encoded,
      fallbackNow: fallbackNow,
    ).keepingOnly(QaCheckCatalog.checkIds);
  }

  Future<void> save(QaEvidenceSession session) async {
    final preferences = await SharedPreferences.getInstance();
    final sanitized = session.keepingOnly(QaCheckCatalog.checkIds);
    final stored = await preferences.setString(storageKey, sanitized.toJson());
    if (!stored) {
      throw StateError('Shared preferences rejected QA evidence persistence.');
    }
  }

  Future<QaEvidenceSession> reset({DateTime? now}) async {
    final preferences = await SharedPreferences.getInstance();
    final removed = await preferences.remove(storageKey);
    if (!removed && preferences.containsKey(storageKey)) {
      throw StateError('Could not clear the persisted QA evidence session.');
    }
    return QaEvidenceSession.fresh(now ?? DateTime.now());
  }
}
