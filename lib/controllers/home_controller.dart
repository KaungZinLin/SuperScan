import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:super_scan/models/saved_scan.dart';
import 'package:super_scan/models/drive_scan.dart';
import 'package:super_scan/services/google_drive_service.dart';
import 'package:super_scan/controllers/sync_controller.dart';
import 'package:super_scan/services/scan_storage.dart';
import 'package:flutter/services.dart';
import 'package:super_scan/models/scan_meta.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
// import 'package:image_picker/image_picker.dart';
import 'package:super_scan/screens/scan_viewer_screen.dart';
import 'package:super_scan/services/google_auth_service.dart';
import 'package:windows_toast/windows_toast.dart';
import 'package:image/image.dart' as img;
class HomeController extends ChangeNotifier {
  // Alternative to !mounted in the view - don't understand it yet
  bool _isDisposed = false;
  bool get isMounted => !_isDisposed;

  final GoogleDriveService _driveService = GoogleDriveService();
  final auth = GoogleAuthService.instance;

  List<SavedScan> savedScans = [];
  List<DriveScan> driveScans = [];
  List<SavedScan> desktopSavedScans = [];
  // ignore: unused_field
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

  // Future<void> openScanViewer(Directory scanDir, context) async {
  //   await Navigator.push<bool>(
  //     context,
  //     MaterialPageRoute(builder: (_) => ScanViewerScreen(scanDir: scanDir)),
  //   );

  //   await loadSavedScans();
  //   await syncScans(context);
  // }
  // scan viewer opener
  Future<void> openScanViewer(Directory scanDir, context) async {
  final changed = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (_) => ScanViewerScreen(scanDir: scanDir),
    ),
  );

  // ONLY reload if something changed
  if (changed == true) {
    await Future.delayed(const Duration(milliseconds: 150));

    await loadSavedScans();
    await syncScans();
  }
}

