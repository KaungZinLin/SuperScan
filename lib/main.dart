import 'package:flutter/material.dart';

import 'constants.dart';

import 'package:super_scan/components/launch_controller.dart';

import 'package:super_scan/widgets/adaptive_navigation_rail.dart';
import 'package:super_scan/widgets/adaptive_navigation_bar.dart';
import 'package:super_scan/components/navigation_destinations.dart';

import 'package:super_scan/screens/home_screen.dart';
import 'package:super_scan/screens/loading_screen.dart';
import 'package:super_scan/screens/settings_screen.dart';

void main() {
  runApp(const SuperScan());
}

class SuperScan extends StatelessWidget {
  const SuperScan({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: kLightThemeData,
      darkTheme: kDarkThemeData,
      themeMode: ThemeMode.system,

      initialRoute: '/',
      routes: {
        '/': (_) => const MainLayout(),
        HomeScreen.id: (_) => const HomeScreen(),
        SettingsScreen.id: (_) => const SettingsScreen(),
      },
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  final LaunchController _launchController = LaunchController();
  bool _isLoading = true;

  final List<Widget> _pagesByIndex = const [
    HomeScreen(), // Index 0
    SettingsScreen(), // Index 1
  ];

  @override
  void initState() {
    super.initState();
    _runStartupSequence();
  }

  Future<void> _runStartupSequence() async {
    await _launchController.initializeApp();

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingScreen();
    }

    final bool isWide =
        MediaQuery
            .of(context)
            .size
            .width >= kDesktopBreakpoint;

    return Scaffold(
        body: Row(
          children: [
            if (isWide)
              AdaptiveNavigationRail(
                selectedIndex: _selectedIndex,
                onSelected: (i) => setState(() => _selectedIndex = i),
                destinations: railDestinations,
              ),

            if (isWide) const VerticalDivider(thickness: 1, width: 1),

            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: _pagesByIndex,
              ),
            ),
          ],
        ),

        bottomNavigationBar: isWide ? null : AdaptiveBottomNavigation
          (
          selectedIndex: _selectedIndex,
          onSelected: (i) => setState(() => _selectedIndex = i),
          destinations: bottomDestinations,
          labelStyle: kNavigationBarLabelStyle,
        )
    );
  }
}