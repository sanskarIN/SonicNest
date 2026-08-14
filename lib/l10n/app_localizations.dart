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
  String get open => 'Open';
  String get play => 'Play';
  String get pause => 'Pause';
  String get resume => 'Resume';
  String get cancel => 'Cancel';
  String get save => 'Save';
  String get delete => 'Delete';
  String get share => 'Share';
  String get restore => 'Restore';
  String get selectAll => 'Select all';
  String get clearAll => 'Clear all';
  String get off => 'Off';

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
  String get recentRecordings => 'Recent recordings';
  String get viewAll => 'View all';
  String get recordingsWillAppearHere => 'Your recordings will appear here.';
  String get useQuickRecordOrImport =>
      'Use Quick Record or import audio from the Library.';

  String get aboutTagline => 'Modern, privacy-first sound and voice recording.';
  String get supportSonicNest => '☕ Support SonicNest';
  String get supportOpenSourceHint =>
      'Help keep SonicNest open source. Support is optional and never blocks recording.';
  String get sonicNestOnGitHub => 'SonicNest on GitHub';
  String get developerProfile => 'Developer profile';
  String get business => 'Business';
  String get businessAlternate => 'Business (alternate)';
  String get support => 'Support';
  String get openSourceLicenses => 'Open-source licenses';
  String get reviewThirdPartyLicenses =>
      'Review third-party licenses used by this build';
  String get privacy => 'Privacy';
  String get privacySummary =>
      'The core recorder is designed to work offline. Recordings stay on your device unless you explicitly choose to share or export them. SonicNest does not include hidden analytics or automatic cloud uploads.';
  String get openSourceLicense => 'Open source license';
  String get apacheLicenseSummary =>
      'Apache License 2.0. Third-party components keep their own licenses and notices.';
  String get businessInquirySubject => 'SonicNest business inquiry';
  String get supportEmailSubject => 'SonicNest support';
  String versionLabel(String version) => 'Version $version';

  String get recorder => 'Recorder';
  String get mono => 'Mono';
  String get stereo => 'Stereo';
  String recordingStartsIn(int seconds) =>
      'Recording starts in $seconds seconds';
  String get inputIsClipping => 'Input is clipping';
  String addMarker(int count) => 'Add marker ($count)';
  String get noiseSuppression => 'Noise suppression';
  String get echoCancellation => 'Echo cancellation';
  String get recorderError => 'Recorder error';
  String get dismiss => 'Dismiss';
  String get ready => 'Ready';
  String startingIn(int seconds) => 'Starting in $seconds…';
  String get recordingStatus => 'Recording';
  String get pausedStatus => 'Paused';
  String get processingAudio => 'Processing audio';
  String get needsAttention => 'Needs attention';
  String get cancelCountdown => 'Cancel countdown';
  String get startRecording => 'Start recording';
  String get stopAndSave => 'Stop & save';
  String get discard => 'Discard';
  String get qualityPreset => 'Quality preset';
  String get speech => 'Speech';
  String get meeting => 'Meeting';
  String get lecture => 'Lecture';
  String get interview => 'Interview';
  String get podcast => 'Podcast';
  String get music => 'Music';
  String get highQuality => 'High Quality';
  String get lossless => 'Lossless';
  String get smallFile => 'Small File';
  String get custom => 'Custom';

  String get nowPlaying => 'Now Playing';
  String get removeFromFavorites => 'Remove from favorites';
  String get addToFavorites => 'Add to favorites';
  String get previousRecording => 'Previous recording';
  String jumpBackSeconds(int seconds) => 'Jump back $seconds seconds';
  String jumpForwardSeconds(int seconds) => 'Jump forward $seconds seconds';
  String get nextRecording => 'Next recording';
  String get repeat => 'Repeat';
  String get abLoop => 'A–B loop';
  String get clearLoop => 'Clear loop';
  String get skipSilence => 'Skip silence';
  String get bookmarks => 'Bookmarks';
  String get loopSelection => 'Loop selection';
  String get audioPlaying => 'Audio playing';
  String get audioRecording => 'Audio recording';

  String get importAudio => 'Import';
  String libraryCounts(int shown, int saved) => '$shown shown • $saved saved';
  String get searchRecordingsHint =>
      'Search title, tags, notes, folders, bookmarks';
  String get clearSearch => 'Clear search';
  String get select => 'Select';
  String get emptyTrash => 'Empty Trash';
  String bulkActionFailed(Object error) => 'Bulk action failed: $error';
  String deleteSelectedPermanently(int count) =>
      'Delete $count recording${count == 1 ? '' : 's'} permanently?';
  String get selectedPermanentDeleteWarning =>
      'The selected recordings will be permanently deleted. This cannot be undone.';
  String couldNotOpenRecording(Object error) =>
      'Could not open recording: $error';
  String get inTrash => 'In Trash';
  String get editAudio => 'Edit audio';
  String get rename => 'Rename';
  String get tagsFolderNotes => 'Tags, folder & notes';
  String get unpin => 'Unpin';
  String get pin => 'Pin';
  String get duplicate => 'Duplicate';
  String get exportCopy => 'Export copy';
  String get moveToTrash => 'Move to Trash';
  String get deletePermanently => 'Delete permanently';
  String get renameRecording => 'Rename recording';
  String get name => 'Name';
  String get recordingDetails => 'Recording details';
  String get folder => 'Folder';
  String get tags => 'Tags';
  String get tagsHint => 'lecture, study, important';
  String get notes => 'Notes';
  String get deletePermanentlyQuestion => 'Delete permanently?';
  String recordingPermanentDeleteWarning(String title) =>
      '“$title” will be permanently deleted. This cannot be undone.';
  String get emptyTrashQuestion => 'Empty Trash?';
  String get emptyTrashWarning =>
      'Every recording currently in Trash will be permanently deleted.';
  String get cancelSelection => 'Cancel selection';
  String selectedCount(int count) => '$count selected';
  String get bulkActions => 'Bulk actions';
  String get restoreSelected => 'Restore selected';
  String get removeFavorites => 'Remove favorites';
  String get pinSelected => 'Pin selected';
  String get unpinSelected => 'Unpin selected';
  String get shareSelected => 'Share selected';
  String get all => 'All';
  String get favorites => 'Favorites';
  String get pinned => 'Pinned';
  String get trash => 'Trash';
  String get sort => 'Sort';
  String get format => 'Format';
  String get anyFormat => 'Any format';
  String get anyFolder => 'Any folder';
  String get advancedFilters => 'Advanced filters';
  String get exactTag => 'Exact tag';
  String get anyTag => 'Any tag';
  String get fromDate => 'From date';
  String get throughDate => 'Through date';
  String get notSet => 'Not set';
  String get clearFilters => 'Clear filters';
  String get applyFilters => 'Apply filters';
  String get newestFirst => 'Newest first';
  String get oldestFirst => 'Oldest first';
  String get nameAscending => 'Name A–Z';
  String get nameDescending => 'Name Z–A';
  String get longest => 'Longest';
  String get shortest => 'Shortest';
  String get largestFile => 'Largest file';
  String get smallestFile => 'Smallest file';
  String get noRecordingsYet => 'No recordings yet';
  String get noRecordingsLibraryHint =>
      'Create a recording or import an audio file to start your library.';
  String get noFavorites => 'No favorites';
  String get noFavoritesHint => 'Tap the heart on a recording to keep it here.';
  String get nothingPinned => 'Nothing pinned';
  String get nothingPinnedHint => 'Pin important recordings for quick access.';
  String get trashIsEmpty => 'Trash is empty';
  String get trashIsEmptyHint =>
      'Deleted recordings you can restore will appear here.';
  String get recordNow => 'Record now';

  String get recordingSettingsSection => 'Recording';
  String get defaultFormat => 'Default format';
  String get bitrate => 'Bitrate';
  String get sampleRate => 'Sample rate';
  String get automaticGainControl => 'Automatic gain control';
  String get automaticGainHint =>
      'Ask the recording backend to keep voice levels more consistent when supported.';
  String get smartNaming => 'Smart naming';
  String get prefix => 'Prefix';
  String get recordingDefaultPrefix => 'Recording';
  String get filenameTemplate => 'Filename template';
  String get filenameTemplateHint => '{prefix}_{date}_{time}';
  String get filenameTemplateHelper =>
      'Tokens: {prefix} {suffix} {category} {date} {time} {sequence}';
  String get categoryToken => 'Category token';
  String get suffixToken => 'Suffix token';
  String get countdown => 'Countdown';
  String seconds(int count) => '$count seconds';
  String get keepScreenAwakeDuringRecording =>
      'Keep screen awake during recording';
  String get playbackSettingsSection => 'Playback';
  String get defaultPlaybackSpeed => 'Default playback speed';
  String get jumpInterval => 'Jump interval';
  String get skipSilenceByDefault => 'Skip silence by default';
  String get skipSilenceBackendHint =>
      'Used where the active playback backend supports silence skipping.';
  String get appearanceAccessibility => 'Appearance & accessibility';
  String get systemTheme => 'System';
  String get lightTheme => 'Light';
  String get darkTheme => 'Dark';
  String get reduceMotion => 'Reduce motion';
  String get reduceMotionHint =>
      'Avoid non-essential animation and movement.';
  String get safetyStorage => 'Safety & storage';
  String get confirmPermanentDeletion => 'Confirm permanent deletion';
  String get confirmPermanentDeletionHint =>
      'Trash remains recoverable until you permanently delete an item.';
  String get managedStorage => 'Managed storage';
  String storageSummary(String total, String recordings, String trash) =>
      '$total total • $recordings recordings • $trash Trash';
  String savedCount(int count) => '$count saved';
  String get temporaryAudioFiles => 'Temporary audio files';
  String temporaryFilesSummary(int count, String size) => '$count files • $size';
  String get clean => 'Clean';
  String get offlineFirstRecordings => 'Offline-first recordings';
  String get offlineFirstRecordingsHint =>
      'SonicNest stores recordings locally and does not upload microphone data by default.';

  String get batchConvert => 'Batch Convert';
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
