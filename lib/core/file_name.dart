import 'package:path/path.dart' as p;

String sanitizeFileStem(String input, {String fallback = 'Recording'}) {
  String clean(String candidate) {
    var value = candidate.trim();
    value = value.replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1F]'), '_');
    value = value.replaceAll(RegExp(r'\s+'), ' ');
    value = value.replaceAll(RegExp(r'[. ]+$'), '');
    value = value.replaceAll(RegExp(r'^\.+'), '');
    return value;
  }

  var value = clean(input);
  if (value.isEmpty) {
    value = clean(fallback);
  }
  if (value.isEmpty) {
    value = 'Recording';
  }

  const windowsReserved = <String>{
    'CON',
    'PRN',
    'AUX',
    'NUL',
    'COM1',
    'COM2',
    'COM3',
    'COM4',
    'COM5',
    'COM6',
    'COM7',
    'COM8',
    'COM9',
    'LPT1',
    'LPT2',
    'LPT3',
    'LPT4',
    'LPT5',
    'LPT6',
    'LPT7',
    'LPT8',
    'LPT9',
  };
  final firstComponent = value.split('.').first.toUpperCase();
  if (windowsReserved.contains(firstComponent)) {
    value = '_$value';
  }

  const maxRunes = 120;
  final runes = value.runes;
  if (runes.length > maxRunes) {
    value = String.fromCharCodes(runes.take(maxRunes)).trimRight();
  }
  if (value.isEmpty) {
    value = 'Recording';
  }
  return value;
}

String replaceExtension(String path, String extensionWithoutDot) {
  final ext = extensionWithoutDot.startsWith('.')
      ? extensionWithoutDot.substring(1)
      : extensionWithoutDot;
  return p.join(p.dirname(path), '${p.basenameWithoutExtension(path)}.$ext');
}
