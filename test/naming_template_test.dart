import 'package:flutter_test/flutter_test.dart';
import 'package:sonic_nest/core/naming_template.dart';

void main() {
  test('renders date time prefix and sequence tokens', () {
    final name = renderRecordingName(
      template: '{prefix}_{date}_{time}_{sequence}',
      timestamp: DateTime(2026, 8, 14, 6, 30, 15),
      sequence: 12,
      prefix: 'Lecture',
    );

    expect(name, 'Lecture_2026-08-14_06-30-15_0012');
  });

  test('renders category and suffix without unsafe repeated separators', () {
    final name = renderRecordingName(
      template: '{category}_{prefix}_{suffix}',
      timestamp: DateTime(2026, 8, 14),
      sequence: 1,
      prefix: 'Audio',
      category: 'Study',
      suffix: '',
    );

    expect(name, 'Study_Audio');
  });

  test('falls back when the template renders empty', () {
    final name = renderRecordingName(
      template: '{suffix}',
      timestamp: DateTime(2026, 8, 14, 9, 5, 7),
      sequence: 1,
      prefix: 'Recording',
    );

    expect(name, 'Recording_2026-08-14_09-05-07');
  });
}
