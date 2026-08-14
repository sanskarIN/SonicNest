import 'package:flutter/cupertino.dart' show DefaultCupertinoLocalizations;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = <Locale>[Locale('en')];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        const AppLocalizations(Locale('en'));
  }

  String get appName => 'SonicNest';
  String get home => 'Home';
  String get record => 'Record';
  String get library => 'Library';
  String get settings => 'Settings';
  String get about => 'About';
  String get privateRecorderTagline => 'Private sound & voice recording';
  String get madeBy => 'Made by the Sanskar';
  String get startupFailure => 'SonicNest could not finish startup.';
  String get retry => 'Try again';
  String get moreFilters => 'More filters';
  String get filtersActive => 'Filters active';

  String get welcomeToSonicNest => 'Welcome to SonicNest';
  String get homeDescription =>
      'Capture voice and sound privately, then organize and edit it locally.';
  String get recordings => 'Recordings';
  String get recordedAudio => 'Recorded audio';
  String get localStorage => 'Local storage';
  String get quickRecord => 'Quick Record';
  String get quickRecordHint =>
      'Open the recorder with your current quality preset.';
  String get batchConvertHomeHint =>
      'Create converted copies of several saved recordings in one operation.';
  String get open => 'Open';
  String get recentRecordings => 'Recent recordings';
  String get viewAll => 'View all';
  String get recordingsWillAppearHere => 'Your recordings will appear here.';
  String get useQuickRecordOrImport =>
      'Use Quick Record or import audio from the Library.';
  String get play => 'Play';
  String get pause => 'Pause';

  String get batchConvert => 'Batch Convert';
  String get selectAll => 'Select all';
  String get clearAll => 'Clear all';
  String get createConvertedCopies => 'Create converted copies';
  String get batchConvertDescription =>
      'Select multiple library recordings. SonicNest creates new files and keeps every original untouched.';
  String get targetFormat => 'Target format';
  String get copyToExternalFolder => 'Copy to an external folder';
  String get keepConvertedCopiesInLibraryOnly =>
      'Keep converted copies only in the SonicNest library.';
  String get changeExportFolder => 'Change export folder';
  String get stopRequestedCurrentFileFinishes =>
      'Stop requested. The current file will finish safely.';
  String get stoppingAfterCurrentFile => 'Stopping after current file…';
  String get stopAfterCurrentFile => 'Stop after current file';
  String get noSavedRecordingsForBatch =>
      'There are no saved recordings to batch convert yet.';
  String get rateUnknown => 'rate unknown';

  String convertSelected(int count) => 'Convert $count selected';
  String convertedProgress(int completed, int total) =>
      'Converted $completed of $total';
  String convertedCopiesCreated(int count) =>
      '$count converted copies created.';
  String copiedToExportFolder(int count) =>
      ' $count copied to the export folder.';
  String externalCopyFailureSummary(
    int copied,
    int failed,
    String details,
  ) =>
      ' $copied copied externally; $failed external copy failed: $details';
  String conversionFailureDetails(int failed, String details) =>
      ' $failed conversion failed: $details';
  String batchStoppedSummary(
    int completed,
    int total,
    int converted,
    String conversionFailures,
    String exportSummary,
  ) =>
      'Stopped after $completed of $total. '
      '$converted converted.$conversionFailures$exportSummary';
  String batchFailureSummary(int converted, int failed, String details) =>
      '$converted converted; $failed failed. $details';

  static const localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    DefaultMaterialLocalizations.delegate,
    DefaultWidgetsLocalizations.delegate,
    DefaultCupertinoLocalizations.delegate,
  ];
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.any(
        (supported) => supported.languageCode == locale.languageCode,
      );

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture(AppLocalizations(locale));

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
