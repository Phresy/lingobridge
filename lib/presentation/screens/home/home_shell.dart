import 'package:flutter/material.dart';

// FIXED: Add all required imports
import '../../screens/translation/translation_screen.dart';
import '../../screens/history/history_screen.dart';
import '../../screens/downloads/downloads_screen.dart';
import '../../screens/settings/settings_screen.dart';

/// Bottom-nav shell holding the 4 primary destinations. Voice and Profile
/// are reached from within Translation/Settings respectively (per the
/// screen list) rather than taking bottom-nav slots, keeping navigation to
/// Material 3's recommended 3-5 top-level destinations.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  // FIXED: Remove 'const' keyword - these are not constant constructors
  final _screens = [
    const TranslationScreen(),
    const HistoryScreen(),
    const DownloadsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.translate_outlined),
            selectedIcon: Icon(Icons.translate_rounded),
            label: 'Translate',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.download_outlined),
            selectedIcon: Icon(Icons.download_rounded),
            label: 'Downloads',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}