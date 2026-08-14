import 'package:flutter/material.dart';

import 'controllers/app_controller.dart';
import 'core/constants.dart';
import 'core/theme.dart';
import 'widgets/app_shell.dart';

class SonicNestApp extends StatelessWidget {
  const SonicNestApp({super.key, required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppConstants.appName,
        theme: SonicNestTheme.light(),
        darkTheme: SonicNestTheme.dark(),
        themeMode: controller.settings.themeMode,
        home: AppShell(controller: controller),
      ),
    );
  }
}
