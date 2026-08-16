class QaCheckCategory {
  const QaCheckCategory({required this.id, required this.evidenceLabel});

  final String id;
  final String evidenceLabel;
}

class QaCheckDefinition {
  const QaCheckDefinition({
    required this.id,
    required this.categoryId,
    required this.evidenceLabel,
    this.requiresPhysicalTarget = false,
    this.requiresExternalTooling = false,
  });

  final String id;
  final String categoryId;
  final String evidenceLabel;
  final bool requiresPhysicalTarget;
  final bool requiresExternalTooling;
}

abstract final class QaCheckCatalog {
  static const categories = <QaCheckCategory>[
    QaCheckCategory(
      id: 'microphone_lifecycle',
      evidenceLabel: 'Microphone and lifecycle',
    ),
    QaCheckCategory(
      id: 'reliability_stress',
      evidenceLabel: 'Reliability and stress',
    ),
    QaCheckCategory(
      id: 'desktop_interaction',
      evidenceLabel: 'Desktop interaction',
    ),
    QaCheckCategory(
      id: 'accessibility_ux',
      evidenceLabel: 'Accessibility and UX',
    ),
    QaCheckCategory(
      id: 'branding_package',
      evidenceLabel: 'Branding and package validation',
    ),
    QaCheckCategory(
      id: 'external_export',
      evidenceLabel: 'External batch export',
    ),
  ];

