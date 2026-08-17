import 'dart:async';

import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../core/constants.dart';
import '../l10n/app_localizations.dart';

class GumroadPromoBar extends StatelessWidget {
  const GumroadPromoBar({super.key, required this.controller});

  final AppController controller;

  Future<void> _openStore(BuildContext context) async {
    try {
      await controller.external.launchExternal(AppConstants.gumroadStoreUrl);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final openStoreLabel = '${l10n.open} Gumroad Store';

    return Semantics(
      button: true,
      label: '$openStoreLabel: ${AppConstants.gumroadStoreUrl}',
      child: Material(
        color: scheme.tertiaryContainer,
        child: InkWell(
          onTap: () => unawaited(_openStore(context)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Row(
              children: [
                Icon(
                  Icons.storefront_outlined,
                  color: scheme.onTertiaryContainer,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        openStoreLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: scheme.onTertiaryContainer,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        AppConstants.gumroadStoreUrl,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: scheme.onTertiaryContainer,
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                          decorationColor: scheme.onTertiaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.open_in_new,
                  size: 18,
                  color: scheme.onTertiaryContainer,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
