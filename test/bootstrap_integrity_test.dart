import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('core CI validates committed formatting before platform bootstrap', () {
    final workflow = File('.github/workflows/ci.yml').readAsStringSync();
    final formatIndex = workflow.indexOf('Verify committed Dart formatting');
    final bootstrapIndex = workflow.indexOf('Generate platform hosts');

    expect(formatIndex, greaterThanOrEqualTo(0));
    expect(bootstrapIndex, greaterThan(formatIndex));
  });

  test('Bash bootstrap preserves tracked analyzer configuration', () {
    final script = File('tool/bootstrap_platforms.sh').readAsStringSync();

    expect(script, contains('analysis_options.yaml'));
    expect(script, contains('restore_analysis_options'));
    expect(script, contains('trap restore_analysis_options EXIT'));
  });

  test('PowerShell bootstrap preserves tracked analyzer configuration', () {
    final script = File('tool/bootstrap_platforms.ps1').readAsStringSync();

    expect(script, contains("'analysis_options.yaml'"));
    expect(script, contains('finally'));
    expect(
      script,
      contains(r'Copy-Item $AnalysisOptionsBackup $AnalysisOptions -Force'),
    );
  });
}
