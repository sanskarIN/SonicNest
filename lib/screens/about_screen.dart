import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../controllers/app_controller.dart';
import '../core/constants.dart';
import '../widgets/sonicnest_mark.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            const SizedBox(height: 8),
            const Center(child: SonicNestMark(size: 100)),
            const SizedBox(height: 16),
            Text('SonicNest', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            const Text('Modern, privacy-first sound and voice recording.', textAlign: TextAlign.center),
            const SizedBox(height: 6),
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) => Text(
                snapshot.hasData ? 'Version ${snapshot.data!.version} (${snapshot.data!.buildNumber})' : 'Version information',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 28),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    FilledButton.icon(
                      onPressed: () => controller.external.launchExternal(AppConstants.buyMeACoffeeUrl),
                      icon: const Icon(Icons.local_cafe_outlined),
                      label: const Text('☕ Support SonicNest'),
                    ),
                    const SizedBox(height: 10),
                    const Text('Help keep SonicNest open source. Support is optional and never blocks recording.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            _LinkTile(
              icon: Icons.code,
              title: 'SonicNest on GitHub',
              subtitle: AppConstants.repositoryUrl,
              onTap: () => controller.external.launchExternal(AppConstants.repositoryUrl),
            ),
            _LinkTile(
              icon: Icons.person_outline,
              title: 'Developer profile',
              subtitle: AppConstants.githubProfileUrl,
              onTap: () => controller.external.launchExternal(AppConstants.githubProfileUrl),
            ),
            _LinkTile(
              icon: Icons.business_center_outlined,
              title: 'Business',
              subtitle: AppConstants.businessEmailPrimary,
              onTap: () => controller.external.composeEmail(AppConstants.businessEmailPrimary, subject: 'SonicNest business inquiry'),
            ),
            _LinkTile(
              icon: Icons.business_outlined,
              title: 'Business (alternate)',
              subtitle: AppConstants.businessEmailSecondary,
              onTap: () => controller.external.composeEmail(AppConstants.businessEmailSecondary, subject: 'SonicNest business inquiry'),
            ),
            _LinkTile(
              icon: Icons.support_agent,
              title: 'Support',
              subtitle: AppConstants.supportEmail,
              onTap: () => controller.external.composeEmail(AppConstants.supportEmail, subject: 'SonicNest support'),
            ),
            _LinkTile(
              icon: Icons.description_outlined,
              title: 'Open-source licenses',
              subtitle: 'Review third-party licenses used by this build',
              onTap: () => showLicensePage(
                context: context,
                applicationName: 'SonicNest',
                applicationLegalese: AppConstants.developerCredit,
              ),
            ),
            const SizedBox(height: 14),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Privacy', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                    SizedBox(height: 8),
                    Text('The core recorder is designed to work offline. Recordings stay on your device unless you explicitly choose to share or export them. SonicNest does not include hidden analytics or automatic cloud uploads.'),
                    SizedBox(height: 14),
                    Text('Open source license', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                    SizedBox(height: 8),
                    Text('Apache License 2.0. Third-party components keep their own licenses and notices.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            const Text(AppConstants.developerCredit, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.open_in_new),
          onTap: onTap,
        ),
      );
}
