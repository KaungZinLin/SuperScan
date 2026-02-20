import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:super_scan/models/saved_scan.dart';
import 'package:super_scan/models/drive_scan.dart';
import 'package:super_scan/services/google_drive_service.dart';
import 'package:super_scan/controllers/sync_controller.dart';
import 'package:super_scan/constants.dart';
import 'package:super_scan/services/scan_storage.dart';
import 'package:flutter/services.dart';
import 'package:super_scan/models/scan_meta.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:super_scan/screens/scan_viewer_screen.dart';
import 'package:super_scan/services/google_auth_service.dart';
import 'package:super_scan/constants.dart';

class HomeController extends ChangeNotifier {
  // Alternative to !mounted in the view - don't understand it yet
  bool _isDisposed = false;
  bool get isMounted => !_isDisposed;

  final GoogleDriveService _driveService = GoogleDriveService();
  final auth = GoogleAuthService.instance;

  List<SavedScan> savedScans = [];
  List<DriveScan> driveScans = [];
  dynamic _scannedDocuments;

  bool isLoading = false;
  bool isSyncing = false;

  bool get isSignedIn => _driveService.isSignedIn;

  final String _searchQuery = '';

  @override
  void dispose() {
    _isDisposed =
        true; // Mark as disposed - Alternative to !mounted in the view - don't understand it yet
    super.dispose();
  }

  String formatDate(DateTime date) {
    return DateFormat.yMd().add_jm().format(date);
  }

