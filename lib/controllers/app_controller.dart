import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../models/recording_entry.dart';
import '../models/recording_settings.dart';
import '../services/audio_import_service.dart';
import '../services/audio_processor.dart';
import '../services/external_actions.dart';
import '../services/library_recovery_service.dart';
import '../services/metadata_store.dart';
import '../services/player_service.dart';
import '../services/recorder_service.dart';
import '../services/settings_service.dart';
import '../services/storage_service.dart';

enum RecordingSort {
  newest,
  oldest,
  nameAsc,
  nameDesc,
  longest,
  shortest,
  largest,
  smallest,
}

enum LibraryScope { all, favorites, pinned, trash }

class AppController extends ChangeNotifier {
  AppController({
    required this.storage,
    required this.metadata,
    required this.settingsService,
    required this.recorder,
    required this.player,
    required this.processor,
    required this.external,
  }) {
    recorder.addListener(_relay);
    player.addListener(_relay);
  }

  final StorageService storage;
  final MetadataStore metadata;
  final SettingsService settingsService;
  final Uuid _uuid = const Uuid();

  final RecorderService recorder;
  final PlayerService player;
  final AudioProcessor processor;
  final ExternalActions external;

  List<RecordingEntry> _recordings = [];
  SettingsSnapshot settings = SettingsSnapshot.defaults();
  bool initialized = false;
  bool busy = false;
  String? errorMessage;
  int navigationIndex = 0;
  String searchQuery = '';
  RecordingSort sort = RecordingSort.newest;
  LibraryScope scope = LibraryScope.all;
  String? formatFilter;
  String? folderFilter;
  String? tagFilter;
  DateTime? dateFromFilter;
  DateTime? dateToFilter;
  RecordingEntry? selectedRecording;

  List<RecordingEntry> get recordings => List.unmodifiable(_recordings);

  List<RecordingEntry> get visibleRecordings {
    Iterable<RecordingEntry> values = _recordings;
    values = switch (scope) {
      LibraryScope.all => values.where((e) => !e.isTrashed),
      LibraryScope.favorites => values.where((e) => e.favorite && !e.isTrashed),
      LibraryScope.pinned => values.where((e) => e.pinned && !e.isTrashed),
      LibraryScope.trash => values.where((e) => e.isTrashed),
    };
    final query = searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      values = values.where((entry) {
        final haystack = [
          entry.title,
          entry.folder,
          entry.notes,
          ...entry.tags,
          ...entry.markers.map((m) => '${m.label} ${m.note}'),
        ].join(' ').toLowerCase();
        return haystack.contains(query);
      });
    }
    if (formatFilter != null) {
      values = values.where((entry) => entry.format.name == formatFilter);
    }
    if (folderFilter != null) {
      values = values.where((entry) => entry.folder == folderFilter);
    }
    final normalizedTag = tagFilter?.trim().toLowerCase();
    if (normalizedTag != null && normalizedTag.isNotEmpty) {
      values = values.where(
        (entry) =>
            entry.tags.any((tag) => tag.trim().toLowerCase() == normalizedTag),
      );
    }
    final from = dateFromFilter;
    if (from != null) {
      final start = DateTime(from.year, from.month, from.day);
      values = values.where((entry) => !entry.createdAt.isBefore(start));
    }
    final to = dateToFilter;
    if (to != null) {
      final endExclusive = DateTime(to.year, to.month, to.day + 1);
      values = values.where((entry) => entry.createdAt.isBefore(endExclusive));
    }

