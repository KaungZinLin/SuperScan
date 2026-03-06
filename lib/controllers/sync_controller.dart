import 'dart:io';
import 'package:super_scan/services/scan_storage.dart';
import 'dart:convert';
import 'package:super_scan/models/scan_meta.dart';
import '../models/sync_index.dart';
import '../helpers/scan_utils.dart';
import '../services/google_auth_service.dart';
import '../services/google_drive_service.dart';

class SyncController {
  SyncController._();

  static final GoogleDriveService _drive = GoogleDriveService.instance;

  static final GoogleAuthService _auth = GoogleAuthService.instance;

  static Future<void> syncScans(
    List<Directory> scans, {
    bool force = false,
  }) async {
    if (!_auth.isSignedIn) return;

    final index = await SyncIndex.load();

    final tasks = <Future<void>>[];

    for (final scan in scans) {
      final id = ScanUtils.scanId(scan);

      final localTime = ScanUtils.lastModified(scan);

      final lastSynced = DateTime.fromMillisecondsSinceEpoch(index[id] ?? 0);

      if (!force && !localTime.isAfter(lastSynced)) {
        continue;
      }

      tasks.add(() async {
        await _drive.uploadScan(scan);

        await ScanStorage.markAsSynced(scanDir: scan);

        // index[id] = DateTime.now().millisecondsSinceEpoch;
        index[id] = localTime.millisecondsSinceEpoch; // Removed datetime.now as it can cause unnecessary re-syncs if the device clock changes
      }());
    }

    if (tasks.isEmpty) return;

    await Future.wait(tasks);

    await SyncIndex.save(index);
  }

  static Future<void> deleteScan(Directory scanDir) async {
    if (!_auth.isSignedIn) return;

    // Try to get the Drive folder ID from local meta.json
    String? driveFolderId;
    final metaFile = File('${scanDir.path}/meta.json');
    if (await metaFile.exists()) {
      try {
        final json = jsonDecode(await metaFile.readAsString());
        final meta = ScanMeta.fromJson(json);
        driveFolderId = meta.driveFolderId;
      } catch (e) {
        print('Error reading meta.json: $e');
      }
    }

    if (driveFolderId != null && driveFolderId.isNotEmpty) {
      // Use the stored ID – direct and reliable
      await _drive.deleteScanFolderById(driveFolderId);
    } else {
      // Fallback to old name‑based deletion (for scans synced before this change)
      final id = ScanUtils.scanId(scanDir);
      await _drive.deleteScanFolder(id);
    }
  }

  // static Future<void> deleteScan(Directory scanDir) async {
  //   if (!_auth.isSignedIn) return;
  //
  //   final id = ScanUtils.scanId(scanDir);
  //
  //   await _drive.deleteScanFolder(id);
  // }
}
