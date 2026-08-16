import 'dart:convert';

import '../core/constants.dart';
import 'settings_service.dart';
import 'storage_service.dart';

class DiagnosticReport {
  const DiagnosticReport._({
    required this.generatedAtUtc,
    required this.appVersion,
    required this.platform,
    required this.operatingSystemVersion,
    required this.localeName,
    required this.dartVersion,
    required this.processorCount,
    required this.savedRecordings,
    required this.trashRecordings,
    required this.favoriteRecordings,
    required this.pinnedRecordings,
    required this.storageStats,
    required this.storageProbeSucceeded,
    required this.recorderStatus,
    required this.inputDeviceCount,
    required this.inputProbeSucceeded,
    required this.customInputSelected,
    required this.settings,
  });

  static const schemaVersion = 1;

  final DateTime generatedAtUtc;
  final String appVersion;
  final String platform;
  final String operatingSystemVersion;
  final String localeName;
  final String dartVersion;
  final int processorCount;
  final int savedRecordings;
  final int trashRecordings;
  final int favoriteRecordings;
  final int pinnedRecordings;
  final StorageStats? storageStats;
  final bool storageProbeSucceeded;
  final String recorderStatus;
  final int? inputDeviceCount;
  final bool inputProbeSucceeded;
  final bool customInputSelected;
  final SettingsSnapshot settings;

  Map<String, Object?> toJsonObject() {
    final recording = settings.recording;
    final storage = storageStats;
    return {
      'schemaVersion': schemaVersion,
      'generatedAtUtc': generatedAtUtc.toUtc().toIso8601String(),
      'privacy': const {
        'containsRecordingContent': false,
        'containsRecordingTitles': false,
        'containsFilePaths': false,
        'containsNotesTagsOrBookmarks': false,
        'containsInputDeviceNames': false,
      },
      'app': {'name': AppConstants.appName, 'version': appVersion},
      'runtime': {
        'platform': platform,
        'operatingSystemVersion': operatingSystemVersion,
        'locale': localeName,
        'dartVersion': dartVersion,
        'processorCount': processorCount,
      },
      'library': {
        'savedRecordings': savedRecordings,
        'trashRecordings': trashRecordings,
        'favoriteRecordings': favoriteRecordings,
        'pinnedRecordings': pinnedRecordings,
      },
      'storage': {
        'probeSucceeded': storageProbeSucceeded,
        'recordingsBytes': storage?.recordingsBytes,
        'trashBytes': storage?.trashBytes,
        'temporaryBytes': storage?.temporaryBytes,
        'recordingFileCount': storage?.recordingCount,
        'trashFileCount': storage?.trashCount,
        'temporaryFileCount': storage?.temporaryFileCount,
        'totalManagedBytes': storage?.totalManagedBytes,
      },
      'recorder': {
        'status': recorderStatus,
        'inputProbeSucceeded': inputProbeSucceeded,
        'inputDeviceCount': inputDeviceCount,
        'selectedInput': customInputSelected ? 'custom' : 'default',
      },
      'settings': {
        'recording': {
          'format': recording.format.name,
          'preset': recording.preset.name,
          'bitRate': recording.bitRate,
          'sampleRate': recording.sampleRate,
          'channels': recording.channels,
          'automaticGain': recording.autoGain,
          'echoCancellation': recording.echoCancel,
          'noiseSuppression': recording.noiseSuppress,
          'countdownSeconds': recording.countdownSeconds,
          'keepScreenAwake': recording.keepScreenAwake,
        },
        'playback': {
          'defaultSpeed': settings.defaultPlaybackSpeed,
          'skipIntervalSeconds': settings.skipIntervalSeconds,
          'skipSilence': settings.skipSilence,
        },
        'appearance': {
          'themeMode': settings.themeMode.name,
          'reducedMotion': settings.reducedMotion,
        },
        'safety': {'confirmPermanentDelete': settings.confirmDelete},
      },
    };
  }

  String toPrettyJson() =>
      const JsonEncoder.withIndent('  ').convert(toJsonObject());

