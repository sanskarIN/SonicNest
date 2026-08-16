import 'dart:convert';

enum QaEvidenceStatus {
  notRun,
  passed,
  failed,
  blocked;

  static QaEvidenceStatus? tryParse(Object? value) {
    if (value is! String) {
      return null;
    }
    for (final status in QaEvidenceStatus.values) {
      if (status.name == value) {
        return status;
      }
    }
    return null;
  }
}

class QaCheckResult {
  const QaCheckResult({required this.status, required this.updatedAtUtc});

  final QaEvidenceStatus status;
  final DateTime updatedAtUtc;

  Map<String, Object?> toJsonObject() => {
    'status': status.name,
    'updatedAtUtc': updatedAtUtc.toUtc().toIso8601String(),
  };

  static QaCheckResult? tryParse(Object? value) {
    if (value is! Map) {
      return null;
    }
    final map = Map<String, Object?>.from(value);
    final status = QaEvidenceStatus.tryParse(map['status']);
    final timestamp = map['updatedAtUtc'];
    if (status == null ||
        status == QaEvidenceStatus.notRun ||
        timestamp is! String) {
      return null;
    }
    final updatedAt = DateTime.tryParse(timestamp);
    if (updatedAt == null) {
      return null;
    }
    return QaCheckResult(status: status, updatedAtUtc: updatedAt.toUtc());
  }
}

class QaEvidenceSession {
  QaEvidenceSession._({
    required this.startedAtUtc,
    required this.updatedAtUtc,
    required Map<String, QaCheckResult> results,
  }) : results = Map.unmodifiable(results);

  static const schemaVersion = 1;

  final DateTime startedAtUtc;
  final DateTime updatedAtUtc;
  final Map<String, QaCheckResult> results;

  factory QaEvidenceSession.fresh(DateTime now) {
    final utc = now.toUtc();
    return QaEvidenceSession._(
      startedAtUtc: utc,
      updatedAtUtc: utc,
      results: const {},
    );
  }

  factory QaEvidenceSession.fromJsonObject(
    Map<String, Object?> json, {
    required DateTime fallbackNow,
  }) {
    final startedAt = _parseDate(json['startedAtUtc']);
    final updatedAt = _parseDate(json['updatedAtUtc']);
    final rawResults = json['results'];
    if (json['schemaVersion'] != schemaVersion ||
        startedAt == null ||
        updatedAt == null ||
        rawResults is! Map) {
      return QaEvidenceSession.fresh(fallbackNow);
    }

    final parsedResults = <String, QaCheckResult>{};
    for (final entry in rawResults.entries) {
      final id = entry.key;
      if (id is! String || id.isEmpty) {
        continue;
      }
      final result = QaCheckResult.tryParse(entry.value);
      if (result != null) {
        parsedResults[id] = result;
      }
    }

    return QaEvidenceSession._(
      startedAtUtc: startedAt,
      updatedAtUtc: updatedAt,
      results: parsedResults,
    );
  }

  static QaEvidenceSession fromJson(
    String source, {
    required DateTime fallbackNow,
  }) {
    try {
      final decoded = jsonDecode(source);
      if (decoded is! Map) {
        return QaEvidenceSession.fresh(fallbackNow);
      }
      return QaEvidenceSession.fromJsonObject(
        Map<String, Object?>.from(decoded),
        fallbackNow: fallbackNow,
      );
    } catch (_) {
      return QaEvidenceSession.fresh(fallbackNow);
    }
  }

  QaEvidenceStatus statusFor(String checkId) =>
      results[checkId]?.status ?? QaEvidenceStatus.notRun;

  QaCheckResult? resultFor(String checkId) => results[checkId];

  QaEvidenceSession withStatus({
    required String checkId,
    required QaEvidenceStatus status,
    required DateTime changedAt,
  }) {
    final next = Map<String, QaCheckResult>.from(results);
    final changedAtUtc = changedAt.toUtc();
    if (status == QaEvidenceStatus.notRun) {
      next.remove(checkId);
    } else {
      next[checkId] = QaCheckResult(status: status, updatedAtUtc: changedAtUtc);
    }
    return QaEvidenceSession._(
      startedAtUtc: startedAtUtc,
      updatedAtUtc: changedAtUtc,
      results: next,
    );
  }

  QaEvidenceSession keepingOnly(Set<String> checkIds) {
    final next = <String, QaCheckResult>{};
    for (final entry in results.entries) {
      if (checkIds.contains(entry.key)) {
        next[entry.key] = entry.value;
      }
    }
    return QaEvidenceSession._(
      startedAtUtc: startedAtUtc,
      updatedAtUtc: updatedAtUtc,
      results: next,
    );
  }

  Map<String, Object?> toJsonObject() => {
    'schemaVersion': schemaVersion,
    'startedAtUtc': startedAtUtc.toUtc().toIso8601String(),
    'updatedAtUtc': updatedAtUtc.toUtc().toIso8601String(),
    'results': {
      for (final entry in results.entries)
        entry.key: entry.value.toJsonObject(),
    },
  };

  String toJson() => jsonEncode(toJsonObject());

  static DateTime? _parseDate(Object? value) {
    if (value is! String) {
      return null;
    }
    return DateTime.tryParse(value)?.toUtc();
  }
}
