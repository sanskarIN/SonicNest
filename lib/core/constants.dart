/// Shared application constants that do not carry mutable runtime state.
class AppConstants {
  const AppConstants._();

  static const appName = 'SonicNest';
  static const appVersion = '2.18.12';
  static const appBuildNumber = '21812';
  static const appVersionWithBuild = '$appVersion+$appBuildNumber';
  static const appDisplayVersion = '$appVersion ($appBuildNumber)';
  static const developerCredit = 'Made by the Sanskar';
  static const githubProfileUrl = 'https://www.github.com/sanskarIN';
  static const githubProfile = githubProfileUrl;
  static const repositoryUrl = 'https://github.com/sanskarIN/SonicNest';

  /// Optional storefront destination opened only after an explicit user action.
  static const gumroadStoreUrl = 'https://ramsandesh.gumroad.com';
  static const buyMeACoffeeUrl = 'https://buymeacoffee.com/sanskarIN';
  static const businessEmailPrimary = 'sanskarin@outlook.in';
  static const businessEmailSecondary = 'sanskarin.business@gmail.com';
  static const supportEmail = 'supportramsandesh@gmail.com';

  static const metadataSchemaVersion = 1;
  static const maxWaveformSamples = 720;
  static const trashRetentionDays = 30;
}
