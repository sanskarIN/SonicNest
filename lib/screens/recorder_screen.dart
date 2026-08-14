import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../core/formatters.dart';
import '../models/recording_settings.dart';
import '../services/recorder_service.dart';
import '../widgets/waveform_view.dart';

class RecorderScreen extends StatelessWidget {
  const RecorderScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final recorder = controller.recorder;
    final settings = controller.settings.recording;
    final active = recorder.isActive;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Recorder',
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          '${settings.preset.name} • ${settings.format.label} • '
          '${settings.sampleRate ~/ 1000} kHz • '
          '${settings.channels == 1 ? 'Mono' : 'Stereo'}',
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
                      _statusText(recorder.status),
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
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
                      const Tooltip(
                        message: 'Input is clipping',
                        child: Icon(Icons.warning_amber_rounded),
                      ),
                  ],
                ),
                const SizedBox(height: 22),
                _Controls(controller: controller),
                if (active) ...[
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: recorder.addMarker,
                    icon: const Icon(Icons.bookmark_add_outlined),
                    label: Text('Add marker (${recorder.markers.length})'),
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
                  label: settings.channels == 1 ? 'Mono' : 'Stereo',
                ),
                if (settings.noiseSuppress)
                  const _InfoChip(
                    icon: Icons.noise_control_off,
                    label: 'Noise suppression',
                  ),
                if (settings.echoCancel)
                  const _InfoChip(
                    icon: Icons.speaker_group_outlined,
                    label: 'Echo cancellation',
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
              title: const Text('Recorder error'),
              subtitle: Text(recorder.lastError!),
              trailing: TextButton(
                onPressed: recorder.acknowledgeError,
                child: const Text('Dismiss'),
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        _PresetSelector(controller: controller, enabled: !active),
      ],
    );
  }

  String _statusText(RecorderStatus status) => switch (status) {
        RecorderStatus.idle => 'Ready',
        RecorderStatus.recording => 'Recording',
        RecorderStatus.paused => 'Paused',
        RecorderStatus.processing => 'Processing audio',
        RecorderStatus.error => 'Needs attention',
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
    final recorder = controller.recorder;
    if (recorder.status == RecorderStatus.processing) {
      return const CircularProgressIndicator();
    }
    if (recorder.status == RecorderStatus.idle ||
        recorder.status == RecorderStatus.error) {
      return Semantics(
        button: true,
        label: 'Start recording',
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
          label: const Text('Start recording'),
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
            recorder.status == RecorderStatus.recording ? 'Pause' : 'Resume',
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
          label: const Text('Stop & save'),
        ),
        OutlinedButton.icon(
          onPressed: controller.cancelRecording,
          icon: const Icon(Icons.delete_outline),
          label: const Text('Discard'),
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
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quality preset',
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
                        child: Text(_label(preset)),
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

  String _label(QualityPreset preset) => switch (preset) {
        QualityPreset.highQuality => 'High Quality',
        QualityPreset.smallFile => 'Small File',
        _ => '${preset.name[0].toUpperCase()}${preset.name.substring(1)}',
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
