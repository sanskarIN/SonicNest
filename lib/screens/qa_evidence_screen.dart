import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/app_controller.dart';
import '../l10n/app_localizations.dart';
import '../l10n/diagnostics_localizations.dart';
import '../l10n/qa_import_localizations.dart';
import '../models/qa_check_catalog.dart';
import '../models/qa_evidence.dart';
import '../services/diagnostic_report_service.dart';
import '../services/qa_evidence_import_service.dart';
import '../services/qa_evidence_report_service.dart';
import '../services/qa_evidence_store.dart';

class QaEvidenceScreen extends StatefulWidget {
  const QaEvidenceScreen({
    super.key,
    required this.controller,
    this.diagnosticReport,
  });

  final AppController controller;
  final DiagnosticReport? diagnosticReport;

  @override
  State<QaEvidenceScreen> createState() => _QaEvidenceScreenState();
}

class _QaEvidenceScreenState extends State<QaEvidenceScreen> {
  static const _store = QaEvidenceStore();
  static const _reportService = QaEvidenceReportService();
  static const _importService = QaEvidenceImportService();
  static const _maxImportBytes = 2 * 1024 * 1024;

  QaEvidenceSession? _session;
  Object? _loadError;
  String? _savingCheckId;
  bool _resetting = false;
  bool _importing = false;

