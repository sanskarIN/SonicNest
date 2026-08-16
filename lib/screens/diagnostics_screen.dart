import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/app_controller.dart';
import '../core/constants.dart';
import '../core/formatters.dart';
import '../l10n/app_localizations.dart';
import '../l10n/diagnostics_localizations.dart';
import '../models/recording_settings.dart';
import '../services/diagnostic_report_service.dart';
import '../services/storage_service.dart';

class DiagnosticsScreen extends StatefulWidget {
  const DiagnosticsScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends State<DiagnosticsScreen> {
  static const _reportService = DiagnosticReportService();

  DiagnosticReport? _report;
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _collect();
  }

  Future<void> _collect() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      StorageStats? storageStats;
      var storageProbeSucceeded = false;
      try {
        storageStats = await widget.controller.storage.stats();
        storageProbeSucceeded = true;
      } catch (_) {
        storageStats = null;
      }

      int? inputDeviceCount;
      var inputProbeSucceeded = false;
      if (!widget.controller.recorder.isActive) {
        try {
          inputDeviceCount =
              (await widget.controller.recorder.listInputDevices()).length;
          inputProbeSucceeded = true;
        } catch (_) {
          inputDeviceCount = null;
        }
      }

      final recordings = widget.controller.recordings;
      final activeRecordings = recordings.where((entry) => !entry.isTrashed);
      final report = _reportService.build(
        generatedAt: DateTime.now(),
        appVersion: AppConstants.appVersionWithBuild,
        platform: Platform.operatingSystem,
        operatingSystemVersion: Platform.operatingSystemVersion,
        localeName: Platform.localeName,
        dartVersion: Platform.version,
        processorCount: Platform.numberOfProcessors,
        savedRecordings: activeRecordings.length,
        trashRecordings: recordings.where((entry) => entry.isTrashed).length,
        favoriteRecordings: activeRecordings
            .where((entry) => entry.favorite)
            .length,
        pinnedRecordings: activeRecordings.where((entry) => entry.pinned).length,
        storageStats: storageStats,
        storageProbeSucceeded: storageProbeSucceeded,
        recorderStatus: widget.controller.recorder.status.name,
        inputDeviceCount: inputDeviceCount,
        inputProbeSucceeded: inputProbeSucceeded,
        customInputSelected: widget.controller.recorder.selectedDevice != null,
        settings: widget.controller.settings,
      );

