import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:super_scan/helpers/platform_helper.dart';
import 'package:super_scan/helpers/toast_helper.dart';
import 'constants.dart';
import 'package:super_scan/screens/home_screen.dart';
import 'package:super_scan/screens/settings_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:super_scan/services/google_auth_service.dart';
import 'package:permission_handler/permission_handler.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
RouteObserver<ModalRoute<void>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  MobileAds.instance.initialize();

  await initializeDateFormatting();
  await GoogleAuthService.instance.initialize();

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
      navigatorObservers: [routeObserver],

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

// ... existing imports ...

class _MainLayoutState extends State<MainLayout> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Added missing observer initialization
    _requestInitialPermission();
    ToastHelper.init(context);
  }

  // Trigger the popup as soon as the app opens
  Future<void> _requestInitialPermission() async {
    if (!PlatformHelper.isDesktop) {
      await Permission.camera.request();
      setState(() {}); // Refresh to show HomeScreen if granted
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: _getPermissions(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.data == true) {
            return HomeScreen();
          }

          return Scaffold(
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image(image: AssetImage('assets/images/app_icon.png'), height: 100,),
                      SizedBox(height: 16),
                      Text(
                        'Welcome to SuperScan',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'In order to use SuperScan, you need to give the app access to your camera.',
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30,),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.tonalIcon(
                              onPressed: openAppSettings,
                              label: const Text('Open Settings'),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.tonalIcon(
                              onPressed: () {
                                setState(() {});
                              },
                              label: const Text('Refresh'),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ]
                ),
              ),
            ),
          );
        }
    );
  }

  Future<bool> _getPermissions() async {
    if (PlatformHelper.isDesktop) {
      // Always return true on desktop as camera permissions aren't required
      return true;
    }

    var cameraStatus = await Permission.camera.status;

    bool cameraOk = cameraStatus.isGranted;

    if (cameraOk) {
      return true;
    }

    return false;
  }
}