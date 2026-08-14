import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../models/recording_entry.dart';
import '../models/recording_settings.dart';
import '../services/audio_processor.dart';
import '../services/external_actions.dart';
import '../services/metadata_store.dart';
import '../services/player_service.dart';
import '../services/recorder_service.dart';
import '../services/settings_service.dart';
import '../services/storage_service.dart';

enum RecordingSort { newest, oldest, nameAsc, nameDesc, longest, shortest, largest, smallest }
enum LibraryScope { all, favorites, pinned, trash }

class AppController extends ChangeNotifier {
  AppController({
    required StorageService storage,
    required MetadataStore metadata,
    required SettingsService settingsService,
    required RecorderService recorder,
    required PlayerService player,
    required AudioProcessor processor,
    required ExternalActions external,
  })  : _storage = storage,
        _metadata = metadata,
        _settingsService = settingsService,
        recorder = recorder,
        player = player,
        processor = processor,
        external = external {
    recorder.addListener(_relay);
    player.addListener(_relay);
  }

  final StorageService _storage;
  final MetadataStore _metadata;
  final SettingsService _settingsService;
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
        final haystack = [entry.title, entry.folder, entry.notes, ...entry.tags, ...entry.markers.map((m) => '${m.label} ${m.note}')].join(' ').toLowerCase();
        return haystack.contains(query);
      });
    }
    if (formatFilter != null) values = values.where((entry) => entry.format.name == formatFilter);
    if (folderFilter != null) values = values.where((entry) => entry.folder == folderFilter);
    final list = values.toList();
    int compareBool(bool a, bool b) => a == b ? 0 : (a ? -1 : 1);
    list.sort((a, b) {
      final pinned = compareBool(a.pinned, b.pinned);
      if (scope != LibraryScope.trash && pinned != 0) return pinned;
      return switch (sort) {
        RecordingSort.newest => b.createdAt.compareTo(a.createdAt),
        RecordingSort.oldest => a.createdAt.compareTo(b.createdAt),
        RecordingSort.nameAsc => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        RecordingSort.nameDesc => b.title.toLowerCase().compareTo(a.title.toLowerCase()),
        RecordingSort.longest => b.durationMs.compareTo(a.durationMs),
        RecordingSort.shortest => a.durationMs.compareTo(b.durationMs),
        RecordingSort.largest => b.sizeBytes.compareTo(a.sizeBytes),
        RecordingSort.smallest => a.sizeBytes.compareTo(b.sizeBytes),
      };
    });
    return list;
  }

  Set<String> get folders => _recordings.where((e) => !e.isTrashed && e.folder.trim().isNotEmpty).map((e) => e.folder).toSet();

  Future<void> initialize() async {
    if (initialized) return;
    busy = true;
    notifyListeners();
    try {
      settings = await _settingsService.load();
      _recordings = await _metadata.load();
      await _removeMissingMetadata();
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
  void setNavigationIndex(int value) { navigationIndex = value.clamp(0, 4).toInt(); notifyListeners(); }
  void setSearch(String value) { searchQuery = value; notifyListeners(); }
  void setSort(RecordingSort value) { sort = value; notifyListeners(); }
  void setScope(LibraryScope value) { scope = value; notifyListeners(); }
  void setFormatFilter(String? value) { formatFilter = value; notifyListeners(); }
  void setFolderFilter(String? value) { folderFilter = value; notifyListeners(); }

  Future<void> startRecording() => recorder.start(settings.recording);
  Future<void> pauseRecording() => recorder.pause();
  Future<void> resumeRecording() => recorder.resume();
  Future<void> cancelRecording() => recorder.cancel();

  Future<RecordingEntry> stopRecording() async {
    final result = await recorder.stop();
    final entry = await _entryFromResult(result);
    _recordings.add(entry);
    await _persist();
    selectedRecording = entry;
    return entry;
  }

  Future<RecordingEntry> _entryFromResult(RecorderResult result) async {
    return RecordingEntry(
      id: _uuid.v7(),
      title: result.title,
      filePath: result.path,
      durationMs: result.duration.inMilliseconds,
      sizeBytes: await _storage.fileSize(result.path),
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

  Future<RecordingEntry> addProcessedFile(String path, {required String title, required RecordingFormat format, List<RecordingMarker> markers = const []}) async {
    final duration = await player.probeDuration(path);
    final entry = RecordingEntry(
      id: _uuid.v7(), title: title, filePath: path, durationMs: duration.inMilliseconds,
      sizeBytes: await _storage.fileSize(path), format: format,
      bitRate: settings.recording.bitRate, sampleRate: settings.recording.sampleRate,
      channels: settings.recording.channels, createdAt: DateTime.now(), modifiedAt: DateTime.now(), markers: markers,
    );
    _recordings.add(entry);
    selectedRecording = entry;
    await _persist();
    return entry;
  }

  Future<void> importAudio() async {
    final paths = await external.pickAudioFiles();
    if (paths.isEmpty) return;
    await _guarded(() async {
      for (final source in paths) {
        final imported = await _storage.importFile(source);
        final ext = p.extension(imported).replaceFirst('.', '').toLowerCase();
        final format = RecordingFormat.values.where((f) => f.extension == ext).firstOrNull ?? RecordingFormat.m4a;
        final duration = await player.probeDuration(imported);
        _recordings.add(RecordingEntry(
          id: _uuid.v7(), title: p.basenameWithoutExtension(imported), filePath: imported,
          durationMs: duration.inMilliseconds, sizeBytes: await _storage.fileSize(imported), format: format,
          bitRate: 0, sampleRate: 0, channels: 0, createdAt: DateTime.now(), modifiedAt: DateTime.now(),
        ));
      }
      await _persist();
    });
  }

  Future<void> exportRecording(RecordingEntry entry) async {
    final destination = await external.chooseExportPath(p.basename(entry.filePath));
    if (destination != null) await File(entry.filePath).copy(destination);
  }

  Future<void> shareRecording(RecordingEntry entry) => external.shareFile(entry.filePath, text: 'Shared from SonicNest');

  Future<void> openRecording(RecordingEntry entry) async {
    selectedRecording = entry;
    await player.load(entry.filePath, speed: settings.defaultPlaybackSpeed, skipSilence: settings.skipSilence);
    notifyListeners();
  }

  Future<void> renameRecording(RecordingEntry entry, String title) async {
    final clean = title.trim();
    if (clean.isEmpty) return;
    await _guarded(() async {
      final newPath = entry.isTrashed ? entry.filePath : await _storage.renameAudio(entry.filePath, clean);
      await _replace(entry.copyWith(title: clean, filePath: newPath, modifiedAt: DateTime.now()));
    });
  }

  Future<void> duplicateRecording(RecordingEntry entry) async {
    await _guarded(() async {
      final title = '${entry.title} Copy';
      final path = await _storage.duplicateAudio(entry.filePath, title);
      _recordings.add(entry.copyWith(id: _uuid.v7(), title: title, filePath: path, createdAt: DateTime.now(), modifiedAt: DateTime.now(), favorite: false, pinned: false, clearTrashedAt: true));
      await _persist();
    });
  }

  Future<void> toggleFavorite(RecordingEntry entry) => _replace(entry.copyWith(favorite: !entry.favorite, modifiedAt: DateTime.now()));
  Future<void> togglePinned(RecordingEntry entry) => _replace(entry.copyWith(pinned: !entry.pinned, modifiedAt: DateTime.now()));

  Future<void> updateMetadata(RecordingEntry entry, {String? folder, List<String>? tags, String? notes, List<RecordingMarker>? markers}) =>
      _replace(entry.copyWith(folder: folder, tags: tags, notes: notes, markers: markers, modifiedAt: DateTime.now()));

  Future<void> moveToTrash(RecordingEntry entry) async {
    if (entry.isTrashed) return;
    await _guarded(() async {
      if (player.loadedPath == entry.filePath) await player.stop();
      final path = await _storage.moveToTrash(entry.filePath, entry.title);
      await _replace(entry.copyWith(filePath: path, trashedAt: DateTime.now(), modifiedAt: DateTime.now()));
    });
  }

  Future<void> restore(RecordingEntry entry) async {
    if (!entry.isTrashed) return;
    await _guarded(() async {
      final path = await _storage.restoreFromTrash(entry.filePath, entry.title);
      await _replace(entry.copyWith(filePath: path, clearTrashedAt: true, modifiedAt: DateTime.now()));
    });
  }

  Future<void> permanentlyDelete(RecordingEntry entry) async {
    await _guarded(() async {
      if (player.loadedPath == entry.filePath) await player.stop();
      await _storage.deleteIfExists(entry.filePath);
      _recordings.removeWhere((item) => item.id == entry.id);
      if (selectedRecording?.id == entry.id) selectedRecording = null;
      await _persist();
    });
  }

  Future<void> emptyTrash() async {
    await _guarded(() async {
      final trashed = _recordings.where((e) => e.isTrashed).toList();
      for (final entry in trashed) { await _storage.deleteIfExists(entry.filePath); }
      _recordings.removeWhere((e) => e.isTrashed);
      await _persist();
    });
  }

  Future<void> updateSettings(SettingsSnapshot snapshot) async { settings = snapshot; await _settingsService.save(snapshot); notifyListeners(); }
  Future<void> updateRecordingSettings(RecordingSettings recording) => updateSettings(settings.copyWith(recording: recording));
  void clearError() { errorMessage = null; notifyListeners(); }

  Future<void> _replace(RecordingEntry updated) async {
    final index = _recordings.indexWhere((entry) => entry.id == updated.id);
    if (index < 0) return;
    _recordings[index] = updated;
    if (selectedRecording?.id == updated.id) selectedRecording = updated;
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() => _metadata.save(_recordings);

  Future<void> _removeMissingMetadata() async {
    final before = _recordings.length;
    final existing = <RecordingEntry>[];
    for (final entry in _recordings) { if (await File(entry.filePath).exists()) existing.add(entry); }
    _recordings = existing;
    if (before != _recordings.length) await _persist();
  }

  Future<void> _guarded(Future<void> Function() action) async {
    busy = true; errorMessage = null; notifyListeners();
    try { await action(); } catch (error) { errorMessage = error.toString(); rethrow; } finally { busy = false; notifyListeners(); }
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

extension _IterableFirstOrNull<T> on Iterable<T> { T? get firstOrNull => isEmpty ? null : first; }
