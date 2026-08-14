import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
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
      if (!_selectedIds.add(entry.id)) _selectedIds.remove(entry.id);
    });
  }

  void _clearSelection() {
    if (_selectedIds.isEmpty) return;
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
    final entries = controller.visibleRecordings;
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
                          () => controller.setFavoriteForEntries(selectedEntries, true),
                        ),
                        onUnfavorite: () => _runBulk(
                          () => controller.setFavoriteForEntries(selectedEntries, false),
                        ),
                        onPin: () => _runBulk(
                          () => controller.setPinnedForEntries(selectedEntries, true),
                        ),
                        onUnpin: () => _runBulk(
                          () => controller.setPinnedForEntries(selectedEntries, false),
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
                                  'Recordings',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                Text(
                                  '${entries.length} shown • '
                                  '${controller.recordings.where((e) => !e.isTrashed).length} saved',
                                ),
                              ],
                            ),
                          ),
                          FilledButton.tonalIcon(
                            onPressed: controller.busy ? null : controller.importAudio,
                            icon: const Icon(Icons.file_download_outlined),
                            label: const Text('Import'),
                          ),
                        ],
                      ),
                    const SizedBox(height: 18),
                    SearchBar(
                      hintText: 'Search title, tags, notes, folders, bookmarks',
                      leading: const Icon(Icons.search),
                      onChanged: controller.setSearch,
                      trailing: controller.searchQuery.isEmpty
                          ? null
                          : [
                              IconButton(
                                tooltip: 'Clear search',
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
                          label: const Text('Select'),
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
                          label: const Text('Empty Trash'),
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
    try {
      await action();
      if (mounted) _clearSelection();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bulk action failed: $error')),
      );
    }
  }

  Future<void> _confirmBulkDelete(BuildContext context) async {
    final entries = selectedEntries;
    if (entries.isEmpty) return;
    final approved = !controller.settings.confirmDelete ||
        await showDialog<bool>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: Text('Delete ${entries.length} recording${entries.length == 1 ? '' : 's'} permanently?'),
                content: const Text(
                  'The selected recordings will be permanently deleted. This cannot be undone.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ) ==
            true;
    if (!approved) return;
    await _runBulk(() => controller.permanentlyDeleteEntries(entries));
  }

  Future<void> _openPlayer(BuildContext context, RecordingEntry entry) async {
    try {
      await controller.openRecording(entry);
      if (!context.mounted) return;
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
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open recording: $error')),
      );
    }
  }

  Future<void> _showActions(BuildContext context, RecordingEntry entry) async {
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
                subtitle: Text(entry.isTrashed ? 'In Trash' : entry.format.label),
              ),
              if (!entry.isTrashed) ...[
                ListTile(
                  leading: const Icon(Icons.play_arrow),
                  title: const Text('Play'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _openPlayer(context, entry);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Edit audio'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _openEditor(context, entry);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.drive_file_rename_outline),
                  title: const Text('Rename'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _rename(context, entry);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.label_outline),
                  title: const Text('Tags, folder & notes'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _metadata(context, entry);
                  },
                ),
                ListTile(
                  leading: Icon(
                    entry.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                  ),
                  title: Text(entry.pinned ? 'Unpin' : 'Pin'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    controller.togglePinned(entry);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.copy_outlined),
                  title: const Text('Duplicate'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    controller.duplicateRecording(entry);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.ios_share_outlined),
                  title: const Text('Share'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    controller.shareRecording(entry);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.save_alt),
                  title: const Text('Export copy'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    controller.exportRecording(entry);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Move to Trash'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    controller.moveToTrash(entry);
                  },
                ),
              ] else ...[
                ListTile(
                  leading: const Icon(Icons.restore),
                  title: const Text('Restore'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    controller.restore(entry);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_forever),
                  title: const Text('Delete permanently'),
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
    if (!context.mounted) return;
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
    final text = TextEditingController(text: entry.title);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rename recording'),
        content: TextField(
          controller: text,
          autofocus: true,
          maxLength: 120,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, text.text.trim()),
            child: const Text('Rename'),
          ),
        ],
      ),
    );
    text.dispose();
    if (result == null || result.isEmpty) return;
    await controller.renameRecording(entry, result);
  }

  Future<void> _metadata(BuildContext context, RecordingEntry entry) async {
    final folder = TextEditingController(text: entry.folder);
    final tags = TextEditingController(text: entry.tags.join(', '));
    final notes = TextEditingController(text: entry.notes);
    final save = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Recording details'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: folder,
                decoration: const InputDecoration(labelText: 'Folder'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: tags,
                decoration: const InputDecoration(
                  labelText: 'Tags',
                  hintText: 'lecture, study, important',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: notes,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (save == true) {
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
    final approved = !controller.settings.confirmDelete ||
        await showDialog<bool>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Delete permanently?'),
                content: Text(
                  '“${entry.title}” will be permanently deleted. This cannot be undone.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ) ==
            true;
    if (approved) await controller.permanentlyDelete(entry);
  }

  Future<void> _confirmEmptyTrash(BuildContext context) async {
    final approved = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Empty Trash?'),
            content: const Text(
              'Every recording currently in Trash will be permanently deleted.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Empty Trash'),
              ),
            ],
          ),
        ) ==
        true;
    if (approved) await controller.emptyTrash();
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Cancel selection',
              onPressed: onClose,
              icon: const Icon(Icons.close),
            ),
            Expanded(
              child: Text(
                '$count selected',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            TextButton(onPressed: onSelectAll, child: const Text('Select all')),
            PopupMenuButton<String>(
              tooltip: 'Bulk actions',
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
                  ? const [
                      PopupMenuItem(
                        value: 'restore',
                        child: ListTile(
                          leading: Icon(Icons.restore),
                          title: Text('Restore selected'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete_forever),
                          title: Text('Delete permanently'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ]
                  : const [
                      PopupMenuItem(
                        value: 'favorite',
                        child: ListTile(
                          leading: Icon(Icons.favorite),
                          title: Text('Add to favorites'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'unfavorite',
                        child: ListTile(
                          leading: Icon(Icons.heart_broken_outlined),
                          title: Text('Remove favorites'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'pin',
                        child: ListTile(
                          leading: Icon(Icons.push_pin),
                          title: Text('Pin selected'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'unpin',
                        child: ListTile(
                          leading: Icon(Icons.push_pin_outlined),
                          title: Text('Unpin selected'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'share',
                        child: ListTile(
                          leading: Icon(Icons.ios_share_outlined),
                          title: Text('Share selected'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'trash',
                        child: ListTile(
                          leading: Icon(Icons.delete_outline),
                          title: Text('Move to Trash'),
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
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        SegmentedButton<LibraryScope>(
          segments: const [
            ButtonSegment(
              value: LibraryScope.all,
              icon: Icon(Icons.library_music_outlined),
              label: Text('All'),
            ),
            ButtonSegment(
              value: LibraryScope.favorites,
              icon: Icon(Icons.favorite_outline),
              label: Text('Favorites'),
            ),
            ButtonSegment(
              value: LibraryScope.pinned,
              icon: Icon(Icons.push_pin_outlined),
              label: Text('Pinned'),
            ),
            ButtonSegment(
              value: LibraryScope.trash,
              icon: Icon(Icons.delete_outline),
              label: Text('Trash'),
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
          label: const Text('Sort'),
          onSelected: (value) {
            if (value != null) controller.setSort(value);
          },
          dropdownMenuEntries: RecordingSort.values
              .map(
                (sort) => DropdownMenuEntry(
                  value: sort,
                  label: _sortLabel(sort),
                ),
              )
              .toList(),
        ),
        DropdownMenu<String?>(
          initialSelection: controller.formatFilter,
          label: const Text('Format'),
          onSelected: (value) {
            onFilterChanged();
            controller.setFormatFilter(value);
          },
          dropdownMenuEntries: [
            const DropdownMenuEntry<String?>(
              value: null,
              label: 'Any format',
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
            label: const Text('Folder'),
            onSelected: (value) {
              onFilterChanged();
              controller.setFolderFilter(value);
            },
            dropdownMenuEntries: [
              const DropdownMenuEntry<String?>(
                value: null,
                label: 'Any folder',
              ),
              ...controller.folders.map(
                (folder) => DropdownMenuEntry<String?>(
                  value: folder,
                  label: folder,
                ),
              ),
            ],
          ),
      ],
    );
  }

  static String _sortLabel(RecordingSort sort) => switch (sort) {
        RecordingSort.newest => 'Newest first',
        RecordingSort.oldest => 'Oldest first',
        RecordingSort.nameAsc => 'Name A–Z',
        RecordingSort.nameDesc => 'Name Z–A',
        RecordingSort.longest => 'Longest',
        RecordingSort.shortest => 'Shortest',
        RecordingSort.largest => 'Largest file',
        RecordingSort.smallest => 'Smallest file',
      };
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary({required this.scope, required this.onRecord});

  final LibraryScope scope;
  final VoidCallback onRecord;

  @override
  Widget build(BuildContext context) {
    final (icon, title, message) = switch (scope) {
      LibraryScope.all => (
          Icons.mic_none,
          'No recordings yet',
          'Create a recording or import an audio file to start your library.',
        ),
      LibraryScope.favorites => (
          Icons.favorite_border,
          'No favorites',
          'Tap the heart on a recording to keep it here.',
        ),
      LibraryScope.pinned => (
          Icons.push_pin_outlined,
          'Nothing pinned',
          'Pin important recordings for quick access.',
        ),
      LibraryScope.trash => (
          Icons.delete_outline,
          'Trash is empty',
          'Deleted recordings you can restore will appear here.',
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
                label: const Text('Record now'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
