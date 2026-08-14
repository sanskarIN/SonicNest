import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../l10n/app_localizations.dart';
import '../models/recording_entry.dart';
import '../models/recording_settings.dart';
import '../widgets/recording_tile.dart';
import 'editor_screen.dart';
import 'player_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final Set<String> _selectedIds = <String>{};

  AppController get controller => widget.controller;
  bool get selecting => _selectedIds.isNotEmpty;

  List<RecordingEntry> get selectedEntries =>
      controller.recordingsByIds(_selectedIds);

  void _toggleSelection(RecordingEntry entry) {
    setState(() {
      if (!_selectedIds.add(entry.id)) {
        _selectedIds.remove(entry.id);
      }
    });
  }

  void _clearSelection() {
    if (_selectedIds.isEmpty) {
      return;
    }
    setState(_selectedIds.clear);
  }

  void _selectAllVisible() {
    setState(() {
      _selectedIds
        ..clear()
        ..addAll(controller.visibleRecordings.map((entry) => entry.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entries = controller.visibleRecordings;
    final savedCount =
        controller.recordings.where((entry) => !entry.isTrashed).length;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
          sliver: SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (selecting)
                      _SelectionToolbar(
                        count: _selectedIds.length,
                        trashMode: controller.scope == LibraryScope.trash,
                        onClose: _clearSelection,
                        onSelectAll: _selectAllVisible,
                        onFavorite: () => _runBulk(
                          () => controller.setFavoriteForEntries(
                            selectedEntries,
                            true,
                          ),
                        ),
                        onUnfavorite: () => _runBulk(
                          () => controller.setFavoriteForEntries(
                            selectedEntries,
                            false,
                          ),
                        ),
                        onPin: () => _runBulk(
                          () => controller.setPinnedForEntries(
                            selectedEntries,
                            true,
                          ),
                        ),
                        onUnpin: () => _runBulk(
                          () => controller.setPinnedForEntries(
                            selectedEntries,
                            false,
                          ),
                        ),
                        onShare: () => _runBulk(
                          () => controller.shareRecordings(selectedEntries),
                        ),
                        onTrash: () => _runBulk(
                          () => controller.moveEntriesToTrash(selectedEntries),
                        ),
                        onRestore: () => _runBulk(
                          () => controller.restoreEntries(selectedEntries),
                        ),
                        onDelete: () => _confirmBulkDelete(context),
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.recordings,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                Text(l10n.libraryCounts(entries.length, savedCount)),
                              ],
                            ),
                          ),
                          FilledButton.tonalIcon(
                            onPressed:
                                controller.busy ? null : controller.importAudio,
                            icon: const Icon(Icons.file_download_outlined),
                            label: Text(l10n.importAudio),
                          ),
                        ],
                      ),
                    const SizedBox(height: 18),
                    SearchBar(
                      hintText: l10n.searchRecordingsHint,
                      leading: const Icon(Icons.search),
                      onChanged: controller.setSearch,
                      trailing: controller.searchQuery.isEmpty
                          ? null
                          : [
                              IconButton(
                                tooltip: l10n.clearSearch,
                                onPressed: () => controller.setSearch(''),
                                icon: const Icon(Icons.close),
                              ),
                            ],
                    ),
                    const SizedBox(height: 12),
                    _FilterBar(
                      controller: controller,
                      onFilterChanged: _clearSelection,
                    ),
                    if (!selecting && entries.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: _selectAllVisible,
                          icon: const Icon(Icons.checklist),
                          label: Text(l10n.select),
                        ),
                      ),
                    ],
                    if (!selecting &&
                        controller.scope == LibraryScope.trash &&
                        entries.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton.icon(
                          onPressed: () => _confirmEmptyTrash(context),
                          icon: const Icon(Icons.delete_forever_outlined),
                          label: Text(l10n.emptyTrash),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        if (entries.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyLibrary(
              scope: controller.scope,
              onRecord: () => controller.setNavigationIndex(1),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            sliver: SliverList.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                final selected = _selectedIds.contains(entry.id);
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: RecordingTile(
                      entry: entry,
                      selected: selected,
                      onTap: selecting
                          ? () => _toggleSelection(entry)
                          : () => _openPlayer(context, entry),
                      onLongPress: () => _toggleSelection(entry),
                      onSecondaryTapDown: (_) {
                        if (!selecting) {
                          _showActions(context, entry);
                        }
                      },
                      onFavorite: () => controller.toggleFavorite(entry),
                      onMore: () => _showActions(context, entry),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Future<void> _runBulk(Future<void> Function() action) async {
    final l10n = AppLocalizations.of(context);
    try {
      await action();
      if (mounted) {
        _clearSelection();
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.bulkActionFailed(error))),
      );
    }
  }

  Future<void> _confirmBulkDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final entries = selectedEntries;
    if (entries.isEmpty) {
      return;
    }
    final approved = !controller.settings.confirmDelete ||
        await showDialog<bool>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: Text(l10n.deleteSelectedPermanently(entries.length)),
                content: Text(l10n.selectedPermanentDeleteWarning),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: Text(l10n.cancel),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: Text(l10n.delete),
                  ),
                ],
              ),
            ) ==
            true;
    if (!approved) {
      return;
    }
    await _runBulk(() => controller.permanentlyDeleteEntries(entries));
  }

  Future<void> _openPlayer(BuildContext context, RecordingEntry entry) async {
    final l10n = AppLocalizations.of(context);
    try {
      await controller.openRecording(entry);
      if (!context.mounted) {
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ListenableBuilder(
            listenable: controller,
            builder: (context, child) => PlayerScreen(
              controller: controller,
              entry: controller.selectedRecording ?? entry,
            ),
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.couldNotOpenRecording(error))),
      );
    }
  }

  Future<void> _showActions(BuildContext context, RecordingEntry entry) async {
    final l10n = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(entry.title),
                subtitle: Text(
                  entry.isTrashed ? l10n.inTrash : entry.format.label,
                ),
              ),
              if (!entry.isTrashed) ...[
                ListTile(
                  leading: const Icon(Icons.play_arrow),
                  title: Text(l10n.play),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _openPlayer(context, entry);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: Text(l10n.editAudio),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _openEditor(context, entry);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.drive_file_rename_outline),
                  title: Text(l10n.rename),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _rename(context, entry);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.label_outline),
                  title: Text(l10n.tagsFolderNotes),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _metadata(context, entry);
                  },
                ),
                ListTile(
                  leading: Icon(
                    entry.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                  ),
                  title: Text(entry.pinned ? l10n.unpin : l10n.pin),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    controller.togglePinned(entry);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.copy_outlined),
                  title: Text(l10n.duplicate),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    controller.duplicateRecording(entry);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.ios_share_outlined),
                  title: Text(l10n.share),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    controller.shareRecording(entry);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.save_alt),
                  title: Text(l10n.exportCopy),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    controller.exportRecording(entry);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: Text(l10n.moveToTrash),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    controller.moveToTrash(entry);
                  },
                ),
              ] else ...[
                ListTile(
                  leading: const Icon(Icons.restore),
                  title: Text(l10n.restore),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    controller.restore(entry);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_forever),
                  title: Text(l10n.deletePermanently),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _permanentlyDelete(context, entry);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openEditor(BuildContext context, RecordingEntry entry) async {
    await controller.openRecording(entry);
    if (!context.mounted) {
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ListenableBuilder(
          listenable: controller,
          builder: (context, child) => EditorScreen(
            controller: controller,
            entry: entry,
          ),
        ),
      ),
    );
  }

  Future<void> _rename(BuildContext context, RecordingEntry entry) async {
    final l10n = AppLocalizations.of(context);
    final text = TextEditingController(text: entry.title);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.renameRecording),
        content: TextField(
          controller: text,
          autofocus: true,
          maxLength: 120,
          decoration: InputDecoration(labelText: l10n.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, text.text.trim()),
            child: Text(l10n.rename),
          ),
        ],
      ),
    );
    text.dispose();
    if (result == null || result.isEmpty) {
      return;
    }
    await controller.renameRecording(entry, result);
  }

  Future<void> _metadata(BuildContext context, RecordingEntry entry) async {
    final l10n = AppLocalizations.of(context);
    final folder = TextEditingController(text: entry.folder);
    final tags = TextEditingController(text: entry.tags.join(', '));
    final notes = TextEditingController(text: entry.notes);
    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.recordingDetails),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: folder,
                decoration: InputDecoration(labelText: l10n.folder),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: tags,
                decoration: InputDecoration(
                  labelText: l10n.tags,
                  hintText: l10n.tagsHint,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: notes,
                minLines: 3,
                maxLines: 6,
                decoration: InputDecoration(labelText: l10n.notes),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    if (shouldSave == true) {
      await controller.updateMetadata(
        entry,
        folder: folder.text.trim(),
        tags: tags.text
            .split(',')
            .map((value) => value.trim())
            .where((value) => value.isNotEmpty)
            .toSet()
            .toList(),
        notes: notes.text.trim(),
      );
    }
    folder.dispose();
    tags.dispose();
    notes.dispose();
  }

  Future<void> _permanentlyDelete(
    BuildContext context,
    RecordingEntry entry,
  ) async {
    final l10n = AppLocalizations.of(context);
    final approved = !controller.settings.confirmDelete ||
        await showDialog<bool>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: Text(l10n.deletePermanentlyQuestion),
                content: Text(
                  l10n.recordingPermanentDeleteWarning(entry.title),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: Text(l10n.cancel),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: Text(l10n.delete),
                  ),
                ],
              ),
            ) ==
            true;
    if (approved) {
      await controller.permanentlyDelete(entry);
    }
  }

  Future<void> _confirmEmptyTrash(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final approved = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(l10n.emptyTrashQuestion),
            content: Text(l10n.emptyTrashWarning),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(l10n.emptyTrash),
              ),
            ],
          ),
        ) ==
        true;
    if (approved) {
      await controller.emptyTrash();
    }
  }
}

