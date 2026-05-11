import 'dart:async';
import 'package:flutter/material.dart';
import 'package:super_scan/helpers/inline_ad_helper.dart';
import 'package:super_scan/helpers/toast_helper.dart';
import 'package:super_scan/localization/locales.dart';
import 'package:super_scan/main.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:super_scan/controllers/home_controller.dart';
import 'package:super_scan/screens/settings_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_localization/flutter_localization.dart';
// import 'package:super_scan/widgets/action_button.dart';
// import 'package:super_scan/widgets/expandable_fab.dart';
import 'package:super_scan/helpers/platform_helper.dart';
import 'package:super_scan/constants.dart';
import 'package:super_scan/widgets/ad_banner.dart';
import 'dart:io';
import 'package:super_scan/widgets/no_scans_widgets.dart';
import 'package:super_scan/widgets/scan_search_delegate.dart';

import '../models/singletons_data.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  final _viewController = HomeController();

  bool _loading = false;

  bool isConnected = false;

  @override
  void initState() {
    super.initState();

    _initialize();

    _viewController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  // Subscribe to route changes
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  // Dispose
  @override
  void dispose() {
    InlineAdManager.dispose();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // Reload when search is closed
  @override
  void didPopNext() async {
    await _viewController.loadSavedScans();

    if (!mounted) return;
    setState(() {});
  }

  Future<void> _initialize() async {
    setState(() => _loading = true); // Start loading animation

    await _viewController.loadSavedScans(); // Load scans

    if (!mounted) return;

    setState(() => _loading = false); // Stop loading animation

    // Only load drive scans on desktop
    if (PlatformHelper.isDesktop) {
      await _viewController.loadDriveScans();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scansToShow =
    (PlatformHelper.isDesktop
        ? _viewController.filteredDesktopScans
        : _viewController.filteredScans)
        .where((s) => s.dir.existsSync())
        .toList();

    final showAds =
        !appData.entitlementIsActive &&
            !PlatformHelper.isDesktop;

    const adFrequency = 3;

    final adCount = showAds
        ? (scansToShow.length / adFrequency).floor()
        : 0;

    final totalItemCount =
        scansToShow.length + adCount;

    final errorMessage = LocaleData.unexpected_error.getString(context);



    return Scaffold(
      floatingActionButton: PlatformHelper.isDesktop
          ? null
          : FloatingActionButton.extended(
        label: Text(LocaleData.scan.getString(context)),
        icon: const Icon(Icons.add_rounded),
        backgroundColor: kAccentColor,
        foregroundColor: Colors.white,
        onPressed: () async {
          if (Platform.isAndroid) {
            _viewController.processScan(
              errorMessage,
              context,
              FlutterDocScanner().getScannedDocumentAsImages(page: 4),
            );
          } else {
            await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text(
                    'How would you like to scan your documents?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(LocaleData.cancel.getString(context)),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        _viewController.importImages(errorMessage);
                      },
                      child: Text(
                        LocaleData.from_photos.getString(context),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        _viewController.processScan(
                          errorMessage,
                          context,
                          FlutterDocScanner().getScannedDocumentAsImages(
                              page: 4),
                        );
                      },
                      child: Text(
                        LocaleData.from_camera.getString(context),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                );
              },
            );
          }
        },
      ),

      appBar: AppBar(
        centerTitle: true,
        title: const Text(
            'SuperScan', style: TextStyle(fontWeight: FontWeight.bold)),
        leadingWidth: 100,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.settings_rounded, color: kAccentColor),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
            IconButton(
              icon: _viewController.isSyncing || _viewController.isLoading
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: kAccentColor,
                  strokeWidth: 2,
                ),
              )
                  : Icon(Icons.cloud_sync_rounded, color: kAccentColor),
              onPressed: (_viewController.isSyncing || _loading)
                  ? null
                  : () async {
                if (!_viewController.auth.isSignedIn) {
                  ToastHelper.show('Sign in to sync');
                }

                final error = await _viewController.syncScans(errorMessage);

                if (!context.mounted) return;

                if (error != null) {
                  ToastHelper.show(error);
                }
                if (PlatformHelper.isDesktop) {
                  await _viewController.loadDriveScans();
                }
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search_rounded, color: kAccentColor),
            onPressed: () async {
              await showSearch(
                context: context,
                delegate: ScanSearchDelegate(scansToShow),
              );

              await _viewController.loadSavedScans();
              await WidgetsBinding.instance.endOfFrame;
              await _viewController.syncScans(errorMessage);
            },
          ),
        ],
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          // Load inline ads ONCE
          return Stack(
            children: [
              SafeArea(
                child: scansToShow.isEmpty
                    ? EmptyScansPlaceHolder()
                    : ListView.builder(
                  //key: UniqueKey(),
                  padding: const EdgeInsets.all(16),
                  itemCount: totalItemCount,
                  itemBuilder: (context, index) {
                    // Ad Slot
                    // Ad Slot Logic
                    if (showAds &&
                        (index + 1) % (adFrequency + 1) == 0) {
                      final adIndex = index ~/ (adFrequency + 1);

                      return ValueListenableBuilder<int>(
                        valueListenable: InlineAdManager.adUpdate,
                        builder: (context, _, __) {
                          final ad = InlineAdManager.getAd(adIndex);
                          final isLoaded = ad.responseInfo != null;

                          return AnimatedSize(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.fastOutSlowIn,
                            child: isLoaded
                                ? Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: kAccentColor.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min, // Shrink to fit content
                                  children: [
                                    // The "Ad" Label
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: Text(
                                        "AD",
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: kAccentColor.withOpacity(0.6),
                                        ),
                                      ),
                                    ),
                                    // The actual Ad
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(12),
                                        bottomRight: Radius.circular(12),
                                      ),
                                      child: SizedBox(
                                        width: ad.size.width.toDouble(),
                                        height: ad.size.height.toDouble(),
                                        child: AdWidget(ad: ad),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                                : const SizedBox(width: double.infinity, height: 0),
                          );
                        },
                      );
                    }

                    // NORMAL ITEM
                    final scanIndex =
                        index - (index ~/ (adFrequency + 1));

                    final savedScan = scansToShow[scanIndex];
                    final scanDir = savedScan.dir;
                    final meta = savedScan.meta;

                    if (!scanDir.existsSync()) {
                      return const SizedBox.shrink();
                    }

                    final pages = scanDir
                        .listSync()
                        .whereType<File>()
                        .where((f) => f.path.endsWith('.jpg'))
                        .length;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0.0,
                      color: kAccentColor.withAlpha(20),
                      child: ListTile(
                        trailing: const Icon(Icons.chevron_right_rounded),
                        title: Text(meta.name),
                        subtitle: Text(
                            '${context.formatString(LocaleData.pages, [pages])} • ${_viewController.formatDate(errorMessage, meta.createdAt)}'
                        ),
                        onLongPress: () =>
                            _viewController.showScanOptions(errorMessage, savedScan, context),
                        onTap: () async {
                          _viewController
                              .openScanViewer(errorMessage, scanDir, context)
                              .then((_) {
                            _viewController.loadSavedScans();
                            _viewController.syncScans(errorMessage);
                          });
                        },
                      ),
                    );
                  },
                ),
              ),

              if (_loading)
                Container(
                  color: Theme
                      .of(context)
                      .scaffoldBackgroundColor
                      .withValues(alpha: 0.9),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [CircularProgressIndicator()],
                    ),
                  ),
                ),
            ],
          );
        },
      ),

      bottomNavigationBar:
      PlatformHelper.isDesktop ||
          appData.entitlementIsActive
          ? null
          : BottomAppBar(
        height: 100,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 1.0),
          child: Row(children: [Expanded(child: const AdBanner())]),
        ),
      ),
    );
  }
}
