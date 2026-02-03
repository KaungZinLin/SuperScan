import 'package:flutter/material.dart';
import 'package:super_scan/screens/home_page.dart';
import 'package:super_scan/screens/loading_screen.dart';
import 'package:super_scan/screens/settings_page.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

void main() {
  runApp(const SuperScan());
}

class SuperScan extends StatelessWidget {
  const SuperScan({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SuperScan',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          // Change color theme for light mode
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          // Changed color theme for dark mode
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const MainLayout(),
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
  bool _isloading = true;

  final List<Widget> _pages = const [
    HomePage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isloading = false;
        });
      }
    });
  }

  // Added desktop check
  bool get isDesktop {
    if (kIsWeb) return false;
    return Platform.isMacOS || Platform.isWindows || Platform.isLinux;
  }

  @override
  Widget build(BuildContext context) {
    if (_isloading) {
      return LoadingScreen();
    }

    final bool isWide = MediaQuery
        .of(context)
        .size
        .width >= 600;

    return Scaffold(
        body: Row(
          children: [
            if (isWide)
              NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (i) =>
                    setState(() => _selectedIndex = i),
                labelType: NavigationRailLabelType.all,
                destinations: [
                  NavigationRailDestination(
                    // Changed to sync on desktop
                    icon: Icon(isDesktop ? Icons.sync : Icons.home,),
                    label: Text(
                      isDesktop ? 'Sync' : 'Home',
                      style: TextStyle(
                        // fontSize: 12.0,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings),
                    label: Text(
                      'Settings',
                      style: TextStyle(
                        // fontSize: 12.0,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ),
                ],
              ),

            if (isWide) const VerticalDivider(thickness: 1, width: 1),

            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: _pages,
              ),
            ),
          ],
        ),

        bottomNavigationBar: isWide ? null : NavigationBarTheme(
          data: NavigationBarThemeData(
            labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
                  (states) =>
                  TextStyle(
                    letterSpacing: 0.0,
                  ),
            ),
          ),
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) => setState(() => _selectedIndex = i),
            destinations: [
              // Changed to Sync on desktop
              NavigationDestination(icon: Icon(isDesktop ? Icons.sync : Icons.home), label: isDesktop ? 'Sync' : 'Home',),
              NavigationDestination(
                  icon: Icon(Icons.settings), label: 'Settings'),
            ],
          ),
        )
      );
    }
  }