class _SelectionToolbar extends StatelessWidget {
  const _SelectionToolbar({
    required this.count,
    required this.trashMode,
    required this.onClose,
    required this.onSelectAll,
    required this.onFavorite,
    required this.onUnfavorite,
    required this.onPin,
    required this.onUnpin,
    required this.onShare,
    required this.onTrash,
    required this.onRestore,
    required this.onDelete,
  });

  final int count;
  final bool trashMode;
  final VoidCallback onClose;
  final VoidCallback onSelectAll;
  final VoidCallback onFavorite;
  final VoidCallback onUnfavorite;
  final VoidCallback onPin;
  final VoidCallback onUnpin;
  final VoidCallback onShare;
  final VoidCallback onTrash;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            IconButton(
              tooltip: l10n.cancelSelection,
              onPressed: onClose,
              icon: const Icon(Icons.close),
            ),
            Expanded(
              child: Text(
                l10n.selectedCount(count),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            TextButton(onPressed: onSelectAll, child: Text(l10n.selectAll)),
            PopupMenuButton<String>(
              tooltip: l10n.bulkActions,
              onSelected: (value) {
                switch (value) {
                  case 'favorite':
                    onFavorite();
                  case 'unfavorite':
                    onUnfavorite();
                  case 'pin':
                    onPin();
                  case 'unpin':
                    onUnpin();
                  case 'share':
                    onShare();
                  case 'trash':
                    onTrash();
                  case 'restore':
                    onRestore();
                  case 'delete':
                    onDelete();
                }
              },
              itemBuilder: (context) => trashMode
                  ? [
                      PopupMenuItem(
                        value: 'restore',
                        child: ListTile(
                          leading: const Icon(Icons.restore),
                          title: Text(l10n.restoreSelected),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: const Icon(Icons.delete_forever),
                          title: Text(l10n.deletePermanently),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ]
                  : [
                      PopupMenuItem(
                        value: 'favorite',
                        child: ListTile(
                          leading: const Icon(Icons.favorite),
                          title: Text(l10n.addToFavorites),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'unfavorite',
                        child: ListTile(
                          leading: const Icon(Icons.heart_broken_outlined),
                          title: Text(l10n.removeFavorites),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'pin',
                        child: ListTile(
                          leading: const Icon(Icons.push_pin),
                          title: Text(l10n.pinSelected),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'unpin',
                        child: ListTile(
                          leading: const Icon(Icons.push_pin_outlined),
                          title: Text(l10n.unpinSelected),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'share',
                        child: ListTile(
                          leading: const Icon(Icons.ios_share_outlined),
                          title: Text(l10n.shareSelected),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'trash',
                        child: ListTile(
                          leading: const Icon(Icons.delete_outline),
                          title: Text(l10n.moveToTrash),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.controller, required this.onFilterChanged});

  final AppController controller;
  final VoidCallback onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        SegmentedButton<LibraryScope>(
          segments: [
            ButtonSegment(
              value: LibraryScope.all,
              icon: const Icon(Icons.library_music_outlined),
              label: Text(l10n.all),
            ),
            ButtonSegment(
              value: LibraryScope.favorites,
              icon: const Icon(Icons.favorite_outline),
              label: Text(l10n.favorites),
            ),
            ButtonSegment(
              value: LibraryScope.pinned,
              icon: const Icon(Icons.push_pin_outlined),
              label: Text(l10n.pinned),
            ),
            ButtonSegment(
              value: LibraryScope.trash,
              icon: const Icon(Icons.delete_outline),
              label: Text(l10n.trash),
            ),
          ],
          selected: {controller.scope},
          onSelectionChanged: (value) {
            onFilterChanged();
            controller.setScope(value.first);
          },
          showSelectedIcon: false,
        ),
        DropdownMenu<RecordingSort>(
          initialSelection: controller.sort,
          label: Text(l10n.sort),
          onSelected: (value) {
            if (value != null) {
              controller.setSort(value);
            }
          },
          dropdownMenuEntries: RecordingSort.values
              .map(
                (sort) => DropdownMenuEntry(
                  value: sort,
                  label: _sortLabel(sort, l10n),
                ),
              )
              .toList(),
        ),
        DropdownMenu<String?>(
          initialSelection: controller.formatFilter,
          label: Text(l10n.format),
          onSelected: (value) {
            onFilterChanged();
            controller.setFormatFilter(value);
          },
          dropdownMenuEntries: [
            DropdownMenuEntry<String?>(
              value: null,
              label: l10n.anyFormat,
            ),
            ...RecordingFormat.values.map(
              (format) => DropdownMenuEntry<String?>(
                value: format.name,
                label: format.label,
              ),
            ),
          ],
        ),
        if (controller.folders.isNotEmpty)
          DropdownMenu<String?>(
            initialSelection: controller.folderFilter,
            label: Text(l10n.folder),
            onSelected: (value) {
              onFilterChanged();
              controller.setFolderFilter(value);
            },
            dropdownMenuEntries: [
              DropdownMenuEntry<String?>(
                value: null,
                label: l10n.anyFolder,
              ),
              ...controller.folders.map(
                (folder) => DropdownMenuEntry<String?>(
                  value: folder,
                  label: folder,
                ),
              ),
            ],
          ),
        ActionChip(
          avatar: Icon(
            controller.hasAdvancedLibraryFilters
                ? Icons.filter_alt
                : Icons.filter_alt_outlined,
            size: 18,
          ),
          label: Text(
            controller.hasAdvancedLibraryFilters
                ? l10n.filtersActive
                : l10n.advancedFilters,
          ),
          onPressed: () => _showAdvancedFilters(context),
        ),
      ],
    );
  }

  Future<void> _showAdvancedFilters(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    String? selectedTag = controller.tagFilter;
    DateTime? from = controller.dateFromFilter;
    DateTime? through = controller.dateToFilter;
    final tags = controller.tags.toList()..sort();

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          final material = MaterialLocalizations.of(sheetContext);
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                8,
                20,
                20 + MediaQuery.viewInsetsOf(sheetContext).bottom,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.advancedFilters,
                      style: Theme.of(sheetContext)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String?>(
                      initialValue: selectedTag,
                      decoration: InputDecoration(labelText: l10n.exactTag),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(l10n.anyTag),
                        ),
                        ...tags.map(
                          (tag) => DropdownMenuItem<String?>(
                            value: tag,
                            child: Text(tag),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setSheetState(() => selectedTag = value);
                      },
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today_outlined),
                      title: Text(l10n.fromDate),
                      subtitle: Text(
                        from == null
                            ? l10n.notSet
                            : material.formatCompactDate(from!),
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: sheetContext,
                          initialDate: from ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setSheetState(() => from = picked);
                        }
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.event_available_outlined),
                      title: Text(l10n.throughDate),
                      subtitle: Text(
                        through == null
                            ? l10n.notSet
                            : material.formatCompactDate(through!),
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: sheetContext,
                          initialDate: through ?? from ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setSheetState(() => through = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        TextButton(
                          onPressed: () {
                            controller.clearAdvancedLibraryFilters();
                            onFilterChanged();
                            Navigator.pop(sheetContext);
                          },
                          child: Text(l10n.clearFilters),
                        ),
                        FilledButton(
                          onPressed: () {
                            controller.setTagFilter(selectedTag);
                            controller.setDateRangeFilter(from, through);
                            onFilterChanged();
                            Navigator.pop(sheetContext);
                          },
                          child: Text(l10n.applyFilters),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static String _sortLabel(
    RecordingSort sort,
    AppLocalizations l10n,
  ) =>
      switch (sort) {
        RecordingSort.newest => l10n.newestFirst,
        RecordingSort.oldest => l10n.oldestFirst,
        RecordingSort.nameAsc => l10n.nameAscending,
        RecordingSort.nameDesc => l10n.nameDescending,
        RecordingSort.longest => l10n.longest,
        RecordingSort.shortest => l10n.shortest,
        RecordingSort.largest => l10n.largestFile,
        RecordingSort.smallest => l10n.smallestFile,
      };
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary({required this.scope, required this.onRecord});

  final LibraryScope scope;
  final VoidCallback onRecord;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (icon, title, message) = switch (scope) {
      LibraryScope.all => (
          Icons.mic_none,
          l10n.noRecordingsYet,
          l10n.noRecordingsLibraryHint,
        ),
      LibraryScope.favorites => (
          Icons.favorite_border,
          l10n.noFavorites,
          l10n.noFavoritesHint,
        ),
      LibraryScope.pinned => (
          Icons.push_pin_outlined,
          l10n.nothingPinned,
          l10n.nothingPinnedHint,
        ),
      LibraryScope.trash => (
          Icons.delete_outline,
          l10n.trashIsEmpty,
          l10n.trashIsEmptyHint,
        ),
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 58),
            const SizedBox(height: 14),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Text(message, textAlign: TextAlign.center),
            ),
            if (scope == LibraryScope.all) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onRecord,
                icon: const Icon(Icons.mic),
                label: Text(l10n.recordNow),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
