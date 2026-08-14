import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../widgets/sonicnest_mark.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({
    super.key,
    this.failed = false,
    this.errorMessage,
    this.onRetry,
  });

  final bool failed;
  final String? errorMessage;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final strings = AppLocalizations.of(context);
    final detail = errorMessage?.trim();
    final failureText = detail == null || detail.isEmpty
        ? strings.startupFailure
        : '${strings.startupFailure}\n\n$detail';
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(36),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(22),
                      child: SonicNestMark(size: 86),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    strings.appName,
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    strings.privateRecorderTagline,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  if (!failed)
                    const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    )
                  else ...[
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        failureText,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: scheme.error),
                      ),
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: Text(strings.retry),
                    ),
                  ],
                  const SizedBox(height: 22),
                  Text(
                    strings.madeBy,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
