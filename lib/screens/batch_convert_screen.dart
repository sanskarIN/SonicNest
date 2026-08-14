import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

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
  bool _stopRequested = false;
  int _completed = 0;
  int _total = 0;
  String? _status;
  String? _exportDirectory;

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
                          const SizedBox(height: 10),
                          SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Copy to an external folder'),
                            subtitle: Text(
                              _exportDirectory ??
                                  'Keep converted copies only in the SonicNest library.',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            value: _exportDirectory != null,
                            onChanged: _processing
                                ? null
                                : (enabled) async {
                                    if (!enabled) {
                                      setState(() => _exportDirectory = null);
                                      return;
                                    }
                                    await _chooseExportDirectory();
                                  },
                          ),
                          if (_exportDirectory != null)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed:
                                    _processing ? null : _chooseExportDirectory,
                                icon: const Icon(Icons.folder_open_outlined),
                                label: const Text('Change export folder'),
                              ),
                            ),
                          const SizedBox(height: 10),
                          if (_processing)
                            OutlinedButton.icon(
                              onPressed: _stopRequested
                                  ? null
                                  : () {
                                      setState(() {
                                        _stopRequested = true;
                                        _status =
                                            'Stop requested. The current file will finish safely.';
                                      });
                                    },
                              icon: const Icon(Icons.stop_circle_outlined),
                              label: Text(
                                _stopRequested
                                    ? 'Stopping after current file…'
                                    : 'Stop after current file',
                              ),
                            )
                          else
                            FilledButton.icon(
                              onPressed: selected.isEmpty
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
                              _processing && !_stopRequested
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
                              secondary:
                                  const Icon(Icons.audio_file_outlined),
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

  Future<void> _chooseExportDirectory() async {
    final directory = await controller.external.chooseExportDirectory();
    if (!mounted || directory == null) {
      return;
    }
    setState(() => _exportDirectory = directory);
  }

  Future<void> _convert(List<RecordingEntry> entries) async {
    if (_processing || entries.isEmpty) {
      return;
    }
    final format = _targetFormat;
    final exportDirectory = _exportDirectory;
    setState(() {
      _processing = true;
      _stopRequested = false;
      _completed = 0;
      _total = entries.length;
      _status = null;
    });

    final failures = <String>[];
    final exportFailures = <String>[];
    var successes = 0;
    var externalCopies = 0;
    var stopped = false;

    for (final entry in entries) {
      if (_stopRequested) {
        stopped = true;
        break;
      }

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

        if (exportDirectory != null) {
          try {
            await _copyToExternalDirectory(output, exportDirectory);
            externalCopies++;
          } catch (error) {
            exportFailures.add('${entry.title}: $error');
          }
        }
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

      if (_stopRequested) {
        stopped = true;
        break;
      }
    }

    if (!mounted) {
      return;
    }

    final conversionFailureText = failures.isEmpty
        ? ''
        : ' ${failures.length} conversion failed: '
            '${failures.take(2).join(' | ')}';
    final exportText = exportDirectory == null
        ? ''
        : exportFailures.isEmpty
            ? ' $externalCopies copied to the export folder.'
            : ' $externalCopies copied externally; '
                '${exportFailures.length} external copy failed: '
                '${exportFailures.take(2).join(' | ')}';

    setState(() {
      _processing = false;
      _stopRequested = false;
      _status = stopped
          ? 'Stopped after $_completed of $_total. '
              '$successes converted.$conversionFailureText$exportText'
          : failures.isEmpty
              ? '$successes converted copies created.$exportText'
              : '$successes converted; ${failures.length} failed. '
                  '${failures.take(2).join(' | ')}$exportText';
      _selectedIds.clear();
    });
  }

  Future<String> _copyToExternalDirectory(
    String sourcePath,
    String directoryPath,
  ) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw StateError('Converted source file no longer exists.');
    }

    final directory = Directory(directoryPath);
    if (!await directory.exists()) {
      throw StateError('The selected export folder is unavailable.');
    }

    final fileName = p.basename(sourcePath);
    final stem = p.basenameWithoutExtension(fileName);
    final extension = p.extension(fileName);
    var candidate = p.join(directory.path, '$stem$extension');
    var suffix = 2;

    while (await File(candidate).exists()) {
      candidate = p.join(directory.path, '$stem ($suffix)$extension');
      suffix++;
    }

    final copied = await source.copy(candidate);
    return copied.path;
  }
}
