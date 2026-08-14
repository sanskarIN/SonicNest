import 'package:flutter/material.dart';

import 'controllers/app_controller.dart';
import 'core/constants.dart';
import 'core/theme.dart';
import 'screens/splash_screen.dart';
import 'widgets/app_shell.dart';

class SonicNestBootstrap extends StatefulWidget {
  const SonicNestBootstrap({super.key, required this.controller});

  final AppController controller;

  @override
  State<SonicNestBootstrap> createState() => _SonicNestBootstrapState();
}

class _SonicNestBootstrapState extends State<SonicNestBootstrap> {
  late Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = widget.controller.initialize();
  }

  void _retry() {
    setState(() {
      _initialization = widget.controller.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) => FutureBuilder<void>(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return _SplashMaterialApp(controller: widget.controller);
          }
          if (widget.controller.initialized) {
            return SonicNestApp(controller: widget.controller);
          }
          return _SplashMaterialApp(
            controller: widget.controller,
            errorMessage: widget.controller.errorMessage ??
                'SonicNest could not finish startup.',
            onRetry: _retry,
          );
        },
      ),
    );
  }
}

class _SplashMaterialApp extends StatelessWidget {
  const _SplashMaterialApp({
    required this.controller,
    this.errorMessage,
    this.onRetry,
  });

  final AppController controller;
  final String? errorMessage;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: SonicNestTheme.light(),
      darkTheme: SonicNestTheme.dark(),
      themeMode: controller.settings.themeMode,
      home: SplashScreen(errorMessage: errorMessage, onRetry: onRetry),
    );
  }
}

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