  String toMarkdown() {
    final recording = settings.recording;
    final storage = storageStats;
    final buffer = StringBuffer()
      ..writeln('# ${AppConstants.appName} Diagnostics')
      ..writeln()
      ..writeln('Generated (UTC): ${generatedAtUtc.toUtc().toIso8601String()}')
      ..writeln('App version: $appVersion')
      ..writeln()
      ..writeln('## Privacy')
      ..writeln()
      ..writeln('- Recording content: not included')
      ..writeln(
        '- Recording titles, file paths, notes, tags, and bookmarks: not included',
      )
      ..writeln('- Input-device names: not included')
      ..writeln()
      ..writeln('## Runtime')
      ..writeln()
      ..writeln('- Platform: $platform')
      ..writeln('- OS version: $operatingSystemVersion')
      ..writeln('- Locale: $localeName')
      ..writeln('- Dart: $dartVersion')
      ..writeln('- Logical processors: $processorCount')
      ..writeln()
      ..writeln('## Library')
      ..writeln()
      ..writeln('- Saved recordings: $savedRecordings')
      ..writeln('- Trash recordings: $trashRecordings')
      ..writeln('- Favorites: $favoriteRecordings')
      ..writeln('- Pinned: $pinnedRecordings')
      ..writeln()
      ..writeln('## Storage')
      ..writeln()
      ..writeln('- Probe succeeded: $storageProbeSucceeded')
      ..writeln('- Recordings bytes: ${storage?.recordingsBytes ?? 'unavailable'}')
      ..writeln('- Trash bytes: ${storage?.trashBytes ?? 'unavailable'}')
      ..writeln('- Temporary bytes: ${storage?.temporaryBytes ?? 'unavailable'}')
      ..writeln(
        '- Total managed bytes: ${storage?.totalManagedBytes ?? 'unavailable'}',
      )
      ..writeln()
      ..writeln('## Recorder')
      ..writeln()
      ..writeln('- Status: $recorderStatus')
      ..writeln('- Input probe succeeded: $inputProbeSucceeded')
      ..writeln('- Input-device count: ${inputDeviceCount ?? 'unavailable'}')
      ..writeln('- Selected input: ${customInputSelected ? 'custom' : 'default'}')
      ..writeln()
      ..writeln('## Recording settings')
      ..writeln()
      ..writeln('- Format: ${recording.format.name}')
      ..writeln('- Preset: ${recording.preset.name}')
      ..writeln('- Bit rate: ${recording.bitRate}')
      ..writeln('- Sample rate: ${recording.sampleRate}')
      ..writeln('- Channels: ${recording.channels}')
      ..writeln('- Automatic gain: ${recording.autoGain}')
      ..writeln('- Echo cancellation: ${recording.echoCancel}')
      ..writeln('- Noise suppression: ${recording.noiseSuppress}')
      ..writeln('- Countdown seconds: ${recording.countdownSeconds}')
      ..writeln('- Keep screen awake: ${recording.keepScreenAwake}')
      ..writeln()
      ..writeln('## Playback and UI settings')
      ..writeln()
      ..writeln('- Default playback speed: ${settings.defaultPlaybackSpeed}')
      ..writeln('- Skip interval seconds: ${settings.skipIntervalSeconds}')
      ..writeln('- Skip silence: ${settings.skipSilence}')
      ..writeln('- Theme: ${settings.themeMode.name}')
      ..writeln('- Reduced motion: ${settings.reducedMotion}')
      ..writeln('- Confirm permanent delete: ${settings.confirmDelete}');
    return buffer.toString();
  }
}

class DiagnosticReportService {
  const DiagnosticReportService();

  DiagnosticReport build({
    required DateTime generatedAt,
    required String appVersion,
    required String platform,
    required String operatingSystemVersion,
    required String localeName,
    required String dartVersion,
    required int processorCount,
    required int savedRecordings,
    required int trashRecordings,
    required int favoriteRecordings,
    required int pinnedRecordings,
    required StorageStats? storageStats,
    required bool storageProbeSucceeded,
    required String recorderStatus,
    required int? inputDeviceCount,
    required bool inputProbeSucceeded,
    required bool customInputSelected,
    required SettingsSnapshot settings,
  }) {
    return DiagnosticReport._(
      generatedAtUtc: generatedAt.toUtc(),
      appVersion: appVersion,
      platform: platform,
      operatingSystemVersion: operatingSystemVersion,
      localeName: localeName,
      dartVersion: dartVersion,
      processorCount: processorCount,
      savedRecordings: savedRecordings,
      trashRecordings: trashRecordings,
      favoriteRecordings: favoriteRecordings,
      pinnedRecordings: pinnedRecordings,
      storageStats: storageStats,
      storageProbeSucceeded: storageProbeSucceeded,
      recorderStatus: recorderStatus,
      inputDeviceCount: inputDeviceCount,
      inputProbeSucceeded: inputProbeSucceeded,
      customInputSelected: customInputSelected,
      settings: settings,
    );
  }
}
