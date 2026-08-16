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
  String diagnosticsFailed(Object error) =>
      'Could not collect diagnostics: $error';
  String diagnosticsShareFailed(Object error) =>
      'Could not share diagnostics: $error';
  String get diagnosticsLoading => 'Collecting diagnostics…';
  String get diagnosticsRuntime => 'Runtime';
  String get diagnosticsLibrary => 'Library snapshot';
  String get diagnosticsStorage => 'Managed storage';
  String get diagnosticsRecorder => 'Recorder state';
  String get diagnosticsRecordingSettings => 'Recording settings';
  String get diagnosticsPlaybackUi => 'Playback & interface';
  String get diagnosticsVersion => 'Version';
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

  String get qaEvidenceOpen => 'Manual QA evidence';
  String get qaEvidenceOpenSubtitle =>
      'Track the remaining real-device and release validation checks';
  String get qaEvidenceOpenWithDiagnostics =>
      'Open QA evidence with this snapshot';
  String get qaEvidenceTitle => 'Manual QA evidence';
  String get qaEvidenceSubtitle =>
      'Record pass, fail, blocked, or not-run status for release checks. This does not automate or close a manual gate.';
  String get qaEvidencePrivacyTitle => 'Evidence without free-form data';
  String get qaEvidencePrivacyDescription =>
      'Only fixed check IDs, status values, timestamps, and the optional privacy-safe diagnostics snapshot are exported. Free-form tester notes are not collected.';
  String get qaEvidenceCopyJson => 'Copy evidence JSON';
  String get qaEvidenceShareMarkdown => 'Share evidence';
  String get qaEvidenceReset => 'Reset session';
  String get qaEvidenceResetTitle => 'Reset QA evidence session?';
  String get qaEvidenceResetDescription =>
      'All recorded pass, fail, and blocked statuses for this local session will return to Not run.';
  String get qaEvidenceResetConfirm => 'Reset';
  String get qaEvidenceCopied => 'QA evidence JSON copied.';
  String get qaEvidenceShared => 'QA evidence bundle prepared for sharing.';
  String get qaEvidenceResetDone => 'QA evidence session reset.';
  String get qaEvidenceLoading => 'Loading QA evidence…';
  String qaEvidenceLoadFailed(Object error) =>
      'Could not load QA evidence: $error';
  String qaEvidenceSaveFailed(Object error) =>
      'Could not save QA evidence: $error';
  String qaEvidenceShareFailed(Object error) =>
      'Could not share QA evidence: $error';
  String get qaEvidenceTotal => 'Total';
  String get qaEvidenceAssessed => 'Assessed';
  String get qaEvidencePassed => 'Passed';
  String get qaEvidenceFailed => 'Failed';
  String get qaEvidenceBlocked => 'Blocked';
  String get qaEvidenceNotRun => 'Not run';
  String qaEvidenceCategoryProgress(int assessed, int total) =>
      '$assessed of $total assessed';
  String qaEvidenceUpdated(String value) => 'Updated $value';
  String get qaEvidencePhysicalTarget => 'Physical target';
  String get qaEvidenceExternalTooling => 'External tooling';

  String qaEvidenceStatusLabel(String statusName) {
    switch (statusName) {
      case 'passed':
        return qaEvidencePassed;
      case 'failed':
        return qaEvidenceFailed;
      case 'blocked':
        return qaEvidenceBlocked;
      case 'notRun':
      default:
        return qaEvidenceNotRun;
    }
  }

  String qaEvidenceCategoryTitle(String categoryId) {
    switch (categoryId) {
      case 'microphone_lifecycle':
        return 'Microphone & lifecycle';
      case 'reliability_stress':
        return 'Reliability & stress';
      case 'desktop_interaction':
        return 'Desktop interaction';
      case 'accessibility_ux':
        return 'Accessibility & UX';
      case 'branding_package':
        return 'Branding & package validation';
      case 'external_export':
        return 'External batch export';
      default:
        return categoryId;
    }
  }

  String qaEvidenceCheckTitle(String checkId) {
    switch (checkId) {
      case 'android_microphone_permission':
        return 'Android microphone allow, deny, and revoke';
      case 'ios_microphone_permission':
        return 'iOS microphone allow, deny, and revoke';
      case 'macos_microphone_permission':
        return 'macOS microphone permission and entitlement';
      case 'windows_microphone_capture':
        return 'Windows microphone capture and routing';
      case 'linux_microphone_capture':
        return 'Linux microphone capture and routing';
      case 'input_switching':
        return 'Built-in, wired, USB, Bluetooth, and external input switching';
      case 'audio_interruption':
        return 'Incoming call, alarm, and audio-focus interruptions';
      case 'background_device_lock':
        return 'Background recording and device lock';
      case 'android_foreground_service_variation':
        return 'Android foreground-service OEM/device variations';
      case 'ios_background_policy':
        return 'iOS background-recording policy and lifecycle';
      case 'bluetooth_disconnect_reconnect':
        return 'Headphone/Bluetooth disconnect and reconnect';
      case 'low_storage_recording_export':
        return 'Low-storage recording and export recovery';
      case 'filesystem_permission_failure':
        return 'Disk and file permission failure recovery';
      case 'abrupt_interruption_recovery':
        return 'Abrupt process/device interruption recovery';
      case 'real_orphan_recovery':
        return 'Real playable, partial, and damaged orphan recovery';
      case 'repeated_start_stop':
        return 'Repeated recording start/stop stress';
      case 'repeated_pause_resume':
        return 'Repeated recording pause/resume stress';
      case 'recording_30_minute':
        return '30-minute recording soak';
      case 'recording_multi_hour':
        return 'Multi-hour recording soak';
      case 'large_library_ui':
        return 'Large-library UI and memory profiling';
      case 'long_audio_memory':
        return 'Very long playback/editor memory behavior';
      case 'malformed_import_corpus':
        return 'Malformed and corrupt audio import corpus';
      case 'large_batch_profile':
        return 'Large mixed-format batch conversion profiling';
      case 'batch_low_storage':
        return 'Batch conversion under low storage';
      case 'batch_failure_isolation':
        return 'Per-file malformed/unsupported batch failure isolation';
      case 'windows_secondary_click':
        return 'Windows secondary/right-click recording actions';
      case 'macos_secondary_click':
        return 'macOS secondary/right-click recording actions';
      case 'linux_secondary_click':
        return 'Linux secondary/right-click recording actions';
      case 'secondary_click_interaction_safety':
        return 'Secondary-click interaction safety';
      case 'native_context_menu_evaluation':
        return 'Native context-menu usability evaluation';
      case 'talkback_audit':
        return 'Android TalkBack audit';
      case 'voiceover_ios_audit':
        return 'iOS VoiceOver audit';
      case 'voiceover_macos_audit':
        return 'macOS VoiceOver audit';
      case 'narrator_windows_audit':
        return 'Windows Narrator audit';
      case 'linux_accessibility_audit':
        return 'Linux desktop accessibility-tool audit';
      case 'large_text_scaling':
        return 'Large text and scaling review';
      case 'keyboard_only_desktop':
        return 'Keyboard-only end-to-end desktop review';
      case 'reduced_motion_review':
        return 'Reduced-motion behavior review';
      case 'batch_large_text_keyboard':
        return 'Batch Convert large-text and keyboard-only review';
      case 'android_icon_visual_review':
        return 'Android legacy/adaptive/themed icon review';
      case 'apple_icon_visual_review':
        return 'iOS and macOS icon-size review';
      case 'windows_icon_visual_review':
        return 'Windows Explorer/taskbar/Start/shortcut icon review';
      case 'linux_deb_visual_review':
        return 'Linux launcher/menu/task-switcher icon review';
      case 'native_launch_splash_review':
        return 'Android/iOS release launch and splash review';
      case 'real_release_screenshots':
        return 'Capture real screenshots from tested builds';
      case 'linux_deb_real_install':
        return 'Linux .deb install, launch, upgrade, uninstall, and audio';
      case 'windows_portable_real_test':
        return 'Windows portable ZIP real-system validation';
      case 'direct_multi_export_cross_platform':
        return 'Direct original-file multi-export on all platforms';
      case 'mixed_success_missing_source':
        return 'Mixed-success export when one source disappears';
      case 'directory_picker_cross_platform':
        return 'Directory-picker behavior on all platforms';
      case 'real_folder_collision_numbering':
        return 'Collision-safe numbering in real folders';
      case 'destination_permission_revocation':
        return 'Destination disappearance or permission revocation';
      case 'external_copy_low_storage':
        return 'Low-storage behavior during external copies';
      case 'stop_after_current_long_conversion':
        return 'Stop after current file during long conversions';
      case 'navigate_away_batch_conversion':
        return 'Navigate away from Batch Convert during processing';
      case 'very_large_mixed_export_batch':
        return 'Very large and mixed-format export profiling';
      default:
        return checkId;
    }
  }
}
