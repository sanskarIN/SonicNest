import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../models/recording_entry.dart';
import '../models/recording_settings.dart';

class BatchConvertScreen extends StatefulWidget {
  const BatchConvertScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<BatchConvertScreen> createState() => _BatchConvertScreenState();
}

class _BatchConvertScreenState extends State<BatchConvertScreen> {
  final Set<String> _selectedIds = <String>{};
  RecordingFormat _targetFormat = RecordingFormat.mp3;
  bool _processing = false;
  int _completed = 0;
  int _total = 0;
  String? _status;

  AppController get controller => widget.controller;

  List<RecordingEntry> get _entries => controller.recordings
      .where((entry) => !entry.isTrashed)
      .toList(growable: false)
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  @override
  Widget build(BuildContext context) {
    final entries = _entries;
    final selected = entries
        .where((entry) => _selectedIds.contains(entry.id))
        .toList(growable: false);
    final progress = _total <= 0 ? null : _completed / _total;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Batch Convert'),
        actions: [
          TextButton(
            onPressed: _processing || entries.isEmpty
                ? null
                : () {
                    setState(() {
                      if (_selectedIds.length == entries.length) {
                        _selectedIds.clear();
                      } else {
                        _selectedIds
                          ..clear()
                          ..addAll(entries.map((entry) => entry.id));
                      }
                    });
                  },
            child: Text(
              _selectedIds.length == entries.length && entries.isNotEmpty
                  ? 'Clear all'
                  : 'Select all',
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Create converted copies',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Select multiple library recordings. SonicNest creates new files and keeps every original untouched.',
                          ),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<RecordingFormat>(
                            initialValue: _targetFormat,
                            decoration: const InputDecoration(
                              labelText: 'Target format',
                            ),
                            items: RecordingFormat.values
                                .map(
                                  (format) => DropdownMenuItem(
                                    value: format,
                                    child: Text(format.label),
                                  ),
                                )
                                .toList(),
                            onChanged: _processing
                                ? null
                                : (format) {
                                    if (format != null) {
                                      setState(() => _targetFormat = format);
                                    }
                                  },
                          ),
                          const SizedBox(height: 14),
                          FilledButton.icon(
                            onPressed: _processing || selected.isEmpty
                                ? null
                                : () => _convert(selected),
                            icon: const Icon(Icons.multiple_stop_outlined),
                            label: Text(
                              'Convert ${selected.length} selected',
                            ),
                          ),
                          if (_processing || _status != null) ...[
                            const SizedBox(height: 14),
                            if (_processing)
                              LinearProgressIndicator(value: progress),
                            const SizedBox(height: 8),
                            Text(
                              _processing
                                  ? 'Converted $_completed of $_total'
                                  : _status!,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: entries.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Text(
                              'There are no saved recordings to batch convert yet.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          itemCount: entries.length,
                          itemBuilder: (context, index) {
                            final entry = entries[index];
                            final checked = _selectedIds.contains(entry.id);
                            return CheckboxListTile(
                              value: checked,
                              onChanged: _processing
                                  ? null
                                  : (value) {
                                      setState(() {
                                        if (value == true) {
                                          _selectedIds.add(entry.id);
                                        } else {
                                          _selectedIds.remove(entry.id);
                                        }
                                      });
                                    },
                              title: Text(entry.title),
                              subtitle: Text(
                                '${entry.format.label} • '
                                '${entry.sampleRate > 0 ? '${entry.sampleRate} Hz' : 'rate unknown'}',
                              ),
                              secondary: const Icon(Icons.audio_file_outlined),
                              controlAffinity: ListTileControlAffinity.leading,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _convert(List<RecordingEntry> entries) async {
    if (_processing || entries.isEmpty) {
      return;
    }
    final format = _targetFormat;
    setState(() {
      _processing = true;
      _completed = 0;
      _total = entries.length;
      _status = null;
    });

    final failures = <String>[];
    var successes = 0;
    for (final entry in entries) {
      String? output;
      try {
        final title = '${entry.title} ${format.label}';
        output = await controller.processor.transcode(
          inputPath: entry.filePath,
          outputTitle: title,
          format: format,
          bitRate: entry.bitRate > 0
              ? entry.bitRate
              : controller.settings.recording.bitRate,
          sampleRate: entry.sampleRate > 0
              ? entry.sampleRate
              : controller.settings.recording.sampleRate,
          channels: entry.channels > 0
              ? entry.channels
              : controller.settings.recording.channels,
        );
        await controller.addProcessedFile(
          output,
          title: title,
          format: format,
          markers: entry.markers,
        );
        successes++;
      } catch (error) {
        if (output != null) {
          await controller.storage.deleteIfExists(output);
        }
        failures.add('${entry.title}: $error');
      } finally {
        if (mounted) {
          setState(() => _completed++);
        }
      }
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _processing = false;
      _status = failures.isEmpty
          ? '$successes converted copies created.'
          : '$successes converted; ${failures.length} failed. '
              '${failures.take(2).join(' | ')}';
      _selectedIds.clear();
    });
  }
}
