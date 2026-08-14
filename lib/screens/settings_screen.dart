import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../core/formatters.dart';
import '../l10n/app_localizations.dart';
import '../models/recording_settings.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = controller.settings;
    final recording = settings.recording;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              l10n.settings,
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 18),
            _Section(
              title: l10n.recordingSettingsSection,
              icon: Icons.mic_outlined,
              children: [
                DropdownButtonFormField<QualityPreset>(
                  initialValue: recording.preset,
                  decoration: InputDecoration(labelText: l10n.qualityPreset),
                  items: QualityPreset.values
                      .map(
                        (preset) => DropdownMenuItem(
                          value: preset,
                          child: Text(_presetLabel(preset, l10n)),
                        ),
                      )
                      .toList(),
                  onChanged: (preset) {
                    if (preset != null) {
                      controller.updateRecordingSettings(
                        RecordingSettings.forPreset(preset),
                      );
                    }
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<RecordingFormat>(
                  initialValue: recording.format,
                  decoration: InputDecoration(labelText: l10n.defaultFormat),
                  items: RecordingFormat.values
                      .map(
                        (format) => DropdownMenuItem(
                          value: format,
                          child: Text(format.label),
                        ),
                      )
                      .toList(),
                  onChanged: (format) {
                    if (format != null) {
                      controller.updateRecordingSettings(
                        recording.copyWith(
                          format: format,
                          preset: QualityPreset.custom,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _bitRates.contains(recording.bitRate)
                            ? recording.bitRate
                            : 128000,
                        decoration: InputDecoration(labelText: l10n.bitrate),
                        items: _bitRates
                            .map(
                              (rate) => DropdownMenuItem(
                                value: rate,
                                child: Text('${rate ~/ 1000} kbps'),
                              ),
                            )
                            .toList(),
                        onChanged: (rate) {
                          if (rate != null) {
                            controller.updateRecordingSettings(
                              recording.copyWith(
                                bitRate: rate,
                                preset: QualityPreset.custom,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue:
                            _sampleRates.contains(recording.sampleRate)
                            ? recording.sampleRate
                            : 44100,
                        decoration: InputDecoration(labelText: l10n.sampleRate),
                        items: _sampleRates
                            .map(
                              (rate) => DropdownMenuItem(
                                value: rate,
                                child: Text(_sampleRateLabel(rate)),
                              ),
                            )
                            .toList(),
                        onChanged: (rate) {
                          if (rate != null) {
                            controller.updateRecordingSettings(
                              recording.copyWith(
                                sampleRate: rate,
                                preset: QualityPreset.custom,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SegmentedButton<int>(
                  segments: [
                    ButtonSegment(
                      value: 1,
                      icon: const Icon(Icons.spatial_audio_off),
                      label: Text(l10n.mono),
                    ),
                    ButtonSegment(
                      value: 2,
                      icon: const Icon(Icons.spatial_audio),
                      label: Text(l10n.stereo),
                    ),
                  ],
                  selected: {recording.channels},
                  onSelectionChanged: (value) =>
                      controller.updateRecordingSettings(
                        recording.copyWith(
                          channels: value.first,
                          preset: QualityPreset.custom,
                        ),
                      ),
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.automaticGainControl),
                  subtitle: Text(l10n.automaticGainHint),
                  value: recording.autoGain,
                  onChanged: (value) => controller.updateRecordingSettings(
                    recording.copyWith(
                      autoGain: value,
                      preset: QualityPreset.custom,
                    ),
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.echoCancellation),
                  value: recording.echoCancel,
                  onChanged: (value) => controller.updateRecordingSettings(
                    recording.copyWith(
                      echoCancel: value,
                      preset: QualityPreset.custom,
                    ),
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.noiseSuppression),
                  value: recording.noiseSuppress,
                  onChanged: (value) => controller.updateRecordingSettings(
                    recording.copyWith(
                      noiseSuppress: value,
                      preset: QualityPreset.custom,
                    ),
                  ),
                ),
                const Divider(height: 28),
                Text(
                  l10n.smartNaming,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  key: ValueKey('prefix-${recording.namingPrefix}'),
                  initialValue: recording.namingPrefix,
                  decoration: InputDecoration(
                    labelText: l10n.prefix,
                    hintText: l10n.recordingDefaultPrefix,
                  ),
                  maxLength: 40,
                  onFieldSubmitted: (value) =>
                      controller.updateRecordingSettings(
                        recording.copyWith(
                          namingPrefix: value.trim().isEmpty
                              ? l10n.recordingDefaultPrefix
                              : value.trim(),
                        ),
                      ),
                ),
                TextFormField(
                  key: ValueKey('template-${recording.namingTemplate}'),
                  initialValue: recording.namingTemplate,
                  decoration: InputDecoration(
                    labelText: l10n.filenameTemplate,
                    hintText: l10n.filenameTemplateHint,
                    helperText: l10n.filenameTemplateHelper,
                  ),
                  maxLength: 120,
                  onFieldSubmitted: (value) =>
                      controller.updateRecordingSettings(
                        recording.copyWith(namingTemplate: value.trim()),
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        key: ValueKey('category-${recording.namingCategory}'),
                        initialValue: recording.namingCategory,
                        decoration: InputDecoration(
                          labelText: l10n.categoryToken,
                        ),
                        maxLength: 30,
                        onFieldSubmitted: (value) =>
                            controller.updateRecordingSettings(
                              recording.copyWith(namingCategory: value.trim()),
                            ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        key: ValueKey('suffix-${recording.namingSuffix}'),
                        initialValue: recording.namingSuffix,
                        decoration: InputDecoration(
                          labelText: l10n.suffixToken,
                        ),
                        maxLength: 30,
                        onFieldSubmitted: (value) =>
                            controller.updateRecordingSettings(
                              recording.copyWith(namingSuffix: value.trim()),
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  initialValue: recording.countdownSeconds,
                  decoration: InputDecoration(labelText: l10n.countdown),
                  items: const [0, 3, 5, 10]
                      .map(
                        (seconds) => DropdownMenuItem(
                          value: seconds,
                          child: Text(
                            seconds == 0 ? l10n.off : l10n.seconds(seconds),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (seconds) {
                    if (seconds != null) {
                      controller.updateRecordingSettings(
                        recording.copyWith(countdownSeconds: seconds),
                      );
                    }
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.keepScreenAwakeDuringRecording),
                  value: recording.keepScreenAwake,
                  onChanged: (value) => controller.updateRecordingSettings(
                    recording.copyWith(keepScreenAwake: value),
                  ),
                ),
              ],
            ),
            _Section(
              title: l10n.playbackSettingsSection,
              icon: Icons.play_circle_outline,
              children: [
                DropdownButtonFormField<double>(
                  initialValue:
                      _playbackSpeeds.contains(settings.defaultPlaybackSpeed)
                      ? settings.defaultPlaybackSpeed
                      : 1.0,
                  decoration: InputDecoration(
                    labelText: l10n.defaultPlaybackSpeed,
                  ),
                  items: _playbackSpeeds
                      .map(
                        (speed) => DropdownMenuItem(
                          value: speed,
                          child: Text('$speed×'),
                        ),
                      )
                      .toList(),
                  onChanged: (speed) {
                    if (speed != null) {
                      controller.updateSettings(
                        settings.copyWith(defaultPlaybackSpeed: speed),
                      );
                    }
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<int>(
                  initialValue:
                      _skipIntervals.contains(settings.skipIntervalSeconds)
                      ? settings.skipIntervalSeconds
                      : 10,
                  decoration: InputDecoration(labelText: l10n.jumpInterval),
                  items: _skipIntervals
                      .map(
                        (seconds) => DropdownMenuItem(
                          value: seconds,
                          child: Text(l10n.seconds(seconds)),
                        ),
                      )
                      .toList(),
                  onChanged: (seconds) {
                    if (seconds != null) {
                      controller.updateSettings(
                        settings.copyWith(skipIntervalSeconds: seconds),
                      );
                    }
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.skipSilenceByDefault),
                  subtitle: Text(l10n.skipSilenceBackendHint),
                  value: settings.skipSilence,
                  onChanged: (value) => controller.updateSettings(
                    settings.copyWith(skipSilence: value),
                  ),
                ),
              ],
            ),
            _Section(
              title: l10n.appearanceAccessibility,
              icon: Icons.palette_outlined,
              children: [
                SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: const Icon(Icons.brightness_auto),
                      label: Text(l10n.systemTheme),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: const Icon(Icons.light_mode),
                      label: Text(l10n.lightTheme),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: const Icon(Icons.dark_mode),
                      label: Text(l10n.darkTheme),
                    ),
                  ],
                  selected: {settings.themeMode},
                  onSelectionChanged: (value) => controller.updateSettings(
                    settings.copyWith(themeMode: value.first),
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.reduceMotion),
                  subtitle: Text(l10n.reduceMotionHint),
                  value: settings.reducedMotion,
                  onChanged: (value) => controller.updateSettings(
                    settings.copyWith(reducedMotion: value),
                  ),
                ),
              ],
            ),
            _Section(
              title: l10n.safetyStorage,
              icon: Icons.shield_outlined,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.confirmPermanentDeletion),
                  subtitle: Text(l10n.confirmPermanentDeletionHint),
                  value: settings.confirmDelete,
                  onChanged: (value) => controller.updateSettings(
                    settings.copyWith(confirmDelete: value),
                  ),
                ),
                FutureBuilder<StorageStats>(
                  future: controller.storage.stats(),
                  builder: (context, snapshot) {
                    final stats = snapshot.data;
                    if (stats == null) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.storage_outlined),
                        title: Text(l10n.managedStorage),
                        subtitle: const LinearProgressIndicator(),
                      );
                    }
                    return Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.storage_outlined),
                          title: Text(l10n.managedStorage),
                          subtitle: Text(
                            l10n.storageSummary(
                              formatBytes(stats.totalManagedBytes),
                              formatBytes(stats.recordingsBytes),
                              formatBytes(stats.trashBytes),
                            ),
                          ),
                          trailing: Text(
                            l10n.savedCount(stats.recordingCount),
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                        if (stats.temporaryFileCount > 0)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(
                              Icons.cleaning_services_outlined,
                            ),
                            title: Text(l10n.temporaryAudioFiles),
                            subtitle: Text(
                              l10n.temporaryFilesSummary(
                                stats.temporaryFileCount,
                                formatBytes(stats.temporaryBytes),
                              ),
                            ),
                            trailing: TextButton(
                              onPressed: controller.recorder.isActive
                                  ? null
                                  : controller.clearTemporaryStorage,
                              child: Text(l10n.clean),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.lock_outline),
                  title: Text(l10n.offlineFirstRecordings),
                  subtitle: Text(l10n.offlineFirstRecordingsHint),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static const _bitRates = [64000, 96000, 128000, 192000, 256000, 320000];
  static const _sampleRates = [8000, 16000, 22050, 44100, 48000, 96000];
  static const _playbackSpeeds = [.5, .75, 1.0, 1.25, 1.5, 1.75, 2.0];
  static const _skipIntervals = [5, 10, 15, 30];

  static String _sampleRateLabel(int rate) =>
      rate == 22050 ? '22.05 kHz' : '${rate / 1000} kHz';

  static String _presetLabel(QualityPreset preset, AppLocalizations l10n) =>
      switch (preset) {
        QualityPreset.speech => l10n.speech,
        QualityPreset.meeting => l10n.meeting,
        QualityPreset.lecture => l10n.lecture,
        QualityPreset.interview => l10n.interview,
        QualityPreset.podcast => l10n.podcast,
        QualityPreset.music => l10n.music,
        QualityPreset.highQuality => l10n.highQuality,
        QualityPreset.lossless => l10n.lossless,
        QualityPreset.smallFile => l10n.smallFile,
        QualityPreset.custom => l10n.custom,
      };
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
