import 'package:flutter/material.dart';

// Ensure these imports match your actual file structure
import 'home_page.dart';
import 'setting_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // The pages connect to the logic you already built
  final List<Widget> _pages = const [
    HomePage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(234, 239, 239, 1),
      body: SafeArea(
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: NavigationBar(
            backgroundColor: Colors.white,
            elevation: 0,
            height: 65,
            selectedIndex: _selectedIndex,

            // FIX 1: Removes the "unsymmetric purple shadow" completely
            indicatorColor: Colors.transparent,

            // FIX 2: Prevents icons from "jumping" up and down
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,

            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(
                // FIX 3: Removed manual Padding (Flutter centers it automatically)
                icon: Icon(Icons.home_outlined, size: 34),
                selectedIcon: Icon(
                  Icons.home,
                  color: Color.fromARGB(131, 37, 36, 36),
                  size: 34, // Matched size to prevent resizing jump
                ),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined, size: 34),
                selectedIcon: Icon(
                  Icons.settings,
                  color: Color.fromARGB(131, 37, 36, 36),
                  size: 34,
                ),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
