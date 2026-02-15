import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/navigation_provider.dart';
import '../widgets/app_drawer.dart';

import 'home_page.dart';
import 'setting_page.dart';
import 'map_page.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  final List<Widget> _pages = const [
    HomePage(),
    SettingsPage(),
    MapPage(),
  ];

  final List<String> _pageTitles = const [
    'Home',
    'Settings',
    'Map',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedIndex = ref.watch(navigationProvider);

    return Scaffold(
      appBar: selectedIndex != 0
          ? AppBar(
              title: Text(
                _pageTitles[selectedIndex],
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              elevation: 0,
            )
          : null,
      drawer: const AppDrawer(),
      body: _pages[selectedIndex],
    );
  }
}
