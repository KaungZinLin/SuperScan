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

class HomeController extends ChangeNotifier {
  // Alternative to !mounted in the view - don't understand it yet
  bool _isDisposed = false;
  bool get isMounted => !_isDisposed;

  final GoogleDriveService _driveService = GoogleDriveService();

  List <SavedScan> savedScans = [];
  List <DriveScan> driveScans = [];
  dynamic _scannedDocuments;

  bool isLoading = false;
  bool isSyncing = false;

  bool get isSignedIn => _driveService.isSignedIn;

  final String _searchQuery = '';

  @override
  void dispose() {
    _isDisposed = true; // Mark as disposed - Alternative to !mounted in the view - don't understand it yet
    super.dispose();
  }

  String formatDate(DateTime date) {
    return DateFormat.yMd().add_jm().format(date);
  }

  Future<void> openScanViewer(Directory scanDir, context) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ScanViewerScreen(scanDir: scanDir),
      ),
    );

    await loadSavedScans();
    // await _syncScans(); - disabled for now
  }

  Future<void> importImages(BuildContext context) async {
    try {
      final picker = ImagePicker();

      final images = await picker.pickMultiImage(
        imageQuality: 100,
      );

      if (images.isEmpty) return;

      final paths = images.map((e) => e.path).toList();

      final scanDir = await ScanStorage.saveScanImages(paths);

      if (!isMounted) return;

      await loadSavedScans();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Imported images successfully', style: kTextLetterSpacing,),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // await _syncScans(); - disabled for now
    } catch (e) {
      if (!isMounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to improt images: $e', style: kTextLetterSpacing,),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> processScan(Future<dynamic> scanTask) async {
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
    // await _syncScans(); - Disabled for now
  }

  Future<void> showScanOptions(SavedScan scan, context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Options for “${scan.meta.name}”', style: kTextLetterSpacing,),
          content: const Text('What would you like to do?', style: kTextLetterSpacing,),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                style: kTextLetterSpacing,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                renameScan(scan, context);
              },
              child: const Text('Rename', style: TextStyle(
                  letterSpacing: 0.0,
                  fontWeight: .bold
              )),
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
                    fontWeight: .bold
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
      scans.add(
        SavedScan(
          dir: folder,
          meta: ScanMeta.fromJson(metaJson),
        ),
      );
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
          title: const Text('Rename scan', style: kTextLetterSpacing,),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Scan Name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: kTextLetterSpacing,),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, controller.text.trim()),
              child: const Text('Save', style: TextStyle(fontWeight: .bold, letterSpacing: 0.0)),
            ),
          ],
        );
      },
    );


    if (result == null || result.isEmpty) return;

    await ScanStorage.renameScan(
      scanDir: scan.dir,
      newName: result,
    );

    await loadSavedScans();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Renamed successfully', style: kTextLetterSpacing,),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> deleteScan(SavedScan scan, context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete scan?', style: kTextLetterSpacing,),
          content: Text(
            '“${scan.meta.name}” will be permanently deleted.',
            style: kTextLetterSpacing,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel', style: kTextLetterSpacing,),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete', style: TextStyle(fontWeight: .bold, letterSpacing: 0.0)),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await ScanStorage.deleteScan(scan.dir);
    await SyncController.deleteScan(scan.dir);
    await loadSavedScans(); // Reload view

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Deleted locally and from Google Drive', style: kTextLetterSpacing,),
        behavior: SnackBarBehavior.floating,
      ),
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
}