  bool get _interactionLocked =>
      _savingCheckId != null || _resetting || _importing;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loadError = null;
      _session = null;
    });
    try {
      final session = await _store.load();
      if (!mounted) {
        return;
      }
      setState(() => _session = session);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _loadError = error);
    }
  }

  Future<void> _setStatus(
    QaCheckDefinition check,
    QaEvidenceStatus status,
  ) async {
    final session = _session;
    if (session == null ||
        _savingCheckId != null ||
        _resetting ||
        _importing ||
        session.statusFor(check.id) == status) {
      return;
    }

    final next = session.withStatus(
      checkId: check.id,
      status: status,
      changedAt: DateTime.now(),
    );
    setState(() => _savingCheckId = check.id);
    try {
      await _store.save(next);
      if (!mounted) {
        return;
      }
      setState(() => _session = next);
    } catch (error) {
      if (!mounted) {
        return;
      }
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.qaEvidenceSaveFailed(error))));
    } finally {
      if (mounted) {
        setState(() => _savingCheckId = null);
      }
    }
  }

  Future<void> _reset() async {
    if (_interactionLocked) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.qaEvidenceResetTitle),
        content: Text(l10n.qaEvidenceResetDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.qaEvidenceResetConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _resetting = true);
    try {
      final session = await _store.reset();
      if (!mounted) {
        return;
      }
      setState(() => _session = session);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.qaEvidenceResetDone)));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.qaEvidenceSaveFailed(error))));
    } finally {
      if (mounted) {
        setState(() => _resetting = false);
      }
    }
  }

  QaEvidenceBundle? _bundle() {
    final session = _session;
    if (session == null) {
      return null;
    }
    return _reportService.build(
      generatedAt: DateTime.now(),
      session: session,
      diagnostics: widget.diagnosticReport,
    );
  }

  Future<void> _copyJson() async {
    final bundle = _bundle();
    if (bundle == null || _interactionLocked) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: bundle.toPrettyJson()));
    if (!mounted) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l10n.qaEvidenceCopied)));
  }

  Future<void> _shareJson() async {
    final bundle = _bundle();
    if (bundle == null || _interactionLocked) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    try {
      final path = await widget.controller.storage.uniqueTempPath(
        'SonicNest_QA_Evidence_${DateTime.now().millisecondsSinceEpoch}',
        'json',
      );
      await File(path).writeAsString(bundle.toPrettyJson(), flush: true);
      await widget.controller.external.shareFile(
        path,
        text: l10n.qaEvidencePrivacyDescription,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.qaEvidenceShared)));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.qaEvidenceShareFailed(error))),
      );
    }
  }

  Future<void> _shareMarkdown() async {
    final bundle = _bundle();
    if (bundle == null || _interactionLocked) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    try {
      final path = await widget.controller.storage.uniqueTempPath(
        'SonicNest_QA_Evidence_${DateTime.now().millisecondsSinceEpoch}',
        'md',
      );
      await File(path).writeAsString(bundle.toMarkdown(), flush: true);
      await widget.controller.external.shareFile(
        path,
        text: l10n.qaEvidencePrivacyDescription,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.qaEvidenceShared)));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.qaEvidenceShareFailed(error))),
      );
    }
  }

  Future<void> _importJson() async {
    final current = _session;
    if (current == null || _interactionLocked) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    setState(() => _importing = true);
    try {
      final path = await widget.controller.external.pickSingleJsonFile();
      if (path == null) {
        return;
      }
      final file = File(path);
      final length = await file.length();
      if (length > _maxImportBytes) {
        throw StateError('The selected QA evidence file is larger than 2 MiB.');
      }
      final source = await file.readAsString();
      final result = _importService.mergeBundle(
        source: source,
        currentSession: current,
      );
      if (!mounted) {
        return;
      }
      if (!result.hasChanges) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.qaEvidenceImportNoChanges)),
        );
        return;
      }

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.qaEvidenceImportTitle),
          content: Text(
            l10n.qaEvidenceImportDescription(
              result.sourceAssessedChecks,
              result.addedChecks,
              result.updatedChecks,
              result.ignoredChecks,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.qaEvidenceImportConfirm),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) {
        return;
      }

      await _store.save(result.mergedSession);
      if (!mounted) {
        return;
      }
      setState(() => _session = result.mergedSession);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.qaEvidenceImported(result.changedChecks))),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.qaEvidenceImportFailed(error))),
      );
    } finally {
      if (mounted) {
        setState(() => _importing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.qaEvidenceTitle),
        actions: [
          IconButton(
            tooltip: l10n.qaEvidenceReset,
            onPressed: _session == null || _interactionLocked ? null : _reset,
            icon: _resetting
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.restart_alt),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: _buildBody(l10n),
        ),
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    final loadError = _loadError;
    if (loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 44),
              const SizedBox(height: 12),
              Text(
                l10n.qaEvidenceLoadFailed(loadError),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    final session = _session;
    if (session == null) {
      return Semantics(
        label: l10n.qaEvidenceLoading,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final bundle = _reportService.build(
      generatedAt: DateTime.now(),
      session: session,
      diagnostics: widget.diagnosticReport,
    );

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          l10n.qaEvidenceSubtitle,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 12),
        _SummaryCard(bundle: bundle),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified_user_outlined),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.qaEvidencePrivacyTitle,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(l10n.qaEvidencePrivacyDescription),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: _interactionLocked ? null : _copyJson,
                      icon: const Icon(Icons.content_copy_outlined),
                      label: Text(l10n.qaEvidenceCopyJson),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: _interactionLocked ? null : _shareJson,
                      icon: const Icon(Icons.data_object_outlined),
                      label: Text(l10n.qaEvidenceShareJson),
                    ),
                    FilledButton.icon(
                      onPressed: _interactionLocked ? null : _shareMarkdown,
                      icon: const Icon(Icons.share_outlined),
                      label: Text(l10n.qaEvidenceShareMarkdown),
                    ),
                    OutlinedButton.icon(
                      onPressed: _interactionLocked ? null : _importJson,
                      icon: _importing
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.file_open_outlined),
                      label: Text(l10n.qaEvidenceImportJson),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < QaCheckCatalog.categories.length; index++)
          _CategoryCard(
            category: QaCheckCatalog.categories[index],
            session: session,
            initiallyExpanded: index == 0,
            savingCheckId: _savingCheckId,
            interactionLocked: _interactionLocked,
            onChanged: _setStatus,
          ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.bundle});

  final QaEvidenceBundle bundle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final progress = bundle.totalChecks == 0
        ? 0.0
        : bundle.assessedChecks / bundle.totalChecks;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.fact_check_outlined),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.qaEvidenceCategoryProgress(
                      bundle.assessedChecks,
                      bundle.totalChecks,
                    ),
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _CountChip(
                  label: l10n.qaEvidencePassed,
                  value: bundle.passedChecks,
                  icon: Icons.check_circle_outline,
                ),
                _CountChip(
                  label: l10n.qaEvidenceFailed,
                  value: bundle.failedChecks,
                  icon: Icons.cancel_outlined,
                ),
                _CountChip(
                  label: l10n.qaEvidenceBlocked,
                  value: bundle.blockedChecks,
                  icon: Icons.block_outlined,
                ),
                _CountChip(
                  label: l10n.qaEvidenceNotRun,
                  value: bundle.notRunChecks,
                  icon: Icons.pending_outlined,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) =>
      Chip(avatar: Icon(icon, size: 18), label: Text('$label: $value'));
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.session,
    required this.initiallyExpanded,
    required this.savingCheckId,
    required this.interactionLocked,
    required this.onChanged,
  });

  final QaCheckCategory category;
  final QaEvidenceSession session;
  final bool initiallyExpanded;
  final String? savingCheckId;
  final bool interactionLocked;
  final Future<void> Function(QaCheckDefinition, QaEvidenceStatus) onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final checks = QaCheckCatalog.checksForCategory(category.id);
    final assessed = checks
        .where(
          (check) => session.statusFor(check.id) != QaEvidenceStatus.notRun,
        )
        .length;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        title: Text(
          l10n.qaEvidenceCategoryTitle(category.id),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          l10n.qaEvidenceCategoryProgress(assessed, checks.length),
        ),
        children: [
          for (final check in checks)
            _QaCheckTile(
              definition: check,
              status: session.statusFor(check.id),
              updatedAt: session.resultFor(check.id)?.updatedAtUtc,
              saving: savingCheckId == check.id,
              enabled: savingCheckId == null && !interactionLocked,
              onChanged: (status) => onChanged(check, status),
            ),
        ],
      ),
    );
  }
}