// May cause context errors: ignored because it is not used
  // Future<void> importImages() async {
  //   try {
  //     final picker = ImagePicker();
  //
  //     final images = await picker.pickMultiImage(imageQuality: 100);
  //
  //     if (images.isEmpty) return;
  //
  //     final paths = images.map((e) => e.path).toList();
  //
  //     final scanDir = await ScanStorage.saveScanImages(paths);
  //
  //     if (!isMounted) return;
  //
  //     await loadSavedScans();
  //
  //     WindowsToast.show(
  //         'Imported images successfully',
  //         context,
  //         30,
  //     );
  //
  //     await syncScans();
  //   } catch (e) {
  //     if (!isMounted) return;
  //
  //     WindowsToast.show(
  //         'Failed to import images: $e',
  //         context,
  //         30,
  //     );
  //   }
  // }


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
          images = List<String>.from(result['Uri']);
        }
      } else if (result is List) {
        images = List<String>.from(result);
      }

      if (images.isEmpty) {
        if (!isMounted) return;
        _scannedDocuments = 'No images returned.';
        notifyListeners();
        return;
      }

      // Normalize paths
      images = images.map((p) => Uri.parse(p).toFilePath()).toList();

      // Compress images
      for (final path in images) {
        try {
          final file = File(path);

          final bytes = await file.readAsBytes();
          final decoded = img.decodeImage(bytes);

          if (decoded == null) continue;

          final optimized = decoded.width > 2200
              ? img.copyResize(decoded, width: 2200)
              : decoded;

          final compressed = img.encodePng(optimized, level: 9);

          await file.writeAsBytes(compressed, flush: true);
        } catch (e) {
          debugPrint('Image compression failed for $path: $e');
        }
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
    await syncScans();
  }

  Future<void> showScanOptions(SavedScan scan, context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Options for “${scan.meta.name}”',
          ),
          content: const Text(
            'What would you like to do?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                renameScan(scan, context);
              },
              child: const Text(
                'Rename',
                style: TextStyle(letterSpacing: 0.0)
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
          title: const Text('Rename scan'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Scan Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text(
                'Save',
                style: TextStyle(fontWeight: .bold),
              ),
            ),
          ],
        );
      },
    );

    if (result == null || result.isEmpty) return;

    await ScanStorage.renameScan(scanDir: scan.dir, newName: result);

    await loadSavedScans();
    await syncScans();
  }

  Future<void> deleteScan(SavedScan scan, context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete scan?'),
          content: Text(
            '“${scan.meta.name}” will be permanently deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text(
                'Delete',
                style: TextStyle(fontWeight: .bold),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await SyncController.deleteScan(scan.dir); // Delete from Google Drive
    await ScanStorage.deleteScan(scan.dir); // Delete locally

    await loadSavedScans(); // Reload view
    // print('Reloaded save scans');

    WindowsToast.show(
        'Deleted permanently',
        context,
        30,
    );
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

  Future<String?> syncScans({bool force = false}) async {
    if (!isSignedIn) return null;

    isSyncing = true;
    isLoading = true;
    notifyListeners();

    try {
      final scans = await _getLocalScans();
      await SyncController.syncScans(scans, force: force);
      return null; // success
    } catch (e) {
      return 'Failed to sync: $e'; // Return the error
    } finally {
      isSyncing = false;
      isLoading = false;
      notifyListeners();
    }
  }

  // Future<void> syncScans(BuildContext context, {bool force = false}) async {
  //   if (!isSignedIn) {
  //     return; // Return if not signed in without any prompts because the app doesn't force you to use an account
  //   }
  //
  //   isSyncing = true; // start syncing
  //   isLoading = true; // Start loading
  //   notifyListeners(); // Notify to start syncing/loading
  //
  //   try {
  //     final scans = await _getLocalScans();
  //     await SyncController.syncScans(scans, force: force);
  //   } catch (e) {
  //     WindowsToast.show(
  //         'Failed to sync: $e',
  //         context,
  //         30,
  //     );
  //   } finally {
  //     isSyncing = false; // Stop syncing
  //     isLoading = false; // Stop loading
  //     notifyListeners();
  //   }
  // }

  Future<Directory> openDriveScan(DriveScan scan) async {
    final scanDir = await _driveService.downloadScanFolder(
      folderId: scan.folderId,
    );

    return scanDir;
  }

  // Future<void> openDriveScan(DriveScan scan, BuildContext context) async {
  //   try {
  //     final scanDir = await _driveService.downloadScanFolder(
  //       folderId: scan.folderId,
  //       folderName: scan.meta.name,
  //     );
  //
  //     if (!isMounted) return;
  //
  //    await Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (_) => ScanViewerScreen(scanDir: scanDir)),
  //     );
  //
  //   } catch (e) {
  //     WindowsToast.show(
  //         'Failed to open scan: $e',
  //         context,
  //         30,
  //     );
  //   }
  // }

  Future<void> loadDriveScans() async {
    if (!isSignedIn) return;

    isLoading = true;
    notifyListeners();

    final driveScans = await _driveService.fetchDriveScans();
    desktopSavedScans = [];

    const int concurrency = 5; // number of parallel downloads
    final scanQueue = List<DriveScan>.from(driveScans);

    while (scanQueue.isNotEmpty) {
      // Take up to `concurrency` scans from the queue
      final batch = scanQueue.take(concurrency).toList();
      scanQueue.removeRange(0, batch.length);

      // Download batch in parallel
      await Future.wait(batch.map((d) async {
        try {
          final folderName = d.meta.name;
          final localDir = await _driveService.downloadScanFolder(
            folderId: d.folderId,
          );

          desktopSavedScans.add(SavedScan(dir: localDir, meta: d.meta));
          notifyListeners(); // update UI progressively
        } catch (e) {
          // print("Failed to download '${d.meta.name}': $e");
        }
      }));
    }

    isLoading = false;
    notifyListeners();

    // print("Desktop scans loaded: ${desktopSavedScans.length}");
  }

    /// Load scans from Google Drive (desktop)
  // Future<void> loadDriveScans() async {
  //   if (!isSignedIn) return;

  //   isLoading = true;
  //   notifyListeners();

  //   // Fetch DriveScan objects from Google Drive
  //   final driveScans = await _driveService.fetchDriveScans();

  //   // Clear previous desktop scans
  //   desktopSavedScans = [];

  //   for (final d in driveScans) {
  //     try {
  //       // Download the Drive folder to a temporary directory
  //       final localDir = await _driveService.downloadScanFolder(
  //         folderId: d.folderId,
  //         folderName: d.meta.name,
  //       );

  //       // Wrap it as a SavedScan (dir is non-nullable)
  //       final savedScan = SavedScan(
  //         dir: localDir,
  //         meta: d.meta,
  //       );

  //       desktopSavedScans.add(savedScan);

  //       print("Added desktop scan: ${d.meta.name} from folder ${d.folderId}");
  //     } catch (e) {
  //       print("Failed to download Drive scan ${d.meta.name}: $e");
  //     }
  //   }

  //   isLoading = false;
  //   notifyListeners();

  //   print("Desktop scans loaded: ${desktopSavedScans.length}");
  // }

  // /// Desktop-specific filtered getter
  List<SavedScan> get filteredDesktopScans {
    if (_searchQuery.isEmpty) return desktopSavedScans;

    final query = _searchQuery.toLowerCase();

    return desktopSavedScans.where((scan) {
      final name = scan.meta.name.toLowerCase();
      return name.contains(query);
    }).toList();
  }
}
