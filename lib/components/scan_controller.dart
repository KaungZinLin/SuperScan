import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:super_scan/components/saved_scan.dart';
import 'package:super_scan/components/scan_meta.dart';
import 'package:super_scan/components/scan_storage.dart';
import 'dart:convert';

class ScanController extends ChangeNotifier {
  List<SavedScan> _scans = [];

  List<SavedScan> get scans => List.unmodifiable(_scans);

  /// Load all scans
  Future<void> loadScans() async {
    final dir = await getApplicationDocumentsDirectory();
    final scansDir = Directory('${dir.path}/scans');

    if (!scansDir.existsSync()) {
      _scans = [];
      notifyListeners();
      return;
    }

    final folders = scansDir.listSync().whereType<Directory>();
    final loaded = <SavedScan>[];

    for (final folder in folders) {
      final metaFile = File('${folder.path}/meta.json');
      if (!metaFile.existsSync()) continue;

      final json = jsonDecode(metaFile.readAsStringSync());
      loaded.add(
        SavedScan(
          dir: folder,
          meta: ScanMeta.fromJson(json),
        ),
      );
    }

    loaded.sort((a, b) => b.meta.createdAt.compareTo(a.meta.createdAt));
    _scans = loaded;
    notifyListeners();
  }

  /// Rename
  Future<void> renameScan(SavedScan scan, String newName) async {
    await ScanStorage.renameScan(
      scanDir: scan.dir,
      newName: newName,
    );
    await loadScans();
  }

  /// Delete
  Future<void> deleteScan(SavedScan scan) async {
    await ScanStorage.deleteScan(scan.dir);
    await loadScans();
  }

  /// Create (after scanning)
  Future<void> addScanFromImages(List<String> images) async {
    await ScanStorage.saveScanImages(images);
    await loadScans();
  }
}