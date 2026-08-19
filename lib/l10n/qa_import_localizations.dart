import 'app_localizations.dart';

extension QaImportLocalizations on AppLocalizations {
  String get qaEvidenceShareJson => 'Share evidence JSON';
  String get qaEvidenceImportJson => 'Import evidence JSON';
  String get qaEvidenceImportTitle => 'Merge QA evidence?';
  String qaEvidenceImportDescription(
    int assessed,
    int added,
    int updated,
    int ignored,
  ) =>
      'The selected same-version bundle contains $assessed assessed checks. '
      '$added will be added, $updated will replace older local evidence, and '
      '$ignored older or equal results will be kept unchanged. Not-run values '
      'never clear local assessed evidence.';
  String get qaEvidenceImportConfirm => 'Merge evidence';
  String qaEvidenceImported(int changed) =>
      'QA evidence merged. $changed check${changed == 1 ? '' : 's'} changed.';
  String get qaEvidenceImportNoChanges =>
      'The selected evidence contains no newer assessed results to merge.';
  String qaEvidenceImportFailed(Object error) =>
      'Could not import QA evidence: $error';
}