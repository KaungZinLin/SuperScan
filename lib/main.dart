import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:purchases_flutter/models/store.dart';
import 'package:super_scan/helpers/auth_restore_result.dart';
import 'package:super_scan/helpers/platform_helper.dart';
import 'package:super_scan/helpers/toast_helper.dart';
import 'package:super_scan/iap_constants.dart';
import 'package:super_scan/localization/locales.dart';
import 'constants.dart';
import 'package:super_scan/screens/home_screen.dart';
import 'package:super_scan/screens/settings_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:super_scan/services/google_auth_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:upgrader/upgrader.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:super_scan/services/language_service.dart';
import 'package:super_scan/store_config.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'models/singletons_data.dart';


final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

void main() async {
  if (Platform.isIOS || Platform.isMacOS) {
    StoreConfig(
      store: Store.appStore,
      apiKey: appleApiKey,
    );
  } else if (Platform.isAndroid) {
    // Run the app passing --dart-define=AMAZON=true
    const useAmazon = bool.fromEnvironment("amazon");
    StoreConfig(
      store: useAmazon ? Store.amazon : Store.playStore,
      apiKey: useAmazon ? appleApiKey : googleApiKey,
    );
  }

  // This is for Flutter itself
  WidgetsFlutterBinding.ensureInitialized();

  await _configureSDK();
  await loadPremiumStatus();

  // This is required specifically for the flutter_localization package
  // to prevent the EnsureInitializeException
  await FlutterLocalization.instance.ensureInitialized();

  final savedLang = await LanguageService.getLanguage();

  FlutterLocalization.instance.init(
    mapLocales: LOCALES,
    initLanguageCode: savedLang ?? "en",
  );

  if (!PlatformHelper.isDesktop &&
      !appData.entitlementIsActive) {
    await MobileAds.instance.initialize();
  } else {
    debugPrint('Ads disabled for premium/desktop user');
  }

  await initializeDateFormatting();

  final result = await GoogleAuthService.instance.initialize();

  if (result == AuthRestoreResult.expired) {
    // Optionally try to force a sign-in without user interaction
    // or set a flag to show a "Session Expired" snackbar in the UI.
    await GoogleAuthService.instance.signIn();
  }

  runApp(const SuperScan());
}


class SuperScan extends StatefulWidget {
  const SuperScan({super.key});

  @override
  State<SuperScan> createState() => _SuperScanState();
}

class _SuperScanState extends State<SuperScan> {
  final FlutterLocalization localization = FlutterLocalization.instance;

  @override
  void initState() {
    super.initState();
    // 2. Listen for language changes to rebuild the app
    localization.onTranslatedLanguage = onTranslatedLanguage;
  }

  void onTranslatedLanguage(Locale? locale) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: kLightThemeData,
      darkTheme: kDarkThemeData,
      themeMode: ThemeMode.system,
      navigatorObservers: [routeObserver],

      // 3. Localization Delegates and Supported Locales
      supportedLocales: localization.supportedLocales,
      localizationsDelegates: localization.localizationsDelegates,

      home: UpgradeAlert(
        upgrader: Upgrader(
          durationUntilAlertAgain: const Duration(hours: 2),
        ),
        child: const MainLayout(),
      ),
      routes: {
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

class _MainLayoutState extends State<MainLayout> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestInitialPermission();
    ToastHelper.init(context);
    _checkAuth();
  }

  Future<void> _requestInitialPermission() async {
    if (!PlatformHelper.isDesktop) {
      await Permission.camera.request();
      if (mounted) setState(() {});
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
          return const HomeScreen();
        }

        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Image(
                    image: AssetImage('assets/images/app_icon.png'),
                    height: 100,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Welcome to SuperScan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'In order to use SuperScan, you need to give the app access to your camera.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
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
                          onPressed: () => setState(() {}),
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _getPermissions() async {
    if (PlatformHelper.isDesktop) return true;

    var cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted) {
      cameraStatus = await Permission.camera.request();
    }

    if (!cameraStatus.isGranted) return false;

    if (Platform.isAndroid) return true;

    if (Platform.isIOS) {
      var photoStatus = await Permission.photos.status;
      if (!photoStatus.isGranted && !photoStatus.isLimited) {
        photoStatus = await Permission.photos.request();
      }
      return photoStatus.isGranted || photoStatus.isLimited;
    }
    return false;
  }

  Future<void> _checkAuth() async {
    final result = await GoogleAuthService.instance.initialize();
    if (!mounted) return;

    if (result == AuthRestoreResult.expired) {
      ToastHelper.show('Your Google session expired. Please sign in again.');
    }
  }
}

Future<void> _configureSDK() async {
  // Enable debug logs before calling `configure`.
  await Purchases.setLogLevel(LogLevel.debug);

  /*
    - appUserID is nil, so an anonymous ID will be generated automatically by the Purchases SDK. Read more about Identifying Users here: https://docs.revenuecat.com/docs/user-ids

    - PurchasesAreCompletedyBy is PurchasesAreCompletedByRevenueCat, so Purchases will automatically handle finishing transactions. Read more about completing purchases here: https://www.revenuecat.com/docs/migrating-to-revenuecat/sdk-or-not/finishing-transactions
    */
  PurchasesConfiguration configuration;
  if (StoreConfig.isForAmazonAppstore()) {
    configuration = AmazonConfiguration(StoreConfig.instance.apiKey)
      ..appUserID = null
      ..purchasesAreCompletedBy = const PurchasesAreCompletedByRevenueCat();
  } else {
    configuration = PurchasesConfiguration(StoreConfig.instance.apiKey)
      ..appUserID = null
      ..purchasesAreCompletedBy = const PurchasesAreCompletedByRevenueCat();
  }
  await Purchases.configure(configuration);
}

Future<void> loadPremiumStatus() async {

  // Temporarily force premium for testing
  // appData.entitlementIsActive = false;
  // return;

  try {
    final customerInfo = await Purchases.getCustomerInfo();

    final entitlement =
    customerInfo.entitlements.all[entitlementID];

    appData.entitlementIsActive =
        entitlement?.isActive ?? false;
  } catch (e) {
    appData.entitlementIsActive = false;
  }
}