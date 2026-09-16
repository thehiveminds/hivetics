

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shared/theme.dart';
import 'state/theme_notifier.dart';
import 'features/sites/sites_screen.dart';
import 'features/deploys/deploys_screen.dart';
import 'features/settings/settings_screen.dart';
import 'widgets/bottom_tab_bar.dart';

class HiveHubApp extends ConsumerWidget {
  const HiveHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Hivetics',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: HHTheme.light().withHHExtension(),
      darkTheme: HHTheme.dark().withHHExtension(),
      home: const _RootShell(),
    );
  }
}

class _RootShell extends StatefulWidget {
  const _RootShell();

  @override
  State<_RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<_RootShell> {
  int _index = 0;


  static const _screens = [
    SitesScreen(),
    DeploysScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final hh = context.hh;

    return Scaffold(
      backgroundColor: hh.bgBase,

      extendBody: true,
      body: IndexedStack(
        index: _index,
        children: _screens,
      ),
      bottomNavigationBar: BottomTabBar(
        currentIndex: _index,
        onTap: (i) {
          if (i == _index) {
            return;
          }
          setState(() => _index = i);
        },
      ),
    );
  }
}
