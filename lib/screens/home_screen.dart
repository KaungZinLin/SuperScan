import 'package:flutter/material.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:super_scan/controllers/home_controller.dart';
import 'package:super_scan/widgets/action_button.dart';
import 'package:super_scan/widgets/expandable_fab.dart';
import 'package:super_scan/helpers/platform_helper.dart';
import 'package:super_scan/constants.dart';
import 'dart:io';
import 'package:super_scan/widgets/no_scans_widgets.dart';
import 'package:super_scan/widgets/scan_search_delegate.dart';
import 'package:super_scan/services/google_drive_service.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // List<SavedScan> _savedScans = [];
  // List<DriveScan> _driveScans = [];

  final _viewController = HomeController();

  bool _syncing = false;
  bool _loading = false;


  /// Helper to handle the scanner calls and catch platform errors

  // Future<void> _loadDriveScans() async {
  //   if (!_isSignedIn) return;
  //
  //   setState(() => _loading = true);
  //   final scans = await _driveService.fetchDriveScans();
  //   setState(() {
  //     _driveScans = scans;
  //     _loading = false;
  //   });
  // }

  final _driveService = GoogleDriveService(); // Singleton instance

// Refreshing Drive API if needed


  // Future<List<Directory>> _getLocalScans() async {
  //   final dir = await getApplicationDocumentsDirectory();
  //   final scansDir = Directory('${dir.path}/scans');
  //
  //   if (!scansDir.existsSync()) return [];
  //   return scansDir.listSync().whereType<Directory>().toList();
  // }
  //
  // Future<void> _syncScans({bool force = false}) async {
  //   if (!_isSignedIn) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Sign in first to sync your scans.'),
  //         behavior: SnackBarBehavior.floating,
  //       ),
  //     );
  //     return;
  //   }
  //
  //   setState(() => _syncing = true); // start loading
  //
  //   try {
  //     final scans = await _getLocalScans();
  //     await SyncController.syncScans(scans, force: force);
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Sync failed: $e'), behavior: SnackBarBehavior.floating,),
  //     );
  //   } finally {
  //     if (mounted) setState(() => _syncing = false); // stop loading
  //   }
  // }

  // Future<void> _openDriveScan(DriveScan scan) async {
  //   try {
  //     final scanDir = await GoogleDriveService().downloadScanFolder(
  //       folderId: scan.folderId,
  //       folderName: scan.meta.name,
  //     );
  //
  //     if (!mounted) return;
  //
  //     await Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (_) => ScanViewerScreen(scanDir: scanDir),
  //       ),
  //     );
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to open scan: $e'), behavior: .floating,),
  //     );
  //   }
  // }

  @override
  void initState() {
    super.initState();
    _viewController.loadSavedScans(); // always load local scans

    _viewController.addListener(() {
      if (mounted) setState(() {});
    });

    // Restore sign-in and then load Drive scans
    // GoogleDriveService().restoreSignIn().then((_) async {
    //   if (!mounted) return;
    //
    //   setState(() {}); // refresh _isSignedIn for UI
    //
    //   if (PlatformHelper.isDesktop && GoogleDriveService().isSignedIn) {
    //     await _loadDriveScans();
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Completely removed FAB on desktop
      floatingActionButton: PlatformHelper.isDesktop ? null :
          ExpandableFab(
            distance: 20,
            children: [
              ActionButton(
                icon: Icon(Icons.photo_library, color: Colors.white,),
                onPressed: () {
                  _viewController.importImages(context);
                },
              ),
              ActionButton(
                icon: Icon(Icons.camera_alt, color: Colors.white,),
                onPressed: () {
                  _viewController.processScan(FlutterDocScanner().getScannedDocumentAsImages(
                      page: 4));
                },
              ),
            ],
          ),
      // Changed appBar name to Sync on desktop
      appBar: AppBar(
        centerTitle: true,
        title: Text('Home', style: kTextLetterSpacing,),
        leading: IconButton(
          icon: _syncing || _loading // Show indicator if either local syncing or desktop loading is active
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
            //await _syncScans();
            if (PlatformHelper.isDesktop) {
              print('Loading drive scans on desktop');
              // await _loadDriveScans();
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: kAccentColor,),
            onPressed: () => showSearch(
              context: context,
              delegate: ScanSearchDelegate(_viewController.savedScans),
            ),
          ),
        ],
      ),

        body: SafeArea(
          child:
              _viewController.filteredScans.isEmpty ? EmptyScansPlaceholder()
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
                  title: Text(
                    meta.name,
                    style: kTextLetterSpacing,
                  ),
                  subtitle: Text(
                    '$pages page(s) • ${_viewController.formatDate(meta.createdAt)}',
                    style: kTextLetterSpacing,
                  ),
                  onLongPress: () => _viewController.showScanOptions(savedScan, context),
                  onTap: () async {
                    _viewController.openScanViewer(scanDir, context);
                    //await _syncScans(); - Disabled syncing for now
                  },
                ),
              );
            },
          ),
        )
    );
  }
}