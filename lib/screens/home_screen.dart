import 'package:flutter/material.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:super_scan/controllers/home_controller.dart';
import 'package:super_scan/screens/settings_screen.dart';
import 'package:super_scan/widgets/action_button.dart';
import 'package:super_scan/widgets/expandable_fab.dart';
import 'package:super_scan/helpers/platform_helper.dart';
import 'package:super_scan/constants.dart';
import 'dart:io';
import 'package:super_scan/widgets/no_scans_widgets.dart';
import 'package:super_scan/widgets/scan_search_delegate.dart';
import 'package:super_scan/widgets/ad_banner.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _viewController = HomeController();

  final bool _syncing = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    _initialize();

    _viewController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  Future<void> _initialize() async {
    setState(() => _loading = true); // Start loading animation

    await _viewController.loadSavedScans(); // Load scans

    if (!mounted) return;

    setState(() => _loading = false); // Stop loading animation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Completely removed FAB on desktop
      floatingActionButton: PlatformHelper.isDesktop
          ? null
          : ExpandableFab(
              distance: 20,
              children: [
                ActionButton(
                  icon: Icon(Icons.photo_library, color: Colors.white),
                  onPressed: () {
                    _viewController.importImages(context);
                  },
                ),
                ActionButton(
                  icon: Icon(Icons.camera_alt, color: Colors.white),
                  onPressed: () {
                    _viewController.processScan(
                      context,
                      FlutterDocScanner().getScannedDocumentAsImages(page: 4),
                    );
                  },
                ),
              ],
            ),
      // Changed appBar name to Sync on desktop
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'SuperScan',
          style: TextStyle(fontWeight: .bold, letterSpacing: 0.0),
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
              onPressed: (_syncing || _loading)
                  ? null
                  : () async {
                      await _viewController.syncScans(context);
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
            onPressed: () => showSearch(
              context: context,
              delegate: ScanSearchDelegate(_viewController.savedScans),
            ),
          ),
        ],
      ),

      body: Stack(
        children: [
          SafeArea(
            child: _viewController.filteredScans.isEmpty
                ? EmptyScansPlaceholder()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _viewController.filteredScans.length,
                    itemBuilder: (context, index) {
                      final savedScan = _viewController.filteredScans[index];
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
                          title: Text(meta.name, style: kTextLetterSpacing),
                          subtitle: Text(
                            '$pages page(s) • ${_viewController.formatDate(meta.createdAt)}',
                            style: kTextLetterSpacing,
                          ),
                          onLongPress: () => _viewController.showScanOptions(
                            savedScan,
                            context,
                          ),
                          onTap: () async {
                            _viewController.openScanViewer(scanDir, context);
                            //await _syncScans(); - Disabled syncing for now
                          },
                        ),
                      );
                    },
                  ),
          ),

          if (_loading)
            Container(
              color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [CircularProgressIndicator()],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        height: 100,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 1.0),
          child: Row(children: [Expanded(child: const AdBanner())]),
        ),
      ),
    );
  }
}
