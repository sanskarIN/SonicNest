import 'recording_settings.dart';

class RecordingMarker {
  const RecordingMarker({required this.positionMs, required this.label, this.note = ''});

  final int positionMs;
  final String label;
  final String note;

  Map<String, Object> toJson() => {
        'positionMs': positionMs,
        'label': label,
        'note': note,
      };

  factory RecordingMarker.fromJson(Map<String, dynamic> json) => RecordingMarker(
        positionMs: (json['positionMs'] as num?)?.toInt() ?? 0,
        label: json['label'] as String? ?? 'Marker',
        note: json['note'] as String? ?? '',
      );
}

class RecordingEntry {
  const RecordingEntry({
    required this.id,
    required this.title,
    required this.filePath,
    required this.durationMs,
    required this.sizeBytes,
    required this.format,
    required this.bitRate,
    required this.sampleRate,
    required this.channels,
    required this.createdAt,
    required this.modifiedAt,
    this.favorite = false,
    this.pinned = false,
    this.tags = const [],
    this.folder = '',
    this.notes = '',
    this.markers = const [],
    this.waveform = const [],
    this.trashedAt,
  });

  final String id;
  final String title;
  final String filePath;
  final int durationMs;
  final int sizeBytes;
  final RecordingFormat format;
  final int bitRate;
  final int sampleRate;
  final int channels;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final bool favorite;
  final bool pinned;
  final List<String> tags;
  final String folder;
  final String notes;
  final List<RecordingMarker> markers;
  final List<double> waveform;
  final DateTime? trashedAt;

  bool get isTrashed => trashedAt != null;
  Duration get duration => Duration(milliseconds: durationMs);

  RecordingEntry copyWith({
    String? id,
    String? title,
    String? filePath,
    int? durationMs,
    int? sizeBytes,
    RecordingFormat? format,
    int? bitRate,
    int? sampleRate,
    int? channels,
    DateTime? createdAt,
    DateTime? modifiedAt,
    bool? favorite,
    bool? pinned,
    List<String>? tags,
    String? folder,
    String? notes,
    List<RecordingMarker>? markers,
    List<double>? waveform,
    DateTime? trashedAt,
    bool clearTrashedAt = false,
  }) {
    return RecordingEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      durationMs: durationMs ?? this.durationMs,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      format: format ?? this.format,
      bitRate: bitRate ?? this.bitRate,
      sampleRate: sampleRate ?? this.sampleRate,
      channels: channels ?? this.channels,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      favorite: favorite ?? this.favorite,
      pinned: pinned ?? this.pinned,
      tags: tags ?? this.tags,
      folder: folder ?? this.folder,
      notes: notes ?? this.notes,
      markers: markers ?? this.markers,
      waveform: waveform ?? this.waveform,
      trashedAt: clearTrashedAt ? null : (trashedAt ?? this.trashedAt),
    );
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'filePath': filePath,
        'durationMs': durationMs,
        'sizeBytes': sizeBytes,
        'format': format.name,
        'bitRate': bitRate,
        'sampleRate': sampleRate,
        'channels': channels,
        'createdAt': createdAt.toIso8601String(),
        'modifiedAt': modifiedAt.toIso8601String(),
        'favorite': favorite,
        'pinned': pinned,
        'tags': tags,
        'folder': folder,
        'notes': notes,
        'markers': markers.map((m) => m.toJson()).toList(),
        'waveform': waveform,
        'trashedAt': trashedAt?.toIso8601String(),
      };

  factory RecordingEntry.fromJson(Map<String, dynamic> json) {
    final formatName = json['format'] as String?;
    final format = RecordingFormat.values.where((f) => f.name == formatName).firstOrNull ?? RecordingFormat.m4a;
    return RecordingEntry(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Recording',
      filePath: json['filePath'] as String? ?? '',
      durationMs: (json['durationMs'] as num?)?.toInt() ?? 0,
      sizeBytes: (json['sizeBytes'] as num?)?.toInt() ?? 0,
      format: format,
      bitRate: (json['bitRate'] as num?)?.toInt() ?? 0,
      sampleRate: (json['sampleRate'] as num?)?.toInt() ?? 0,
      channels: (json['channels'] as num?)?.toInt() ?? 1,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      modifiedAt: DateTime.tryParse(json['modifiedAt'] as String? ?? '') ?? DateTime.now(),
      favorite: json['favorite'] as bool? ?? false,
      pinned: json['pinned'] as bool? ?? false,
      tags: (json['tags'] as List<dynamic>? ?? const []).whereType<String>().toList(),
      folder: json['folder'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      markers: (json['markers'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((m) => RecordingMarker.fromJson(Map<String, dynamic>.from(m)))
          .toList(),
      waveform: (json['waveform'] as List<dynamic>? ?? const [])
          .whereType<num>()
          .map((n) => n.toDouble())
          .toList(),
      trashedAt: DateTime.tryParse(json['trashedAt'] as String? ?? ''),
    );
  }
}

extension _IterableFirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
