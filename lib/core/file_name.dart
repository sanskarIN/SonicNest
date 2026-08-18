import 'dart:convert';

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

  // Keep enough headroom for the extension and collision suffix that the
  // storage service appends later. The rune limit protects Windows UTF-16
  // component length, while the UTF-8 byte limit protects common Unix filesystems.
  const maxRunes = 120;
  const maxUtf8Bytes = 220;
  final bounded = StringBuffer();
  var runeCount = 0;
  var byteCount = 0;
  for (final rune in value.runes) {
    final encodedLength = utf8.encode(String.fromCharCode(rune)).length;
    if (runeCount >= maxRunes || byteCount + encodedLength > maxUtf8Bytes) {
      break;
    }
    bounded.writeCharCode(rune);
    runeCount++;
    byteCount += encodedLength;
  }
  // Truncation can expose a dot or space that was safe only because more text
  // originally followed it. Re-apply the trailing Windows component rule to
  // the bounded value before using it as a filename stem.
  value = bounded.toString().replaceAll(RegExp(r'[. ]+$'), '');

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
