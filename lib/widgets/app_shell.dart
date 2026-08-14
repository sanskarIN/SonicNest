import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/app_controller.dart';
import '../l10n/app_localizations.dart';
import '../screens/about_screen.dart';
import '../screens/home_screen.dart';
import '../screens/library_screen.dart';
import '../screens/recorder_screen.dart';
import '../screens/settings_screen.dart';
import '../services/recorder_service.dart';
import 'sonicnest_mark.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final destinations = [
      NavigationDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home),
        label: strings.home,
      ),
      NavigationDestination(
        icon: const Icon(Icons.mic_none),
        selectedIcon: const Icon(Icons.mic),
        label: strings.record,
      ),
      NavigationDestination(
        icon: const Icon(Icons.library_music_outlined),
        selectedIcon: const Icon(Icons.library_music),
        label: strings.library,
      ),
      NavigationDestination(
        icon: const Icon(Icons.settings_outlined),
        selectedIcon: const Icon(Icons.settings),
        label: strings.settings,
      ),
      NavigationDestination(
        icon: const Icon(Icons.info_outline),
        selectedIcon: const Icon(Icons.info),
        label: strings.about,
      ),
    ];
    final pages = [
      HomeScreen(controller: controller),
      RecorderScreen(controller: controller),
      LibraryScreen(controller: controller),
      SettingsScreen(controller: controller),
      AboutScreen(controller: controller),
    ];
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.digit1, control: true): () =>
            controller.setNavigationIndex(0),
        const SingleActivator(LogicalKeyboardKey.digit2, control: true): () =>
            controller.setNavigationIndex(1),
        const SingleActivator(LogicalKeyboardKey.digit3, control: true): () =>
            controller.setNavigationIndex(2),
        const SingleActivator(LogicalKeyboardKey.digit4, control: true): () =>
            controller.setNavigationIndex(3),
        const SingleActivator(LogicalKeyboardKey.digit5, control: true): () =>
            controller.setNavigationIndex(4),
        const SingleActivator(LogicalKeyboardKey.f9): _toggleRecording,
        const SingleActivator(LogicalKeyboardKey.f10): _toggleRecordingPause,
        const SingleActivator(
          LogicalKeyboardKey.keyP,
          control: true,
          alt: true,
        ): _togglePlayback,
        const SingleActivator(
          LogicalKeyboardKey.arrowLeft,
          control: true,
          alt: true,
        ): () => unawaited(
              controller.player.jump(
                Duration(seconds: -controller.settings.skipIntervalSeconds),
              ),
            ),
        const SingleActivator(
          LogicalKeyboardKey.arrowRight,
          control: true,
          alt: true,
        ): () => unawaited(
              controller.player.jump(
                Duration(seconds: controller.settings.skipIntervalSeconds),
              ),
            ),
      },
      child: Focus(
        autofocus: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            final content = IndexedStack(
              index: controller.navigationIndex,
              children: pages,
            );
            return Scaffold(
              appBar: wide
                  ? null
                  : AppBar(
                      title: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SonicNestMark(size: 34),
                          const SizedBox(width: 10),
                          Text(strings.appName),
                        ],
                      ),
                    ),
              body: SafeArea(
                child: wide
                    ? Row(
                        children: [
                          NavigationRail(
                            selectedIndex: controller.navigationIndex,
                            onDestinationSelected: controller.setNavigationIndex,
                            labelType: NavigationRailLabelType.all,
                            leading: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: SonicNestMark(size: 48),
                            ),
                            destinations: destinations
                                .map(
                                  (destination) => NavigationRailDestination(
                                    icon: destination.icon,
                                    selectedIcon: destination.selectedIcon,
                                    label: Text(destination.label),
                                  ),
                                )
                                .toList(),
                          ),
                          const VerticalDivider(width: 1),
                          Expanded(child: content),
                        ],
                      )
                    : content,
              ),
              bottomNavigationBar: wide
                  ? null
                  : NavigationBar(
                      selectedIndex: controller.navigationIndex,
                      onDestinationSelected: controller.setNavigationIndex,
                      destinations: destinations,
                    ),
            );
          },
        ),
      ),
    );
  }

  void _toggleRecording() {
    controller.setNavigationIndex(1);
    if (controller.recorder.status == RecorderStatus.countdown) {
      unawaited(controller.cancelRecording());
    } else if (controller.recorder.isCapturing) {
      unawaited(controller.stopRecording());
    } else if (controller.recorder.status == RecorderStatus.idle) {
      unawaited(controller.startRecording());
    }
  }

  void _toggleRecordingPause() {
    if (controller.recorder.status == RecorderStatus.recording) {
      unawaited(controller.pauseRecording());
    } else if (controller.recorder.status == RecorderStatus.paused) {
      unawaited(controller.resumeRecording());
    }
  }

  void _togglePlayback() {
    if (controller.player.loadedPath == null) {
      return;
    }
    if (controller.player.isPlaying) {
      unawaited(controller.player.pause());
    } else {
      unawaited(controller.player.play());
    }
  }
}
