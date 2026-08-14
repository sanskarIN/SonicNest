import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../core/formatters.dart';
import '../l10n/app_localizations.dart';
import '../models/recording_settings.dart';
import '../services/recorder_service.dart';
import '../widgets/waveform_view.dart';

class RecorderScreen extends StatelessWidget {
  const RecorderScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final recorder = controller.recorder;
    final settings = controller.settings.recording;
    final active = recorder.isActive;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          l10n.recorder,
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          '${_presetLabel(settings.preset, l10n)} • ${settings.format.label} • '
          '${settings.sampleRate ~/ 1000} kHz • '
          '${settings.channels == 1 ? l10n.mono : l10n.stereo}',
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StatusDot(
                      active: recorder.status == RecorderStatus.recording,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _statusText(recorder, l10n),
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (recorder.status == RecorderStatus.countdown)
                  Semantics(
                    liveRegion: true,
                    label: l10n.recordingStartsIn(
                      recorder.countdownRemaining,
                    ),
                    child: Text(
                      '${recorder.countdownRemaining}',
                      style: Theme.of(context)
                          .textTheme
                          .displayLarge
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  )
                else
                  Text(
                    formatDuration(recorder.elapsed),
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall
                        ?.copyWith(fontFeatures: const []),
                  ),
                const SizedBox(height: 18),
                WaveformView(samples: recorder.waveform, height: 150),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: recorder.amplitude.clamp(0.0, 1.0).toDouble(),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (recorder.clipping)
                      Tooltip(
                        message: l10n.inputIsClipping,
                        child: const Icon(Icons.warning_amber_rounded),
                      ),
                  ],
                ),
                const SizedBox(height: 22),
                _Controls(controller: controller),
                if (recorder.isCapturing) ...[
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: recorder.addMarker,
                    icon: const Icon(Icons.bookmark_add_outlined),
                    label: Text(l10n.addMarker(recorder.markers.length)),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Wrap(
              spacing: 18,
              runSpacing: 12,
              children: [
                _InfoChip(icon: Icons.tune, label: settings.format.label),
                _InfoChip(
                  icon: Icons.speed,
                  label: '${settings.bitRate ~/ 1000} kbps',
                ),
                _InfoChip(
                  icon: Icons.graphic_eq,
                  label: '${settings.sampleRate} Hz',
                ),
                _InfoChip(
                  icon: Icons.spatial_audio_off,
                  label: settings.channels == 1 ? l10n.mono : l10n.stereo,
                ),
                if (settings.noiseSuppress)
                  _InfoChip(
                    icon: Icons.noise_control_off,
                    label: l10n.noiseSuppression,
                  ),
                if (settings.echoCancel)
                  _InfoChip(
                    icon: Icons.speaker_group_outlined,
                    label: l10n.echoCancellation,
                  ),
              ],
            ),
          ),
        ),
        if (recorder.lastError != null) ...[
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.error_outline),
              title: Text(l10n.recorderError),
              subtitle: Text(recorder.lastError!),
              trailing: TextButton(
                onPressed: recorder.acknowledgeError,
                child: Text(l10n.dismiss),
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        _PresetSelector(controller: controller, enabled: !active),
      ],
    );
  }

  String _statusText(
    RecorderService recorder,
    AppLocalizations l10n,
  ) =>
      switch (recorder.status) {
        RecorderStatus.idle => l10n.ready,
        RecorderStatus.countdown =>
          l10n.startingIn(recorder.countdownRemaining),
        RecorderStatus.recording => l10n.recordingStatus,
        RecorderStatus.paused => l10n.pausedStatus,
        RecorderStatus.processing => l10n.processingAudio,
        RecorderStatus.error => l10n.needsAttention,
      };

  String _presetLabel(QualityPreset preset, AppLocalizations l10n) =>
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

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.outline,
        ),
      );
}

class _Controls extends StatelessWidget {
  const _Controls({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final recorder = controller.recorder;
    if (recorder.status == RecorderStatus.processing) {
      return const CircularProgressIndicator();
    }
    if (recorder.status == RecorderStatus.countdown) {
      return OutlinedButton.icon(
        onPressed: controller.cancelRecording,
        icon: const Icon(Icons.close),
        label: Text(l10n.cancelCountdown),
      );
    }
    if (recorder.status == RecorderStatus.idle ||
        recorder.status == RecorderStatus.error) {
      return Semantics(
        button: true,
        label: l10n.startRecording,
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
          ),
          onPressed: () async {
            try {
              await controller.startRecording();
            } catch (error) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$error')),
                );
              }
            }
          },
          icon: const Icon(Icons.mic),
          label: Text(l10n.startRecording),
        ),
      );
    }
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        FilledButton.tonalIcon(
          onPressed: recorder.status == RecorderStatus.recording
              ? controller.pauseRecording
              : controller.resumeRecording,
          icon: Icon(
            recorder.status == RecorderStatus.recording
                ? Icons.pause
                : Icons.play_arrow,
          ),
          label: Text(
            recorder.status == RecorderStatus.recording
                ? l10n.pause
                : l10n.resume,
          ),
        ),
        FilledButton.icon(
          onPressed: () async {
            try {
              await controller.stopRecording();
              controller.setNavigationIndex(2);
            } catch (error) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$error')),
                );
              }
            }
          },
          icon: const Icon(Icons.stop),
          label: Text(l10n.stopAndSave),
        ),
        OutlinedButton.icon(
          onPressed: controller.cancelRecording,
          icon: const Icon(Icons.delete_outline),
          label: Text(l10n.discard),
        ),
      ],
    );
  }
}

class _PresetSelector extends StatelessWidget {
  const _PresetSelector({required this.controller, required this.enabled});

  final AppController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.qualityPreset,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<QualityPreset>(
              initialValue: controller.settings.recording.preset,
              items: QualityPreset.values
                  .map(
                    (preset) => DropdownMenuItem(
                      value: preset,
                      child: Text(_label(preset, l10n)),
                    ),
                  )
                  .toList(),
              onChanged: enabled
                  ? (preset) {
                      if (preset != null) {
                        controller.updateRecordingSettings(
                          RecordingSettings.forPreset(preset),
                        );
                      }
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  String _label(QualityPreset preset, AppLocalizations l10n) => switch (preset) {
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

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(label),
        ],
      );
}
