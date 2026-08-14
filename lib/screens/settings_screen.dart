import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../core/formatters.dart';
import '../models/recording_settings.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final settings = controller.settings;
    final recording = settings.recording;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Settings',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 18),
            _Section(
              title: 'Recording',
              icon: Icons.mic_outlined,
              children: [
                DropdownButtonFormField<QualityPreset>(
                  initialValue: recording.preset,
                  decoration: const InputDecoration(labelText: 'Quality preset'),
                  items: QualityPreset.values
                      .map(
                        (preset) => DropdownMenuItem(
                          value: preset,
                          child: Text(_presetLabel(preset)),
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
                  decoration: const InputDecoration(labelText: 'Default format'),
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
                        decoration: const InputDecoration(labelText: 'Bitrate'),
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
                        initialValue: _sampleRates.contains(recording.sampleRate)
                            ? recording.sampleRate
                            : 44100,
                        decoration: const InputDecoration(labelText: 'Sample rate'),
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
                  segments: const [
                    ButtonSegment(
                      value: 1,
                      icon: Icon(Icons.spatial_audio_off),
                      label: Text('Mono'),
                    ),
                    ButtonSegment(
                      value: 2,
                      icon: Icon(Icons.spatial_audio),
                      label: Text('Stereo'),
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
                  title: const Text('Automatic gain control'),
                  subtitle: const Text(
                    'Ask the recording backend to keep voice levels more consistent when supported.',
                  ),
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
                  title: const Text('Echo cancellation'),
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
                  title: const Text('Noise suppression'),
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
                  'Smart naming',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  key: ValueKey('prefix-${recording.namingPrefix}'),
                  initialValue: recording.namingPrefix,
                  decoration: const InputDecoration(
                    labelText: 'Prefix',
                    hintText: 'Recording',
                  ),
                  maxLength: 40,
                  onFieldSubmitted: (value) =>
                      controller.updateRecordingSettings(
                    recording.copyWith(
                      namingPrefix:
                          value.trim().isEmpty ? 'Recording' : value.trim(),
                    ),
                  ),
                ),
                TextFormField(
                  key: ValueKey('template-${recording.namingTemplate}'),
                  initialValue: recording.namingTemplate,
                  decoration: const InputDecoration(
                    labelText: 'Filename template',
                    hintText: '{prefix}_{date}_{time}',
                    helperText:
                        'Tokens: {prefix} {suffix} {category} {date} {time} {sequence}',
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
                        decoration: const InputDecoration(labelText: 'Category token'),
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
                        decoration: const InputDecoration(labelText: 'Suffix token'),
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
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: recording.countdownSeconds,
                        decoration: const InputDecoration(labelText: 'Countdown'),
                        items: const [0, 3, 5, 10]
                            .map(
                              (seconds) => DropdownMenuItem(
                                value: seconds,
                                child: Text(
                                  seconds == 0 ? 'Off' : '$seconds seconds',
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
                    ),
                  ],
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Keep screen awake during recording'),
                  value: recording.keepScreenAwake,
                  onChanged: (value) => controller.updateRecordingSettings(
                    recording.copyWith(keepScreenAwake: value),
                  ),
                ),
              ],
            ),
            _Section(
              title: 'Playback',
              icon: Icons.play_circle_outline,
              children: [
                DropdownButtonFormField<double>(
                  initialValue:
                      _playbackSpeeds.contains(settings.defaultPlaybackSpeed)
                          ? settings.defaultPlaybackSpeed
                          : 1.0,
                  decoration: const InputDecoration(
                    labelText: 'Default playback speed',
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
                  decoration: const InputDecoration(labelText: 'Jump interval'),
                  items: _skipIntervals
                      .map(
                        (seconds) => DropdownMenuItem(
                          value: seconds,
                          child: Text('$seconds seconds'),
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
                  title: const Text('Skip silence by default'),
                  subtitle: const Text(
                    'Used where the active playback backend supports silence skipping.',
                  ),
                  value: settings.skipSilence,
                  onChanged: (value) => controller.updateSettings(
                    settings.copyWith(skipSilence: value),
                  ),
                ),
              ],
            ),
            _Section(
              title: 'Appearance & accessibility',
              icon: Icons.palette_outlined,
              children: [
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: Icon(Icons.brightness_auto),
                      label: Text('System'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode),
                      label: Text('Light'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode),
                      label: Text('Dark'),
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
                  title: const Text('Reduce motion'),
                  subtitle: const Text(
                    'Avoid non-essential animation and movement.',
                  ),
                  value: settings.reducedMotion,
                  onChanged: (value) => controller.updateSettings(
                    settings.copyWith(reducedMotion: value),
                  ),
                ),
              ],
            ),
            _Section(
              title: 'Safety & storage',
              icon: Icons.shield_outlined,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Confirm permanent deletion'),
                  subtitle: const Text(
                    'Trash remains recoverable until you permanently delete an item.',
                  ),
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
                      return const ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.storage_outlined),
                        title: Text('Managed storage'),
                        subtitle: LinearProgressIndicator(),
                      );
                    }
                    return Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.storage_outlined),
                          title: const Text('Managed storage'),
                          subtitle: Text(
                            '${formatBytes(stats.totalManagedBytes)} total • '
                            '${formatBytes(stats.recordingsBytes)} recordings • '
                            '${formatBytes(stats.trashBytes)} Trash',
                          ),
                          trailing: Text(
                            '${stats.recordingCount} saved',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                        if (stats.temporaryFileCount > 0)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.cleaning_services_outlined),
                            title: const Text('Temporary audio files'),
                            subtitle: Text(
                              '${stats.temporaryFileCount} files • '
                              '${formatBytes(stats.temporaryBytes)}',
                            ),
                            trailing: TextButton(
                              onPressed: controller.recorder.isActive
                                  ? null
                                  : () async {
                                      await controller.storage.clearTemporaryFiles();
                                      controller.notifyListeners();
                                    },
                              child: const Text('Clean'),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.lock_outline),
                  title: Text('Offline-first recordings'),
                  subtitle: Text(
                    'SonicNest stores recordings locally and does not upload microphone data by default.',
                  ),
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

  static String _presetLabel(QualityPreset preset) => switch (preset) {
        QualityPreset.highQuality => 'High Quality',
        QualityPreset.smallFile => 'Small File',
        _ => '${preset.name[0].toUpperCase()}${preset.name.substring(1)}',
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
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
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