  static const checks = <QaCheckDefinition>[
    QaCheckDefinition(
      id: 'android_microphone_permission',
      categoryId: 'microphone_lifecycle',
      evidenceLabel: 'Android microphone allow, deny, and revoke behavior',
      requiresPhysicalTarget: true,
    ),
    QaCheckDefinition(
      id: 'ios_microphone_permission',
      categoryId: 'microphone_lifecycle',
      evidenceLabel: 'iOS microphone allow, deny, and revoke behavior',
      requiresPhysicalTarget: true,
    ),
    QaCheckDefinition(
      id: 'macos_microphone_permission',
      categoryId: 'microphone_lifecycle',
      evidenceLabel: 'macOS microphone permission and entitlement behavior',
      requiresPhysicalTarget: true,
    ),
    QaCheckDefinition(
      id: 'windows_microphone_capture',
      categoryId: 'microphone_lifecycle',
      evidenceLabel: 'Windows microphone capture and routing',
      requiresPhysicalTarget: true,
    ),
    QaCheckDefinition(
      id: 'linux_microphone_capture',
      categoryId: 'microphone_lifecycle',
      evidenceLabel:
          'Linux microphone capture and routing on PulseAudio or PipeWire',
      requiresPhysicalTarget: true,
    ),
    QaCheckDefinition(
      id: 'input_switching',
      categoryId: 'microphone_lifecycle',
      evidenceLabel:
          'Built-in, wired, USB, Bluetooth, and external input switching',
      requiresPhysicalTarget: true,
    ),
    QaCheckDefinition(
      id: 'audio_interruption',
      categoryId: 'microphone_lifecycle',
      evidenceLabel:
          'Incoming call, alarm, and audio-focus interruption behavior',
      requiresPhysicalTarget: true,
    ),
    QaCheckDefinition(
      id: 'background_device_lock',
      categoryId: 'microphone_lifecycle',
      evidenceLabel: 'Background recording and device-lock behavior',
      requiresPhysicalTarget: true,
    ),
    QaCheckDefinition(
      id: 'android_foreground_service_variation',
      categoryId: 'microphone_lifecycle',
      evidenceLabel:
          'Android foreground-service behavior across OEM/device variations',
      requiresPhysicalTarget: true,
    ),
    QaCheckDefinition(
      id: 'ios_background_policy',
      categoryId: 'microphone_lifecycle',
      evidenceLabel: 'iOS background-recording policy and lifecycle behavior',
      requiresPhysicalTarget: true,
    ),
    QaCheckDefinition(
      id: 'bluetooth_disconnect_reconnect',
      categoryId: 'microphone_lifecycle',
      evidenceLabel: 'Headphone and Bluetooth disconnect/reconnect during playback and recording',
      requiresPhysicalTarget: true,
    ),
    QaCheckDefinition(
      id: 'low_storage_recording_export',
      categoryId: 'reliability_stress',
      evidenceLabel: 'Low-storage recording and export failure recovery',
      requiresPhysicalTarget: true,
    ),
    QaCheckDefinition(
      id: 'filesystem_permission_failure',
      categoryId: 'reliability_stress',
      evidenceLabel: 'Disk and file permission failure recovery',
      requiresPhysicalTarget: true,
    ),
    QaCheckDefinition(
      id: 'abrupt_interruption_recovery',
      categoryId: 'reliability_stress',
      evidenceLabel: 'Abrupt process/device interruption followed by metadata and audio recovery',
      requiresPhysicalTarget: true,
    ),
    QaCheckDefinition(
      id: 'real_orphan_recovery',
      categoryId: 'reliability_stress',
      evidenceLabel: 'Recovery of real playable, partial, and damaged managed orphan audio',
      requiresPhysicalTarget: true,
    ),
    QaCheckDefinition(
      id: 'repeated_start_stop',
      categoryId: 'reliability_stress',
      evidenceLabel: 'Repeated recording start/stop stress',
      requiresPhysicalTarget: true,
    ),
    QaCheckDefinition(
      id: 'repeated_pause_resume',
      categoryId: 'reliability_stress',
      evidenceLabel: 'Repeated recording pause/resume stress',
      requiresPhysicalTarget: true,
    ),
    QaCheckDefinition(
      id: 'recording_30_minute',
      categoryId: 'reliability_stress',
      evidenceLabel: 'Thirty-minute recording soak',
      requiresPhysicalTarget: true,
    ),
    QaCheckDefinition(
      id: 'recording_multi_hour',
      categoryId: 'reliability_stress',
      evidenceLabel: 'Multi-hour recording soak',
      requiresPhysicalTarget: true,
    ),
    QaCheckDefinition(
      id: 'large_library_ui',
      categoryId: 'reliability_stress',
      evidenceLabel:
          'Large-library startup, search, filter, scroll, and memory profiling',
      requiresExternalTooling: true,
    ),
    QaCheckDefinition(
      id: 'long_audio_memory',
      categoryId: 'reliability_stress',
      evidenceLabel: 'Very long playback/editor memory-growth behavior',
      requiresExternalTooling: true,
    ),
    QaCheckDefinition(
      id: 'malformed_import_corpus',
      categoryId: 'reliability_stress',
      evidenceLabel: 'Malformed and corrupt audio import corpus',
      requiresExternalTooling: true,
    ),
    QaCheckDefinition(
      id: 'large_batch_profile',
      categoryId: 'reliability_stress',
      evidenceLabel: 'Large mixed-format batch conversion profiling',
      requiresExternalTooling: true,
    ),
    QaCheckDefinition(
      id: 'batch_low_storage',
      categoryId: 'reliability_stress',
      evidenceLabel: 'Batch conversion under low-storage conditions',
      requiresPhysicalTarget: true,
    ),
    QaCheckDefinition(
      id: 'batch_failure_isolation',
      categoryId: 'reliability_stress',
      evidenceLabel: 'Per-file batch failure isolation with malformed or unsupported media',
      requiresExternalTooling: true,
    ),
    QaCheckDefinition(
      id: 'windows_secondary_click',
      categoryId: 'desktop_interaction',
      evidenceLabel: 'Windows secondary/right-click recording actions',
      requiresPhysicalTarget: true,
    ),
    QaCheckDefinition(
      id: 'macos_secondary_click',
      categoryId: 'desktop_interaction',
      evidenceLabel: 'macOS secondary/right-click recording actions',
      requiresPhysicalTarget: true,
    ),
    QaCheckDefinition(
      id: 'linux_secondary_click',
      categoryId: 'desktop_interaction',
      evidenceLabel: 'Linux secondary/right-click recording actions',
      requiresPhysicalTarget: true,
    ),
    QaCheckDefinition(
      id: 'secondary_click_interaction_safety',
      categoryId: 'desktop_interaction',
      evidenceLabel: 'Secondary-click coexistence with tap, double-click, focus, and touch long-press',
      requiresPhysicalTarget: true,
    ),
    QaCheckDefinition(
      id: 'native_context_menu_evaluation',
      categoryId: 'desktop_interaction',
      evidenceLabel: 'Usability evaluation of cursor-anchored native context menu versus current action surface',
      requiresPhysicalTarget: true,
    ),
    QaCheckDefinition(
      id: 'talkback_audit',
      categoryId: 'accessibility_ux',
      evidenceLabel: 'Android TalkBack audit',
      requiresPhysicalTarget: true,
      requiresExternalTooling: true,
    ),
    QaCheckDefinition(
      id: 'voiceover_ios_audit',
      categoryId: 'accessibility_ux',
      evidenceLabel: 'iOS VoiceOver audit',
      requiresPhysicalTarget: true,
      requiresExternalTooling: true,
    ),
    QaCheckDefinition(
      id: 'voiceover_macos_audit',
      categoryId: 'accessibility_ux',
      evidenceLabel: 'macOS VoiceOver audit',
      requiresPhysicalTarget: true,
      requiresExternalTooling: true,
    ),
    QaCheckDefinition(
      id: 'narrator_windows_audit',
      categoryId: 'accessibility_ux',
      evidenceLabel: 'Windows Narrator audit',
      requiresPhysicalTarget: true,
      requiresExternalTooling: true,
    ),
    QaCheckDefinition(
      id: 'linux_accessibility_audit',
      categoryId: 'accessibility_ux',
      evidenceLabel: 'Linux desktop accessibility-tool audit',
      requiresPhysicalTarget: true,
      requiresExternalTooling: true,
    ),
    QaCheckDefinition(
      id: 'large_text_scaling',
      categoryId: 'accessibility_ux',
      evidenceLabel:
          'Large text and scaling review on small phones and desktop windows',
      requiresPhysicalTarget: true,
    ),
    QaCheckDefinition(
      id: 'keyboard_only_desktop',
      categoryId: 'accessibility_ux',
      evidenceLabel: 'Keyboard-only end-to-end desktop review',
      requiresPhysicalTarget: true,
    ),
    QaCheckDefinition(
      id: 'reduced_motion_review',
      categoryId: 'accessibility_ux',
      evidenceLabel: 'Reduced-motion behavior review',
      requiresPhysicalTarget: true,
    ),
    QaCheckDefinition(
      id: 'batch_large_text_keyboard',
      categoryId: 'accessibility_ux',
      evidenceLabel:
          'Batch conversion with large text and keyboard-only interaction',
      requiresPhysicalTarget: true,
    ),
    QaCheckDefinition(
      id: 'android_icon_visual_review',
      categoryId: 'branding_package',
      evidenceLabel: 'Android launcher icon review across legacy, adaptive, and themed masks',
      requiresPhysicalTarget: true,
    ),
    QaCheckDefinition(
      id: 'apple_icon_visual_review',
      categoryId: 'branding_package',
      evidenceLabel: 'iOS and macOS icon review at small and large OS sizes',
      requiresPhysicalTarget: true,
    ),
    QaCheckDefinition(
      id: 'windows_icon_visual_review',
      categoryId: 'branding_package',
      evidenceLabel:
          'Windows icon review in Explorer, taskbar, Start, and shortcuts',
      requiresPhysicalTarget: true,
    ),
    QaCheckDefinition(
      id: 'linux_deb_visual_review',
      categoryId: 'branding_package',
      evidenceLabel: 'Linux Debian package launcher, menu, and task-switcher visual review',
      requiresPhysicalTarget: true,
    ),
    QaCheckDefinition(
      id: 'native_launch_splash_review',
      categoryId: 'branding_package',
      evidenceLabel:
          'Android and iOS release launch/splash assets including dark mode',
      requiresPhysicalTarget: true,
    ),
    QaCheckDefinition(
      id: 'real_release_screenshots',
      categoryId: 'branding_package',
      evidenceLabel: 'Real screenshots captured from tested release candidates',
      requiresPhysicalTarget: true,
    ),
    QaCheckDefinition(
      id: 'linux_deb_real_install',
      categoryId: 'branding_package',
      evidenceLabel: 'Linux .deb install, launch, upgrade, uninstall, microphone, and desktop integration',
      requiresPhysicalTarget: true,
    ),
    QaCheckDefinition(
      id: 'windows_portable_real_test',
      categoryId: 'branding_package',
      evidenceLabel: 'Windows portable ZIP extraction, audio, accessibility, branding, and cleanup',
      requiresPhysicalTarget: true,
    ),
    QaCheckDefinition(
      id: 'direct_multi_export_cross_platform',
      categoryId: 'external_export',
      evidenceLabel:
          'Direct original-file multi-export on every supported platform',
      requiresPhysicalTarget: true,
    ),
    QaCheckDefinition(
      id: 'mixed_success_missing_source',
      categoryId: 'external_export',
      evidenceLabel: 'Mixed-success direct export when one source disappears before copying',
      requiresExternalTooling: true,
    ),
    QaCheckDefinition(
      id: 'directory_picker_cross_platform',
      categoryId: 'external_export',
      evidenceLabel: 'Directory-picker availability and behavior on all maintained platforms',
      requiresPhysicalTarget: true,
    ),
    QaCheckDefinition(
      id: 'real_folder_collision_numbering',
      categoryId: 'external_export',
      evidenceLabel: 'Collision-safe numbering in real user-selected folders',
      requiresPhysicalTarget: true,
    ),
    QaCheckDefinition(
      id: 'destination_permission_revocation',
      categoryId: 'external_export',
      evidenceLabel:
          'Destination disappearance or permission revocation after selection',
      requiresPhysicalTarget: true,
    ),
    QaCheckDefinition(
      id: 'external_copy_low_storage',
      categoryId: 'external_export',
      evidenceLabel: 'Low-storage behavior during external copies',
      requiresPhysicalTarget: true,
    ),
    QaCheckDefinition(
      id: 'stop_after_current_long_conversion',
      categoryId: 'external_export',
      evidenceLabel: 'Stop-after-current behavior during long conversions',
      requiresPhysicalTarget: true,
    ),
    QaCheckDefinition(
      id: 'navigate_away_batch_conversion',
      categoryId: 'external_export',
      evidenceLabel:
          'Closing or navigating away from Batch Convert while processing',
      requiresPhysicalTarget: true,
    ),
    QaCheckDefinition(
      id: 'very_large_mixed_export_batch',
      categoryId: 'external_export',
      evidenceLabel: 'Very large and mixed-format batch export profiling',
      requiresExternalTooling: true,
    ),
  ];

  static final Set<String> checkIds = checks.map((check) => check.id).toSet();

  static List<QaCheckDefinition> checksForCategory(String categoryId) => checks
      .where((check) => check.categoryId == categoryId)
      .toList(growable: false);

  static QaCheckDefinition? checkById(String id) {
    for (final check in checks) {
      if (check.id == id) {
        return check;
      }
    }
    return null;
  }
}
