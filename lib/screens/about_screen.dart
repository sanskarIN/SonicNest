import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../core/constants.dart';
import '../l10n/app_localizations.dart';
import '../l10n/diagnostics_localizations.dart';
import '../widgets/sonicnest_mark.dart';
import 'diagnostics_screen.dart';
import 'qa_evidence_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            const SizedBox(height: 8),
            const Center(child: SonicNestMark(size: 100)),
            const SizedBox(height: 16),
            Text(
              l10n.appName,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(l10n.aboutTagline, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(
              l10n.versionLabel(AppConstants.appDisplayVersion),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    FilledButton.icon(
                      onPressed: () => controller.external.launchExternal(
                        AppConstants.buyMeACoffeeUrl,
                      ),
                      icon: const Icon(Icons.local_cafe_outlined),
                      label: Text(l10n.supportSonicNest),
                    ),
                    const SizedBox(height: 10),
                    Text(l10n.supportOpenSourceHint),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            _LinkTile(
              icon: Icons.storefront_outlined,
              title: '${l10n.open} Gumroad Store',
              subtitle: AppConstants.gumroadStoreUrl,
              onTap: () => controller.external.launchExternal(
                AppConstants.gumroadStoreUrl,
              ),
            ),
            _LinkTile(
              icon: Icons.monitor_heart_outlined,
              title: l10n.diagnostics,
              subtitle: l10n.diagnosticsAboutTileSubtitle,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => DiagnosticsScreen(controller: controller),
                ),
              ),
            ),
            _LinkTile(
              icon: Icons.fact_check_outlined,
              title: l10n.qaEvidenceOpen,
              subtitle: l10n.qaEvidenceOpenSubtitle,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => QaEvidenceScreen(controller: controller),
                ),
              ),
            ),
            _LinkTile(
              icon: Icons.code,
              title: l10n.sonicNestOnGitHub,
              subtitle: AppConstants.repositoryUrl,
              onTap: () => controller.external.launchExternal(
                AppConstants.repositoryUrl,
              ),
            ),
            _LinkTile(
              icon: Icons.person_outline,
              title: l10n.developerProfile,
              subtitle: AppConstants.githubProfileUrl,
              onTap: () => controller.external.launchExternal(
                AppConstants.githubProfileUrl,
              ),
            ),
            _LinkTile(
              icon: Icons.business_center_outlined,
              title: l10n.business,
              subtitle: AppConstants.businessEmailPrimary,
              onTap: () => controller.external.composeEmail(
                AppConstants.businessEmailPrimary,
                subject: l10n.businessInquirySubject,
              ),
            ),
            _LinkTile(
              icon: Icons.business_outlined,
              title: l10n.businessAlternate,
              subtitle: AppConstants.businessEmailSecondary,
              onTap: () => controller.external.composeEmail(
                AppConstants.businessEmailSecondary,
                subject: l10n.businessInquirySubject,
              ),
            ),
            _LinkTile(
              icon: Icons.support_agent,
              title: l10n.support,
              subtitle: AppConstants.supportEmail,
              onTap: () => controller.external.composeEmail(
                AppConstants.supportEmail,
                subject: l10n.supportEmailSubject,
              ),
            ),
            _LinkTile(
              icon: Icons.description_outlined,
              title: l10n.openSourceLicenses,
              subtitle: l10n.reviewThirdPartyLicenses,
              onTap: () => showLicensePage(
                context: context,
                applicationName: l10n.appName,
                applicationVersion: AppConstants.appVersion,
                applicationLegalese: AppConstants.developerCredit,
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.privacy,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(l10n.privacySummary),
                    const SizedBox(height: 14),
                    Text(
                      l10n.openSourceLicense,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(l10n.apacheLicenseSummary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              AppConstants.developerCredit,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing = const Icon(Icons.open_in_new),
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget trailing;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing,
      onTap: onTap,
    ),
  );
}