      if (!mounted) {
        return;
      }
      setState(() {
        _report = report;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  Future<void> _copyJson() async {
    final report = _report;
    if (report == null) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: report.toPrettyJson()));
    if (!mounted) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.diagnosticsCopied)));
  }

  Future<void> _shareMarkdown() async {
    final report = _report;
    if (report == null) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    try {
      final path = await widget.controller.storage.uniqueTempPath(
        'SonicNest_Diagnostics_${DateTime.now().millisecondsSinceEpoch}',
        'md',
      );
      await File(path).writeAsString(report.toMarkdown(), flush: true);
      await widget.controller.external.shareFile(
        path,
        text: l10n.diagnosticsPrivacyDescription,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.diagnosticsShared)));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.diagnosticsShareFailed(error))),
      );
    }
  }

  String _boolLabel(AppLocalizations l10n, bool value) =>
      value ? l10n.diagnosticsEnabled : l10n.diagnosticsDisabled;

  String _probeLabel(AppLocalizations l10n, bool succeeded) =>
      succeeded ? l10n.diagnosticsSucceeded : l10n.diagnosticsUnavailable;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.diagnostics),
        actions: [
          IconButton(
            tooltip: l10n.diagnosticsRefresh,
            onPressed: _loading ? null : _collect,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: _buildBody(l10n),
        ),
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_loading) {
      return Semantics(
        label: l10n.diagnosticsLoading,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final error = _error;
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 44),
              const SizedBox(height: 12),
              Text(
                l10n.diagnosticsFailed(error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _collect,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    final report = _report!;
    final storage = report.storageStats;
    final recording = report.settings.recording;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          l10n.diagnosticsSubtitle,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.privacy_tip_outlined),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.diagnosticsPrivacyTitle,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(l10n.diagnosticsPrivacyDescription),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: _copyJson,
                      icon: const Icon(Icons.content_copy_outlined),
                      label: Text(l10n.diagnosticsCopyJson),
                    ),
                    FilledButton.icon(
                      onPressed: _shareMarkdown,
                      icon: const Icon(Icons.share_outlined),
                      label: Text(l10n.diagnosticsShareMarkdown),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _DiagnosticSection(
          title: l10n.diagnosticsRuntime,
          icon: Icons.computer_outlined,
          rows: [
            (l10n.diagnosticsVersion, AppConstants.appDisplayVersion),
            (l10n.diagnosticsPlatform, report.platform),
            (l10n.diagnosticsOsVersion, report.operatingSystemVersion),
            (l10n.diagnosticsLocale, report.localeName),
            (l10n.diagnosticsDartVersion, report.dartVersion),
            (
              l10n.diagnosticsProcessorCount,
              l10n.diagnosticsCount(report.processorCount),
            ),
          ],
        ),
        _DiagnosticSection(
          title: l10n.diagnosticsLibrary,
          icon: Icons.library_music_outlined,
          rows: [
            (l10n.diagnosticsSaved, l10n.diagnosticsCount(report.savedRecordings)),
            (l10n.diagnosticsTrash, l10n.diagnosticsCount(report.trashRecordings)),
            (
              l10n.diagnosticsFavorites,
              l10n.diagnosticsCount(report.favoriteRecordings),
            ),
            (l10n.diagnosticsPinned, l10n.diagnosticsCount(report.pinnedRecordings)),
          ],
        ),
        _DiagnosticSection(
          title: l10n.diagnosticsStorage,
          icon: Icons.storage_outlined,
          rows: [
            (
              l10n.diagnosticsProbeStatus,
              _probeLabel(l10n, report.storageProbeSucceeded),
            ),
            (
              l10n.diagnosticsTotalManaged,
              storage == null
                  ? l10n.diagnosticsUnavailable
                  : formatBytes(storage.totalManagedBytes),
            ),
            (
              l10n.recordings,
              storage == null
                  ? l10n.diagnosticsUnavailable
                  : formatBytes(storage.recordingsBytes),
            ),
            (
              l10n.diagnosticsTrash,
              storage == null
                  ? l10n.diagnosticsUnavailable
                  : formatBytes(storage.trashBytes),
            ),
            (
              l10n.diagnosticsTemporary,
              storage == null
                  ? l10n.diagnosticsUnavailable
                  : formatBytes(storage.temporaryBytes),
            ),
          ],
        ),
        _DiagnosticSection(
          title: l10n.diagnosticsRecorder,
          icon: Icons.mic_none_outlined,
          rows: [
            (l10n.diagnosticsRecorderStatus, report.recorderStatus),
            (
              l10n.diagnosticsProbeStatus,
              _probeLabel(l10n, report.inputProbeSucceeded),
            ),
            (
              l10n.diagnosticsInputCount,
              report.inputDeviceCount == null
                  ? l10n.diagnosticsUnavailable
                  : l10n.diagnosticsCount(report.inputDeviceCount!),
            ),
            (
              l10n.diagnosticsSelectedInput,
              report.customInputSelected
                  ? l10n.diagnosticsCustomInput
                  : l10n.diagnosticsDefaultInput,
            ),
          ],
        ),
        _DiagnosticSection(
          title: l10n.diagnosticsRecordingSettings,
          icon: Icons.tune_outlined,
          rows: [
            (l10n.diagnosticsFormat, recording.format.label),
            (l10n.diagnosticsPreset, recording.preset.name),
            (
              l10n.diagnosticsBitRate,
              l10n.diagnosticsBitsPerSecond(recording.bitRate),
            ),
            (
              l10n.diagnosticsSampleRate,
              l10n.diagnosticsHertz(recording.sampleRate),
            ),
            (l10n.diagnosticsChannels, l10n.diagnosticsCount(recording.channels)),
            (l10n.diagnosticsAutoGain, _boolLabel(l10n, recording.autoGain)),
            (
              l10n.diagnosticsEchoCancellation,
              _boolLabel(l10n, recording.echoCancel),
            ),
            (
              l10n.diagnosticsNoiseSuppression,
              _boolLabel(l10n, recording.noiseSuppress),
            ),
            (
              l10n.diagnosticsCountdown,
              l10n.diagnosticsSeconds(recording.countdownSeconds),
            ),
            (
              l10n.diagnosticsKeepAwake,
              _boolLabel(l10n, recording.keepScreenAwake),
            ),
          ],
        ),
        _DiagnosticSection(
          title: l10n.diagnosticsPlaybackUi,
          icon: Icons.accessibility_new_outlined,
          rows: [
            (
              l10n.diagnosticsPlaybackSpeed,
              '${report.settings.defaultPlaybackSpeed}×',
            ),
            (
              l10n.diagnosticsSkipInterval,
              l10n.diagnosticsSeconds(report.settings.skipIntervalSeconds),
            ),
            (
              l10n.diagnosticsSkipSilence,
              _boolLabel(l10n, report.settings.skipSilence),
            ),
            (l10n.diagnosticsTheme, report.settings.themeMode.name),
            (
              l10n.diagnosticsReducedMotion,
              _boolLabel(l10n, report.settings.reducedMotion),
            ),
            (
              l10n.diagnosticsDeleteConfirmation,
              _boolLabel(l10n, report.settings.confirmDelete),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _DiagnosticSection extends StatelessWidget {
  const _DiagnosticSection({
    required this.title,
    required this.icon,
    required this.rows,
  });

  final String title;
  final IconData icon;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        row.$1,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: SelectableText(
                        row.$2,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
