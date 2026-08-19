import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sonic_nest/l10n/app_localizations.dart';
import 'package:sonic_nest/l10n/qa_import_localizations.dart';

void main() {
  const l10n = AppLocalizations(Locale('en'));

  test('QA evidence transfer actions have localized labels', () {
    expect(l10n.qaEvidenceShareJson, 'Share evidence JSON');
    expect(l10n.qaEvidenceImportJson, 'Import evidence JSON');
    expect(l10n.qaEvidenceImportConfirm, 'Merge evidence');
  });

  test('merge description explains the non-destructive conflict policy', () {
    final text = l10n.qaEvidenceImportDescription(7, 2, 3, 2).toLowerCase();

    expect(text, contains('7 assessed checks'));
    expect(text, contains('2 will be added'));
    expect(text, contains('3 will replace older local evidence'));
    expect(text, contains('not-run values never clear'));
  });

  test('merge completion copy pluralizes changed check count', () {
    expect(l10n.qaEvidenceImported(1), 'QA evidence merged. 1 check changed.');
    expect(l10n.qaEvidenceImported(2), 'QA evidence merged. 2 checks changed.');
  });
}