class _QaCheckTile extends StatelessWidget {
  const _QaCheckTile({
    required this.definition,
    required this.status,
    required this.updatedAt,
    required this.saving,
    required this.enabled,
    required this.onChanged,
  });

  final QaCheckDefinition definition;
  final QaEvidenceStatus status;
  final DateTime? updatedAt;
  final bool saving;
  final bool enabled;
  final ValueChanged<QaEvidenceStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = l10n.qaEvidenceCheckTitle(definition.id);
    final statusLabel = l10n.qaEvidenceStatusLabel(status.name);
    return Semantics(
      container: true,
      label: '$title. $statusLabel.',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            if (updatedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                l10n.qaEvidenceUpdated(updatedAt!.toLocal().toString()),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (definition.requiresPhysicalTarget)
                  Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text(l10n.qaEvidencePhysicalTarget),
                  ),
                if (definition.requiresExternalTooling)
                  Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text(l10n.qaEvidenceExternalTooling),
                  ),
                if (saving)
                  const SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  PopupMenuButton<QaEvidenceStatus>(
                    enabled: enabled,
                    tooltip: '$title: $statusLabel',
                    onSelected: onChanged,
                    itemBuilder: (context) => [
                      for (final option in QaEvidenceStatus.values)
                        PopupMenuItem<QaEvidenceStatus>(
                          value: option,
                          child: Row(
                            children: [
                              Icon(_statusIcon(option), size: 20),
                              const SizedBox(width: 10),
                              Text(l10n.qaEvidenceStatusLabel(option.name)),
                            ],
                          ),
                        ),
                    ],
                    child: Chip(
                      avatar: Icon(_statusIcon(status), size: 18),
                      label: Text(statusLabel),
                    ),
                  ),
              ],
            ),
            const Divider(height: 24),
          ],
        ),
      ),
    );
  }

  static IconData _statusIcon(QaEvidenceStatus status) {
    switch (status) {
      case QaEvidenceStatus.notRun:
        return Icons.pending_outlined;
      case QaEvidenceStatus.passed:
        return Icons.check_circle_outline;
      case QaEvidenceStatus.failed:
        return Icons.cancel_outlined;
      case QaEvidenceStatus.blocked:
        return Icons.block_outlined;
    }
  }
}