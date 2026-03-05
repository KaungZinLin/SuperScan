import 'dart:async';
import 'package:flutter/material.dart';
import 'package:super_scan/main.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:super_scan/controllers/home_controller.dart';
import 'package:super_scan/screens/settings_screen.dart';
// import 'package:super_scan/widgets/action_button.dart';
// import 'package:super_scan/widgets/expandable_fab.dart';
import 'package:super_scan/helpers/platform_helper.dart';
import 'package:super_scan/constants.dart';
import 'dart:io';
import 'package:super_scan/widgets/no_scans_widgets.dart';
import 'package:super_scan/widgets/scan_search_delegate.dart';
import 'package:super_scan/widgets/ad_banner.dart';
import 'package:windows_toast/windows_toast.dart';

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
    final scansToShow = PlatformHelper.isDesktop
        ? _viewController.filteredDesktopScans
        : _viewController.filteredScans;
    return Scaffold(
      // Completely removed FAB on desktop
      floatingActionButton: PlatformHelper.isDesktop
          ? null
          // Disabled custom FAB as the app is Android-only for now and the scanning screen already allows users to import images
          // : ExpandableFab(
          //     distance: 20,
          //     children: [
          //       ActionButton(
          //         icon: Icon(Icons.photo_library, color: Colors.white),
          //         onPressed: () {
          //           _viewController.importImages(context);
          //         },
          //       ),
          //       ActionButto
      //       letterSpacing(
          //         icon: Icon(Icons.camera_alt, color: Colors.white),
          //         onPressed: () {
          //           _viewController.processScan(
          //             context,
          //             FlutterDocScanner().getScannedDocumentAsImages(page: 4),
          //           );
          //         },
          //       ),
          //     ],
          //   ),
      : FloatingActionButton.extended(
        label: Text('Scan'),
        icon: Icon(Icons.add),
        backgroundColor: kAccentColor,
        foregroundColor: Colors.white,
        onPressed: () {
          _viewController.processScan(
            context,
            FlutterDocScanner().getScannedDocumentAsImages(page: 4),
          );
        },
      ),
      // Changed appBar name to Sync on desktop
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'SuperScan',
          style: TextStyle(fontWeight: .bold),
        ),
        leadingWidth: 100,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.settings, color: kAccentColor),
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
              icon:
                  _viewController.isSyncing ||
                      _viewController
                          .isLoading // Show indicator if either local syncing or desktop loading is active
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: kAccentColor,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(Icons.cloud_sync, color: kAccentColor),
              onPressed: (_viewController.isSyncing || _loading)
                  ? null
                  : () async {
                      if (!_viewController.auth.isSignedIn) {
                        WindowsToast.show('Sign in to sync', context, 30);
                      }
                      // await _viewController.syncScans();
                      final error = await _viewController.syncScans();

                      if (!context.mounted) return;

                      if (error != null) {
                        WindowsToast.show(error, context, 30);
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
            icon: Icon(Icons.search, color: kAccentColor),
              onPressed: () async {
                await showSearch(
                  context: context,
                  delegate: ScanSearchDelegate(scansToShow),
                );

                await _viewController.loadSavedScans();

                // Wait until the UI has fully returned to the home screen
                await WidgetsBinding.instance.endOfFrame;

                await _viewController.syncScans();
              }
          )],
      ),

      body: Stack(
        children: [
          SafeArea(
            child: scansToShow.isEmpty
                ? EmptyScansPlaceHolder()
                : ListView.builder(
              key: UniqueKey(),
                    padding: const EdgeInsets.all(16),
                    itemCount: scansToShow.length,
                    itemBuilder: (context, index) {
                      final savedScan = scansToShow[index];
                      final scanDir = savedScan.dir;
                      final meta = savedScan.meta;
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
                          trailing: const Icon(Icons.chevron_right),
                          title: Text(meta.name),
                          subtitle: Text(
                            '$pages page(s) • ${_viewController.formatDate(meta.createdAt)}',
                          ),
                          onLongPress: () => _viewController.showScanOptions(
                            savedScan,
                            context,
                          ),
                          onTap: () async {
                            _viewController.openScanViewer(scanDir, context).then((_) {
                              _viewController.loadSavedScans();
                              _viewController.syncScans();
                            });
                          },
                        ),
                      );
                    },
                  ),
          ),

          if (_loading)
            Container(
              color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.9),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [CircularProgressIndicator()],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: PlatformHelper.isDesktop
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
