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

  test('both bootstrap scripts generate all six Flutter targets', () {
    final bash = File('tool/bootstrap_platforms.sh').readAsStringSync();
    final powershell = File('tool/bootstrap_platforms.ps1').readAsStringSync();
    const platforms = 'android,ios,macos,linux,windows,web';

    expect(bash, contains('--platforms=$platforms'));
    expect(powershell, contains('--platforms=$platforms'));
    expect(bash, contains('! -d web'));
    expect(powershell, contains("'web'"));
  });

  test('default app entry point uses conditional native and web bootstrap', () {
    final main = File('lib/main.dart').readAsStringSync();
    final bootstrap = File('lib/bootstrap/bootstrap.dart').readAsStringSync();

    expect(main, contains("import 'bootstrap/bootstrap.dart';"));
    expect(main, contains('bootstrapSonicNest()'));
    expect(bootstrap, contains('dart.library.io'));
    expect(bootstrap, contains('dart.library.js_interop'));
    expect(bootstrap, contains("'bootstrap_native.dart'"));
    expect(bootstrap, contains("'bootstrap_web.dart'"));
  });

  test('core CI validates a Web release through the default entry point', () {
    final workflow = File('.github/workflows/ci.yml').readAsStringSync();

    expect(workflow, contains('name: Web release build'));
    expect(workflow, contains('flutter config --enable-web'));
    expect(workflow, contains('flutter build web --release'));
    expect(workflow, isNot(contains('--target lib/main_web.dart')));
  });
}
