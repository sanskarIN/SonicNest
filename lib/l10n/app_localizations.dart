import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = <Locale>[Locale('en')];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        const AppLocalizations(Locale('en'));
  }

  String get appName => 'SonicNest';
  String get home => 'Home';
  String get record => 'Record';
  String get library => 'Library';
  String get settings => 'Settings';
  String get about => 'About';
  String get privateRecorderTagline => 'Private sound & voice recording';
  String get madeBy => 'Made by the Sanskar';
  String get startupFailure => 'SonicNest could not finish startup.';
  String get retry => 'Try again';
  String get moreFilters => 'More filters';
  String get filtersActive => 'Filters active';

  static const localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    DefaultMaterialLocalizations.delegate,
    DefaultWidgetsLocalizations.delegate,
    DefaultCupertinoLocalizations.delegate,
  ];
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.any(
        (supported) => supported.languageCode == locale.languageCode,
      );

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture(AppLocalizations(locale));

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
