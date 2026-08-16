import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sonic_nest/l10n/app_localizations.dart';
import 'package:sonic_nest/l10n/diagnostics_localizations.dart';
import 'package:sonic_nest/models/qa_check_catalog.dart';

void main() {
  const l10n = AppLocalizations(Locale('en'));

  test('diagnostics labels are available through the localization layer', () {
    expect(l10n.diagnostics, 'Diagnostics & QA');
    expect(l10n.diagnosticsRefresh, 'Refresh diagnostics');
    expect(l10n.diagnosticsCopyJson, 'Copy JSON');
    expect(l10n.diagnosticsShareMarkdown, 'Share report');
    expect(l10n.diagnosticsVersion, 'Version');
  });

  test('diagnostics privacy copy names the intentionally excluded data', () {
    final text = l10n.diagnosticsPrivacyDescription.toLowerCase();

    expect(text, contains('recording content'));
    expect(text, contains('titles'));
    expect(text, contains('file paths'));
    expect(text, contains('notes'));
    expect(text, contains('tags'));
    expect(text, contains('bookmarks'));
    expect(text, contains('input-device names'));
  });

  test('diagnostics helper labels render values consistently', () {
    expect(l10n.diagnosticsSeconds(5), '5 seconds');
    expect(l10n.diagnosticsHertz(48000), '48000 Hz');
    expect(l10n.diagnosticsBitsPerSecond(128000), '128000 bps');
    expect(l10n.diagnosticsCount(7), '7');
  });

  test('QA evidence workflow is localized and avoids free-form notes', () {
    expect(l10n.qaEvidenceTitle, 'Manual QA evidence');
    expect(l10n.qaEvidenceStatusLabel('passed'), l10n.qaEvidencePassed);
    expect(l10n.qaEvidenceStatusLabel('failed'), l10n.qaEvidenceFailed);
    expect(l10n.qaEvidenceStatusLabel('blocked'), l10n.qaEvidenceBlocked);
    expect(l10n.qaEvidenceStatusLabel('notRun'), l10n.qaEvidenceNotRun);
    expect(
      l10n.qaEvidencePrivacyDescription.toLowerCase(),
      contains('free-form tester notes are not collected'),
    );
  });

  test('every QA category and check has a user-facing localized label', () {
    for (final category in QaCheckCatalog.categories) {
      final label = l10n.qaEvidenceCategoryTitle(category.id);
      expect(label, isNot(category.id));
      expect(label.trim(), isNotEmpty);
    }

    for (final check in QaCheckCatalog.checks) {
      final label = l10n.qaEvidenceCheckTitle(check.id);
      expect(label, isNot(check.id));
      expect(label.trim(), isNotEmpty);
    }
  });
}