  Future<void> openScanViewer(Directory scanDir, context) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ScanViewerScreen(scanDir: scanDir)),
    );

    await loadSavedScans();
    await syncScans(context);
  }

  Future<void> importImages(BuildContext context) async {
    try {
      final picker = ImagePicker();

      final images = await picker.pickMultiImage(imageQuality: 100);

      if (images.isEmpty) return;

      final paths = images.map((e) => e.path).toList();

      final scanDir = await ScanStorage.saveScanImages(paths);

      if (!isMounted) return;

      await loadSavedScans();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Imported images successfully',
            style: kTextLetterSpacing,
          ),
          behavior: SnackBarBehavior.fixed,
        ),
      );

      await syncScans(context);
    } catch (e) {
      if (!isMounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to improt images: $e',
            style: kTextLetterSpacing,
          ),
          behavior: SnackBarBehavior.fixed,
        ),
      );
    }
  }

  Future<void> processScan(
    BuildContext context,
    Future<dynamic> scanTask,
  ) async {
    try {
      final result = await scanTask;

      List<String> images = [];

      if (result is Map) {
        if (result['images'] != null) {
          images = List<String>.from(result['images']);
        } else if (result['Uri'] != null) {
          // iOS legacy keys
          images = List<String>.from(result['Uri']);
        }
      } else if (result is List) {
        // Some iOS versions return List<String>
        images = List<String>.from(result);
      }

      if (images.isEmpty) {
        if (!isMounted) return;
        _scannedDocuments = 'No images returned.';
        notifyListeners();
        return;
      }

      final scanDir = await ScanStorage.saveScanImages(images);

      if (!isMounted) return;

      _scannedDocuments = 'Scan saved to:\n${scanDir.path}';
      notifyListeners();
    } on PlatformException catch (e) {
      debugPrint('Scan error: $e');
      if (!isMounted) return;
      _scannedDocuments = 'Failed to scan document.';
      notifyListeners();
    }

    await loadSavedScans();
    notifyListeners();
    await syncScans(context);
  }

  Future<void> showScanOptions(SavedScan scan, context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Options for “${scan.meta.name}”',
            style: kTextLetterSpacing,
          ),
          content: const Text(
            'What would you like to do?',
            style: kTextLetterSpacing,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: kTextLetterSpacing),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                renameScan(scan, context);
              },
              child: const Text(
                'Rename',
                style: TextStyle(letterSpacing: 0.0, fontWeight: .bold),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                deleteScan(scan, context);
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                  letterSpacing: 0.0,
                  fontWeight: .bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> loadSavedScans() async {
    final dir = await getApplicationDocumentsDirectory();
    final scansDir = Directory('${dir.path}/scans');

    if (!await scansDir.exists()) {
      notifyListeners();
      return;
    }

    final folders = scansDir.listSync().whereType<Directory>();

    final scans = <SavedScan>[];

    for (final folder in folders) {
      final metaFile = File('${folder.path}/meta.json');
      if (!metaFile.existsSync()) continue;

      final metaJson = jsonDecode(metaFile.readAsStringSync());
      scans.add(SavedScan(dir: folder, meta: ScanMeta.fromJson(metaJson)));
    }

    // Sort newest → oldest
    scans.sort((a, b) => b.meta.createdAt.compareTo(a.meta.createdAt));

    savedScans = scans;
    notifyListeners();
  }

  Future<void> renameScan(SavedScan scan, context) async {
    final controller = TextEditingController(text: scan.meta.name);

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename scan', style: kTextLetterSpacing),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Scan Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: kTextLetterSpacing),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text(
                'Save',
                style: TextStyle(fontWeight: .bold, letterSpacing: 0.0),
              ),
            ),
          ],
        );
      },
    );

    if (result == null || result.isEmpty) return;

    await ScanStorage.renameScan(scanDir: scan.dir, newName: result);

    await loadSavedScans();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Renamed successfully', style: kTextLetterSpacing),
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }

  Future<void> deleteScan(SavedScan scan, context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete scan?', style: kTextLetterSpacing),
          content: Text(
            '“${scan.meta.name}” will be permanently deleted.',
            style: kTextLetterSpacing,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel', style: kTextLetterSpacing),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text(
                'Delete',
                style: TextStyle(fontWeight: .bold, letterSpacing: 0.0),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await ScanStorage.deleteScan(scan.dir);
    await SyncController.deleteScan(scan.dir);
    await loadSavedScans(); // Reload view

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted successfully'),
        behavior: SnackBarBehavior.fixed,
      ),
    );

    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: const Text(
    //       'Deleted locally and from Google Drive',
    //       style: kTextLetterSpacing,
    //     ),
    //     behavior: SnackBarBehavior.fixed,
    //   ),
    // );
  }

  List<SavedScan> get filteredScans {
    if (_searchQuery.isEmpty) return savedScans;

    final query = _searchQuery.toLowerCase();

    return savedScans.where((scan) {
      final name = scan.meta.name.toLowerCase();
      return name.contains(query);
    }).toList();
  }

  // GOOGLE DRIVE SYNC IMPLEMENTATION
  Future<List<Directory>> _getLocalScans() async {
    final dir = await getApplicationDocumentsDirectory();
    final scansDir = Directory('${dir.path}/scans');

    if (!scansDir.existsSync()) return [];
    return scansDir.listSync().whereType<Directory>().toList();
  }

  Future<void> syncScans(BuildContext context, {bool force = false}) async {
    if (!isSignedIn) {
      return; // Retrun if not signed in without any prompts because the app doesnt force you to use an account
    }

    isSyncing = true; // start syncing
    isLoading = true;
    notifyListeners(); // Notify to start suncing

    try {
      final scans = await _getLocalScans();
      await SyncController.syncScans(scans, force: force);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sync failed: $e'),
          behavior: SnackBarBehavior.fixed,
        ),
      );
    } finally {
      isSyncing = false; // Stop syncing
      isLoading = false; // Stop loading
      notifyListeners();
    }
  }

  Future<void> openDriveScan(DriveScan scan, BuildContext context) async {
    try {
      final scanDir = await _driveService.downloadScanFolder(
        folderId: scan.folderId,
        folderName: scan.meta.name,
      );

      if (!isMounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ScanViewerScreen(scanDir: scanDir)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to open scan: $e'), behavior: .fixed),
      );
    }
  }

  Future<void> loadDriveScans() async {
    if (!isSignedIn) return;

    isLoading = true; // Start loading animation
    notifyListeners(); // Notify about animation

    final scans = await _driveService
        .fetchDriveScans(); // Fetch scans from Drive and save them to scans
    driveScans = scans; // Move synced documents from scans to driveScans to use

    isLoading = false; // Stop loading animation
    notifyListeners(); // Notify about the end of animation
  }
}