    final list = values.toList();
    int compareBool(bool a, bool b) => a == b ? 0 : (a ? -1 : 1);
    list.sort((a, b) {
      final pinned = compareBool(a.pinned, b.pinned);
      if (scope != LibraryScope.trash && pinned != 0) {
        return pinned;
      }
      return switch (sort) {
        RecordingSort.newest => b.createdAt.compareTo(a.createdAt),
        RecordingSort.oldest => a.createdAt.compareTo(b.createdAt),
        RecordingSort.nameAsc => a.title.toLowerCase().compareTo(
          b.title.toLowerCase(),
        ),
        RecordingSort.nameDesc => b.title.toLowerCase().compareTo(
          a.title.toLowerCase(),
        ),
        RecordingSort.longest => b.durationMs.compareTo(a.durationMs),
        RecordingSort.shortest => a.durationMs.compareTo(b.durationMs),
        RecordingSort.largest => b.sizeBytes.compareTo(a.sizeBytes),
        RecordingSort.smallest => a.sizeBytes.compareTo(b.sizeBytes),
      };
    });
    return list;
  }

  Set<String> get folders => _recordings
      .where((e) => !e.isTrashed && e.folder.trim().isNotEmpty)
      .map((e) => e.folder)
      .toSet();

  Set<String> get tags => _recordings
      .where((entry) => !entry.isTrashed)
      .expand((entry) => entry.tags)
      .map((tag) => tag.trim())
      .where((tag) => tag.isNotEmpty)
      .toSet();

  bool get hasAdvancedLibraryFilters =>
      tagFilter != null || dateFromFilter != null || dateToFilter != null;

  List<RecordingEntry> recordingsByIds(Iterable<String> ids) {
    final wanted = ids.toSet();
    return _recordings
        .where((entry) => wanted.contains(entry.id))
        .toList(growable: false);
  }

  Future<void> initialize() async {
    if (initialized) {
      return;
    }
    busy = true;
    notifyListeners();
    try {
      settings = await settingsService.load();
      _recordings = await metadata.load();
      await _reconcileManagedMetadata();
      await _recoverOrphanedRecordings();
      initialized = true;
      errorMessage = null;
    } catch (error) {
      errorMessage = 'Startup error: $error';
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  void _relay() => notifyListeners();

  void setNavigationIndex(int value) {
    navigationIndex = value.clamp(0, 4).toInt();
    notifyListeners();
  }

  void setSearch(String value) {
    searchQuery = value;
    notifyListeners();
  }

  void setSort(RecordingSort value) {
    sort = value;
    notifyListeners();
  }

  void setScope(LibraryScope value) {
    scope = value;
    notifyListeners();
  }

  void setFormatFilter(String? value) {
    formatFilter = value;
    notifyListeners();
  }

  void setFolderFilter(String? value) {
    folderFilter = value;
    notifyListeners();
  }

  void setTagFilter(String? value) {
    final clean = value?.trim();
    tagFilter = clean == null || clean.isEmpty ? null : clean;
    notifyListeners();
  }

  void setDateRangeFilter(DateTime? from, DateTime? to) {
    if (from != null && to != null && from.isAfter(to)) {
      dateFromFilter = to;
      dateToFilter = from;
    } else {
      dateFromFilter = from;
      dateToFilter = to;
    }
    notifyListeners();
  }

  void clearAdvancedLibraryFilters() {
    tagFilter = null;
    dateFromFilter = null;
    dateToFilter = null;
    notifyListeners();
  }

  Future<void> startRecording() => recorder.start(settings.recording);
  Future<void> pauseRecording() => recorder.pause();
  Future<void> resumeRecording() => recorder.resume();
  Future<void> cancelRecording() => recorder.cancel();

  Future<RecordingEntry> stopRecording() async {
    final result = await recorder.stop();
    final entry = await _entryFromResult(result);
    final previousSelection = selectedRecording;
    _recordings.add(entry);
    try {
      await _persist();
    } catch (_) {
      _recordings.removeWhere((item) => item.id == entry.id);
      selectedRecording = previousSelection;
      rethrow;
    }
    selectedRecording = entry;
    return entry;
  }

  Future<RecordingEntry> _entryFromResult(RecorderResult result) async {
    return RecordingEntry(
      id: _uuid.v7(),
      title: result.title,
      filePath: result.path,
      durationMs: result.duration.inMilliseconds,
      sizeBytes: await storage.fileSize(result.path),
      format: result.settings.format,
      bitRate: result.settings.bitRate,
      sampleRate: result.settings.sampleRate,
      channels: result.settings.channels,
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
      waveform: result.waveform,
      markers: result.markers,
    );
  }

  Future<RecordingEntry> addProcessedFile(
    String path, {
    required String title,
    required RecordingFormat format,
    List<RecordingMarker> markers = const [],
  }) async {
    final previousSelection = selectedRecording;
    RecordingEntry? addedEntry;
    try {
      final duration = await player.probeDuration(path);
      final waveform = await processor.extractWaveformEnvelope(path);
      final now = DateTime.now();
      addedEntry = RecordingEntry(
        id: _uuid.v7(),
        title: title,
        filePath: path,
        durationMs: duration.inMilliseconds,
        sizeBytes: await storage.fileSize(path),
        format: format,
        bitRate: settings.recording.bitRate,
        sampleRate: settings.recording.sampleRate,
        channels: settings.recording.channels,
        createdAt: now,
        modifiedAt: now,
        waveform: waveform,
        markers: markers,
      );
      _recordings.add(addedEntry);
      selectedRecording = addedEntry;
      await _persist();
      return addedEntry;
    } catch (_) {
      if (addedEntry != null) {
        _recordings.removeWhere((entry) => entry.id == addedEntry!.id);
      }
      selectedRecording = previousSelection;
      if (await storage.isManagedAudioPath(path, includeTrash: false)) {
        await storage.deleteIfExists(path);
      }
      rethrow;
    }
  }

  Future<void> importAudio() async {
    final paths = await external.pickAudioFiles();
    if (paths.isEmpty) {
      return;
    }

    final importer = AudioImportService(storage: storage, processor: processor);
    final failures = <String, String>{};
    var importedCount = 0;

    await _guarded(() async {
      for (final source in paths) {
        ImportedAudioData imported;
        try {
          imported = await importer.importOne(source);
        } on AudioImportException catch (error) {
          failures[source] = error.message;
          continue;
        }

        final now = DateTime.now();
        final entry = RecordingEntry(
          id: _uuid.v7(),
          title: imported.title,
          filePath: imported.filePath,
          durationMs: imported.duration.inMilliseconds,
          sizeBytes: imported.sizeBytes,
          format: imported.format,
          bitRate: 0,
          sampleRate: 0,
          channels: 0,
          createdAt: now,
          modifiedAt: now,
          waveform: imported.waveform,
        );
        _recordings.add(entry);
        try {
          await _persist();
          importedCount += 1;
        } catch (_) {
          _recordings.removeWhere((item) => item.id == entry.id);
          await storage.deleteIfExists(imported.filePath);
          rethrow;
        }
      }
    });

    if (failures.isNotEmpty) {
      final failedNames = failures.keys.map(p.basename).take(3).join(', ');
      final remaining = failures.length - failures.keys.take(3).length;
      errorMessage =
          'Imported $importedCount of ${paths.length} files. '
          'Could not import: $failedNames${remaining > 0 ? ' and $remaining more' : ''}.';
      notifyListeners();
    }
  }

  Future<void> exportRecording(RecordingEntry entry) async {
    final destination = await external.chooseExportPath(
      p.basename(entry.filePath),
    );
    if (destination != null) {
      await File(entry.filePath).copy(destination);
    }
  }

  Future<void> shareRecording(RecordingEntry entry) =>
      external.shareFile(entry.filePath, text: 'Shared from SonicNest');

  Future<void> shareRecordings(Iterable<RecordingEntry> entries) {
    final paths = entries
        .where((entry) => !entry.isTrashed)
        .map((entry) => entry.filePath)
        .toList(growable: false);
    return external.shareFiles(paths, text: 'Shared from SonicNest');
  }

  Future<void> openRecording(RecordingEntry entry) async {
    selectedRecording = entry;
    await player.load(
      entry.filePath,
      speed: settings.defaultPlaybackSpeed,
      skipSilence: settings.skipSilence,
    );
    notifyListeners();
  }

  Future<void> renameRecording(RecordingEntry entry, String title) async {
    final clean = title.trim();
    if (clean.isEmpty) {
      return;
    }
    await _guarded(() async {
      if (entry.isTrashed) {
        await _replace(
          entry.copyWith(title: clean, modifiedAt: DateTime.now()),
        );
        return;
      }

      final originalPath = entry.filePath;
      final newPath = await storage.renameAudio(originalPath, clean);
      try {
        await _replace(
          entry.copyWith(
            title: clean,
            filePath: newPath,
            modifiedAt: DateTime.now(),
          ),
        );
      } catch (error) {
        await _rollbackMoveOrThrow(
          movedPath: newPath,
          originalPath: originalPath,
          operation: 'Rename',
          persistenceError: error,
        );
        rethrow;
      }
    });
  }

  Future<void> duplicateRecording(RecordingEntry entry) async {
    await _guarded(() async {
      final title = '${entry.title} Copy';
      final path = await storage.duplicateAudio(entry.filePath, title);
      _recordings.add(
        entry.copyWith(
          id: _uuid.v7(),
          title: title,
          filePath: path,
          createdAt: DateTime.now(),
          modifiedAt: DateTime.now(),
          favorite: false,
          pinned: false,
          clearTrashedAt: true,
        ),
      );
      try {
        await _persist();
      } catch (_) {
        _recordings.removeWhere((item) => item.filePath == path);
        await storage.deleteIfExists(path);
        rethrow;
      }
    });
  }

  Future<void> toggleFavorite(RecordingEntry entry) => _replace(
    entry.copyWith(favorite: !entry.favorite, modifiedAt: DateTime.now()),
  );

  Future<void> togglePinned(RecordingEntry entry) => _replace(
    entry.copyWith(pinned: !entry.pinned, modifiedAt: DateTime.now()),
  );

  Future<void> setFavoriteForEntries(
    Iterable<RecordingEntry> entries,
    bool favorite,
  ) => _updateEntries(
    entries,
    (entry, now) => entry.copyWith(favorite: favorite, modifiedAt: now),
  );

  Future<void> setPinnedForEntries(
    Iterable<RecordingEntry> entries,
    bool pinned,
  ) => _updateEntries(
    entries.where((entry) => !entry.isTrashed),
    (entry, now) => entry.copyWith(pinned: pinned, modifiedAt: now),
  );

  Future<void> updateMetadata(
    RecordingEntry entry, {
    String? folder,
    List<String>? tags,
    String? notes,
    List<RecordingMarker>? markers,
  }) => _replace(
    entry.copyWith(
      folder: folder,
      tags: tags,
      notes: notes,
      markers: markers,
      modifiedAt: DateTime.now(),
    ),
  );

  Future<void> moveToTrash(RecordingEntry entry) => moveEntriesToTrash([entry]);

  Future<void> moveEntriesToTrash(Iterable<RecordingEntry> entries) async {
    final targets = entries
        .where((entry) => !entry.isTrashed)
        .toList(growable: false);
    if (targets.isEmpty) {
      return;
    }
    await _guarded(() async {
      final targetIds = targets.map((entry) => entry.id).toSet();
      for (final entry in targets) {
        if (player.loadedPath == entry.filePath) {
          await player.stop();
        }
        final originalPath = entry.filePath;
        final path = await storage.moveToTrash(originalPath, entry.title);
        try {
          await _replace(
            entry.copyWith(
              filePath: path,
              trashedAt: DateTime.now(),
              modifiedAt: DateTime.now(),
            ),
          );
        } catch (error) {
          await _rollbackMoveOrThrow(
            movedPath: path,
            originalPath: originalPath,
            operation: 'Move to Trash',
            persistenceError: error,
          );
          rethrow;
        }
      }
      if (selectedRecording != null &&
          targetIds.contains(selectedRecording!.id)) {
        selectedRecording = null;
      }
    });
  }

  Future<void> restore(RecordingEntry entry) => restoreEntries([entry]);

  Future<void> restoreEntries(Iterable<RecordingEntry> entries) async {
    final targets = entries
        .where((entry) => entry.isTrashed)
        .toList(growable: false);
    if (targets.isEmpty) {
      return;
    }
    await _guarded(() async {
      for (final entry in targets) {
        final originalPath = entry.filePath;
        final path = await storage.restoreFromTrash(originalPath, entry.title);
        try {
          await _replace(
            entry.copyWith(
              filePath: path,
              clearTrashedAt: true,
              modifiedAt: DateTime.now(),
            ),
          );
        } catch (error) {
          await _rollbackMoveOrThrow(
            movedPath: path,
            originalPath: originalPath,
            operation: 'Restore',
            persistenceError: error,
          );
          rethrow;
        }
      }
    });
  }

  Future<void> permanentlyDelete(RecordingEntry entry) =>
      permanentlyDeleteEntries([entry]);

  Future<void> permanentlyDeleteEntries(
    Iterable<RecordingEntry> entries,
  ) async {
    final targets = entries.toList(growable: false);
    if (targets.isEmpty) {
      return;
    }
    await _guarded(() async {
      for (final entry in targets) {
        await _permanentlyDeleteOne(entry);
      }
    });
  }

  Future<void> emptyTrash() => permanentlyDeleteEntries(
    _recordings.where((entry) => entry.isTrashed).toList(growable: false),
  );

  Future<void> clearTemporaryStorage() async {
    if (recorder.isActive) {
      throw StateError('Temporary files cannot be cleaned while recording.');
    }
    await storage.clearTemporaryFiles();
    notifyListeners();
  }

  Future<void> updateSettings(SettingsSnapshot snapshot) async {
    final previous = settings;
    settings = snapshot;
    try {
      await settingsService.save(snapshot);
    } catch (_) {
      settings = previous;
      rethrow;
    }
    notifyListeners();
  }

  Future<void> updateRecordingSettings(RecordingSettings recording) =>
      updateSettings(settings.copyWith(recording: recording));

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  Future<void> _updateEntries(
    Iterable<RecordingEntry> entries,
    RecordingEntry Function(RecordingEntry entry, DateTime now) update,
  ) async {
    final targets = entries.toList(growable: false);
    if (targets.isEmpty) {
      return;
    }
    final previousRecordings = List<RecordingEntry>.of(_recordings);
    final previousSelection = selectedRecording;
    final now = DateTime.now();
    final updates = {for (final entry in targets) entry.id: update(entry, now)};
    for (var index = 0; index < _recordings.length; index++) {
      final updated = updates[_recordings[index].id];
      if (updated != null) {
        _recordings[index] = updated;
      }
    }
    if (selectedRecording != null) {
      selectedRecording = updates[selectedRecording!.id] ?? selectedRecording;
    }
    try {
      await _persist();
    } catch (_) {
      _recordings = previousRecordings;
      selectedRecording = previousSelection;
      rethrow;
    }
    notifyListeners();
  }

  Future<void> _replace(RecordingEntry updated) async {
    final index = _recordings.indexWhere((entry) => entry.id == updated.id);
    if (index < 0) {
      return;
    }
    final previous = _recordings[index];
    final previousSelection = selectedRecording;
    _recordings[index] = updated;
    if (selectedRecording?.id == updated.id) {
      selectedRecording = updated;
    }
    try {
      await _persist();
    } catch (_) {
      _recordings[index] = previous;
      selectedRecording = previousSelection;
      rethrow;
    }
    notifyListeners();
  }

  Future<void> _permanentlyDeleteOne(RecordingEntry entry) async {
    if (player.loadedPath == entry.filePath) {
      await player.stop();
    }
    final index = _recordings.indexWhere((item) => item.id == entry.id);
    if (index < 0) {
      return;
    }

    final previousSelection = selectedRecording;
    final removed = _recordings.removeAt(index);
    if (selectedRecording?.id == removed.id) {
      selectedRecording = null;
    }

    try {
      await _persist();
    } catch (_) {
      _recordings.insert(index, removed);
      selectedRecording = previousSelection;
      rethrow;
    }

    try {
      await storage.deleteManagedAudioIfExists(removed.filePath);
    } catch (deleteError) {
      if (await File(removed.filePath).exists()) {
        _recordings.insert(index, removed);
        selectedRecording = previousSelection;
        try {
          await _persist();
        } catch (rollbackError) {
          throw StateError(
            'Audio deletion failed ($deleteError) and metadata rollback also '
            'failed ($rollbackError). The audio file was preserved at '
            '${removed.filePath}.',
          );
        }
      }
      rethrow;
    }
  }

  Future<void> _rollbackMoveOrThrow({
    required String movedPath,
    required String originalPath,
    required String operation,
    required Object persistenceError,
  }) async {
    if (!await File(movedPath).exists()) {
      return;
    }
    try {
      await File(movedPath).rename(originalPath);
    } catch (rollbackError) {
      throw StateError(
        '$operation metadata persistence failed ($persistenceError) and the '
        'file rollback also failed ($rollbackError). The audio remains at '
        '$movedPath.',
      );
    }
  }

  Future<void> _persist() => metadata.save(_recordings);

  Future<void> _reconcileManagedMetadata() async {
    final before = _recordings.length;
    final existing = <RecordingEntry>[];
    for (final entry in _recordings) {
      if (!await storage.isManagedAudioPath(entry.filePath)) {
        continue;
      }
      if (await File(entry.filePath).exists()) {
        existing.add(entry);
      }
    }
    _recordings = existing;
    if (before != _recordings.length) {
      await _persist();
    }
  }

  Future<void> _recoverOrphanedRecordings() async {
    final recovery = LibraryRecoveryService(
      storage: storage,
      probeDuration: player.probeDuration,
      extractWaveform: processor.extractWaveformEnvelope,
    );
    final recovered = await recovery.recoverOrphanedRecordings(_recordings);
    if (recovered.isEmpty) {
      return;
    }
    _recordings.addAll(recovered);
    await _persist();
  }

  Future<void> _guarded(Future<void> Function() action) async {
    busy = true;
    errorMessage = null;
    notifyListeners();
    try {
      await action();
    } catch (error) {
      errorMessage = error.toString();
      rethrow;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    recorder.removeListener(_relay);
    player.removeListener(_relay);
    recorder.dispose();
    player.dispose();
    super.dispose();
  }
}
