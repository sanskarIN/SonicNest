import 'recording_settings.dart';

class RecordingMarker {
  const RecordingMarker({
    required this.positionMs,
    required this.label,
    this.note = '',
  });

  factory RecordingMarker.fromJson(Map<String, dynamic> json) =>
      RecordingMarker(
        positionMs: _nonNegativeIntValue(json['positionMs']),
        label: _stringValue(json['label'], 'Marker'),
        note: _stringValue(json['note']),
      );

  final int positionMs;
  final String label;
  final String note;

  Map<String, Object> toJson() => {
    'positionMs': positionMs,
    'label': label,
    'note': note,
  };
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

  factory RecordingEntry.fromJson(Map<String, dynamic> json) {
    final formatName = _stringValue(json['format']);
    final format =
        RecordingFormat.values.where((f) => f.name == formatName).firstOrNull ??
        RecordingFormat.m4a;
    final now = DateTime.now();
    return RecordingEntry(
      id: _stringValue(json['id']),
      title: _stringValue(json['title'], 'Recording'),
      filePath: _stringValue(json['filePath']),
      durationMs: _nonNegativeIntValue(json['durationMs']),
      sizeBytes: _nonNegativeIntValue(json['sizeBytes']),
      format: format,
      bitRate: _nonNegativeIntValue(json['bitRate']),
      sampleRate: _nonNegativeIntValue(json['sampleRate']),
      channels: _positiveIntValue(json['channels'], 1),
      createdAt: _dateTimeValue(json['createdAt']) ?? now,
      modifiedAt: _dateTimeValue(json['modifiedAt']) ?? now,
      favorite: _boolValue(json['favorite']),
      pinned: _boolValue(json['pinned']),
      tags: _stringList(json['tags']),
      folder: _stringValue(json['folder']),
      notes: _stringValue(json['notes']),
      markers: _markerList(json['markers']),
      waveform: _doubleList(json['waveform']),
      trashedAt: _dateTimeValue(json['trashedAt']),
    );
  }

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
    'markers': markers.map((marker) => marker.toJson()).toList(),
    'waveform': waveform,
    'trashedAt': trashedAt?.toIso8601String(),
  };
}

String _stringValue(Object? value, [String fallback = '']) =>
    value is String ? value : fallback;

int _nonNegativeIntValue(Object? value, [int fallback = 0]) {
  if (value is! num || !value.isFinite) {
    return fallback;
  }
  final parsed = value.toInt();
  return parsed < 0 ? fallback : parsed;
}

int _positiveIntValue(Object? value, [int fallback = 1]) {
  final parsed = _nonNegativeIntValue(value, fallback);
  return parsed > 0 ? parsed : fallback;
}

bool _boolValue(Object? value, [bool fallback = false]) =>
    value is bool ? value : fallback;

DateTime? _dateTimeValue(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;

List<String> _stringList(Object? value) {
  if (value is! Iterable) {
    return const [];
  }
  return value.whereType<String>().toList(growable: false);
}

List<double> _doubleList(Object? value) {
  if (value is! Iterable) {
    return const [];
  }
  return value
      .whereType<num>()
      .map((number) => number.toDouble())
      .where((number) => number.isFinite)
      .toList(growable: false);
}

List<RecordingMarker> _markerList(Object? value) {
  if (value is! Iterable) {
    return const [];
  }
  final markers = <RecordingMarker>[];
  for (final item in value) {
    if (item is! Map) {
      continue;
    }
    try {
      markers.add(
        RecordingMarker.fromJson(Map<String, dynamic>.from(item)),
      );
    } on Object {
      // A malformed marker must not invalidate the containing recording.
    }
  }
  return List.unmodifiable(markers);
}

extension _IterableFirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
