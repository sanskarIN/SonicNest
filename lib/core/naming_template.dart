import 'package:intl/intl.dart';

import 'file_name.dart';

const defaultRecordingNameTemplate = '{prefix}_{date}_{time}';

String renderRecordingName({
  required String template,
  required DateTime timestamp,
  required int sequence,
  String prefix = 'Recording',
  String suffix = '',
  String category = '',
}) {
  final normalizedTemplate = template.trim().isEmpty
      ? defaultRecordingNameTemplate
      : template.trim();
  final replacements = <String, String>{
    '{prefix}': prefix.trim().isEmpty ? 'Recording' : prefix.trim(),
    '{suffix}': suffix.trim(),
    '{category}': category.trim(),
    '{date}': DateFormat('yyyy-MM-dd').format(timestamp),
    '{time}': DateFormat('HH-mm-ss').format(timestamp),
    '{year}': DateFormat('yyyy').format(timestamp),
    '{month}': DateFormat('MM').format(timestamp),
    '{day}': DateFormat('dd').format(timestamp),
    '{hour}': DateFormat('HH').format(timestamp),
    '{minute}': DateFormat('mm').format(timestamp),
    '{second}': DateFormat('ss').format(timestamp),
    '{sequence}': sequence.clamp(1, 999999999).toString().padLeft(4, '0'),
  };

  var result = normalizedTemplate;
  for (final entry in replacements.entries) {
    result = result.replaceAll(entry.key, entry.value);
  }

  result = result
      .replaceAll(RegExp(r'[_\- ]{2,}'), '_')
      .replaceAll(RegExp(r'^[_\- ]+|[_\- ]+$'), '');

  if (result.trim().isEmpty) {
    result =
        '${replacements['{prefix}']}_${replacements['{date}']}_${replacements['{time}']}';
  }
  return sanitizeFileStem(result);
}
