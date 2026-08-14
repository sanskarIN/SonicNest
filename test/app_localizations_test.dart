import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sonic_nest/l10n/app_localizations.dart';

void main() {
  const l10n = AppLocalizations(Locale('en'));

  test('English is the declared baseline locale', () {
    expect(AppLocalizations.supportedLocales, contains(const Locale('en')));
    expect(l10n.appName, 'SonicNest');
    expect(l10n.home, isNotEmpty);
    expect(l10n.library, isNotEmpty);
    expect(l10n.settings, isNotEmpty);
  });

  test('dynamic batch strings include supplied counts', () {
    expect(l10n.convertSelected(4), contains('4'));
    expect(l10n.convertedProgress(2, 5), contains('2'));
    expect(l10n.convertedProgress(2, 5), contains('5'));
    expect(l10n.copiedToExportFolder(3), contains('3'));
  });

  test('dynamic library strings distinguish singular and plural deletes', () {
    expect(l10n.deleteSelectedPermanently(1), contains('1 recording'));
    expect(l10n.deleteSelectedPermanently(2), contains('2 recordings'));
  });

  test('editor and storage dynamic strings retain provided values', () {
    expect(l10n.outputGain('-3.0'), contains('-3.0'));
    expect(l10n.exportFormatCopy('FLAC'), contains('FLAC'));
    expect(l10n.storageSummary('10 MB', '8 MB', '2 MB'), contains('10 MB'));
    expect(l10n.storageSummary('10 MB', '8 MB', '2 MB'), contains('8 MB'));
    expect(l10n.storageSummary('10 MB', '8 MB', '2 MB'), contains('2 MB'));
  });

  test('generated editor copy labels preserve the source title', () {
    expect(l10n.selectionCopyTitle('Lecture'), startsWith('Lecture'));
    expect(l10n.partTitle('Lecture', 2), contains('2'));
    expect(l10n.highPassCopyTitle('Voice'), startsWith('Voice'));
  });
}
