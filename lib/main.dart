import 'package:flutter/material.dart';
import 'constants.dart';
import 'package:super_scan/screens/home_screen.dart';
import 'package:super_scan/screens/settings_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:super_scan/services/google_auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  runApp(const SuperScan());
  await GoogleAuthService.instance.tryRestoreSession();
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
  int _currentPageIndex = 0;

  final List<Widget> _pagesByIndex = const [
    HomeScreen(), // Index 0
    SettingsScreen(), // Index 1
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pagesByIndex[_currentPageIndex],
      bottomNavigationBar:
      NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        selectedIndex: _currentPageIndex,
        destinations: [
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.settings),
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}