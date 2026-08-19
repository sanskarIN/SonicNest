import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Manual QA screen exposes guarded JSON share and import actions', () {
    final source = File('lib/screens/qa_evidence_screen.dart')
        .readAsStringSync();

    expect(
      source,
      contains("import '../services/qa_evidence_import_service.dart';"),
    );
    expect(source, contains('static const _maxImportBytes = 2 * 1024 * 1024;'));
    expect(source, contains('pickSingleJsonFile()'));
    expect(source, contains('bundle.toPrettyJson()'));
    expect(source, contains('result.hasChanges'));
    expect(source, contains('qaEvidenceImportDescription'));
    expect(source, contains('await _store.save(result.mergedSession);'));
  });

  test('ExternalActions limits evidence selection to JSON files', () {
    final source = File('lib/services/external_actions.dart')
        .readAsStringSync();

    expect(source, contains('Future<String?> pickSingleJsonFile()'));
    expect(source, contains("allowedExtensions: const ['json']"));
  });
}
