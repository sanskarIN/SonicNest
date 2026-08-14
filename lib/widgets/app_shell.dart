import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../screens/about_screen.dart';
import '../screens/home_screen.dart';
import '../screens/library_screen.dart';
import '../screens/recorder_screen.dart';
import '../screens/settings_screen.dart';
import 'sonicnest_mark.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.controller});
  final AppController controller;

  static const destinations = [
    NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
    NavigationDestination(icon: Icon(Icons.mic_none), selectedIcon: Icon(Icons.mic), label: 'Record'),
    NavigationDestination(icon: Icon(Icons.library_music_outlined), selectedIcon: Icon(Icons.library_music), label: 'Library'),
    NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
    NavigationDestination(icon: Icon(Icons.info_outline), selectedIcon: Icon(Icons.info), label: 'About'),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(controller: controller),
      RecorderScreen(controller: controller),
      LibraryScreen(controller: controller),
      SettingsScreen(controller: controller),
      AboutScreen(controller: controller),
    ];
    return LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth >= 900;
      final content = IndexedStack(index: controller.navigationIndex, children: pages);
      return Scaffold(
        appBar: wide ? null : AppBar(title: const Row(mainAxisSize: MainAxisSize.min, children: [SonicNestMark(size: 34), SizedBox(width: 10), Text('SonicNest')])),
        body: SafeArea(child: wide ? Row(children: [
          NavigationRail(
            selectedIndex: controller.navigationIndex,
            onDestinationSelected: controller.setNavigationIndex,
            labelType: NavigationRailLabelType.all,
            leading: const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: SonicNestMark(size: 48)),
            destinations: destinations.map((d) => NavigationRailDestination(icon: d.icon, selectedIcon: d.selectedIcon, label: Text(d.label))).toList(),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: content),
        ]) : content),
        bottomNavigationBar: wide ? null : NavigationBar(selectedIndex: controller.navigationIndex, onDestinationSelected: controller.setNavigationIndex, destinations: destinations),
      );
    });
  }
}
