import 'app_localizations.dart';

extension DiagnosticsLocalizations on AppLocalizations {
  String get diagnostics => 'Diagnostics & QA';
  String get diagnosticsSubtitle =>
      'Create a privacy-safe device and app state report for testing and support.';
  String get diagnosticsPrivacyTitle => 'Privacy-safe report';
  String get diagnosticsPrivacyDescription =>
      'The report excludes recording content, titles, file paths, notes, tags, bookmarks, naming text, and input-device names.';
  String get diagnosticsRefresh => 'Refresh diagnostics';
  String get diagnosticsCopyJson => 'Copy JSON';
  String get diagnosticsShareMarkdown => 'Share report';
  String get diagnosticsCopied => 'Diagnostics JSON copied.';
  String get diagnosticsShared => 'Diagnostics report prepared for sharing.';
  String diagnosticsFailed(Object error) => 'Could not collect diagnostics: $error';
  String diagnosticsShareFailed(Object error) =>
      'Could not share diagnostics: $error';
  String get diagnosticsLoading => 'Collecting diagnostics…';
  String get diagnosticsRuntime => 'Runtime';
  String get diagnosticsLibrary => 'Library snapshot';
  String get diagnosticsStorage => 'Managed storage';
  String get diagnosticsRecorder => 'Recorder state';
  String get diagnosticsRecordingSettings => 'Recording settings';
  String get diagnosticsPlaybackUi => 'Playback & interface';
  String get diagnosticsPlatform => 'Platform';
  String get diagnosticsOsVersion => 'OS version';
  String get diagnosticsLocale => 'Locale';
  String get diagnosticsDartVersion => 'Dart runtime';
  String get diagnosticsProcessorCount => 'Logical processors';
  String get diagnosticsSaved => 'Saved';
  String get diagnosticsTrash => 'Trash';
  String get diagnosticsFavorites => 'Favorites';
  String get diagnosticsPinned => 'Pinned';
  String get diagnosticsTotalManaged => 'Total managed';
  String get diagnosticsTemporary => 'Temporary';
  String get diagnosticsProbeStatus => 'Probe status';
  String get diagnosticsRecorderStatus => 'Status';
  String get diagnosticsInputCount => 'Detected inputs';
  String get diagnosticsSelectedInput => 'Selected input';
  String get diagnosticsDefaultInput => 'System default';
  String get diagnosticsCustomInput => 'Custom input';
  String get diagnosticsFormat => 'Format';
  String get diagnosticsPreset => 'Preset';
  String get diagnosticsBitRate => 'Bit rate';
  String get diagnosticsSampleRate => 'Sample rate';
  String get diagnosticsChannels => 'Channels';
  String get diagnosticsAutoGain => 'Automatic gain';
  String get diagnosticsEchoCancellation => 'Echo cancellation';
  String get diagnosticsNoiseSuppression => 'Noise suppression';
  String get diagnosticsCountdown => 'Countdown';
  String get diagnosticsKeepAwake => 'Keep screen awake';
  String get diagnosticsPlaybackSpeed => 'Default playback speed';
  String get diagnosticsSkipInterval => 'Skip interval';
  String get diagnosticsSkipSilence => 'Skip silence';
  String get diagnosticsTheme => 'Theme';
  String get diagnosticsReducedMotion => 'Reduced motion';
  String get diagnosticsDeleteConfirmation => 'Delete confirmation';
  String get diagnosticsSucceeded => 'Succeeded';
  String get diagnosticsUnavailable => 'Unavailable';
  String get diagnosticsEnabled => 'Enabled';
  String get diagnosticsDisabled => 'Disabled';
  String diagnosticsSeconds(int value) => '$value seconds';
  String diagnosticsHertz(int value) => '$value Hz';
  String diagnosticsBitsPerSecond(int value) => '$value bps';
  String diagnosticsCount(int value) => '$value';
  String get diagnosticsAboutTileSubtitle =>
      'Privacy-safe runtime, storage, recorder, and settings evidence';
}
