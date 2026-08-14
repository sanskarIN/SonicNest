import 'package:path/path.dart' as p;

String sanitizeFileStem(String input, {String fallback = 'Recording'}) {
  var value = input.trim();
  value = value.replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1F]'), '_');
  value = value.replaceAll(RegExp(r'\s+'), ' ');
  value = value.replaceAll(RegExp(r'[. ]+$'), '');
  value = value.replaceAll(RegExp(r'^\.+'), '');
  if (value.isEmpty) value = fallback;

  const windowsReserved = <String>{
    'CON', 'PRN', 'AUX', 'NUL',
    'COM1', 'COM2', 'COM3', 'COM4', 'COM5', 'COM6', 'COM7', 'COM8', 'COM9',
    'LPT1', 'LPT2', 'LPT3', 'LPT4', 'LPT5', 'LPT6', 'LPT7', 'LPT8', 'LPT9',
  };
  if (windowsReserved.contains(value.toUpperCase())) value = '_$value';
  if (value.length > 120) value = value.substring(0, 120).trimRight();
  return value;
}

String replaceExtension(String path, String extensionWithoutDot) {
  final ext = extensionWithoutDot.startsWith('.')
      ? extensionWithoutDot.substring(1)
      : extensionWithoutDot;
  return p.join(p.dirname(path), '${p.basenameWithoutExtension(path)}.$ext');
}
