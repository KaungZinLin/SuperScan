import 'dart:io';
import '../models/sync_index.dart';
import 'package:super_scan/services/google_drive_sync.dart';
import 'package:super_scan/helpers/scan_utils.dart';
import 'package:super_scan/services/google_drive_service.dart';

class SyncController {
  static Future<void> syncScans(
      List<Directory> scans, {
        bool force = false,
      }) async {
    final index = await SyncIndex.load();

    // Create a list of 'Tasks' (Futures)
    List<Future<void>> syncTasks = [];

    for (final scan in scans) {
      final id = ScanUtils.scanId(scan);
      final localTime = ScanUtils.lastModified(scan);
      final lastSynced = DateTime.fromMillisecondsSinceEpoch(
        index[id] ?? 0,
      );

      if (!force && !localTime.isAfter(lastSynced)) continue;

      // We add the function call to the list WITHOUT 'awaiting' it yet
      syncTasks.add(() async {
        await GoogleDriveSync.uploadScan(scan);
        index[id] = DateTime.now().millisecondsSinceEpoch;
      }());
    }

    // Now, run all tasks in parallel and wait for all to finish
    if (syncTasks.isNotEmpty) {
      await Future.wait(syncTasks);
      await SyncIndex.save(index);
    }
  }

  static final _drive = GoogleDriveService();

  static Future<void> deleteScan(Directory scanDir) async {
    if (!_drive.isSignedIn || _drive.driveApi == null) return;

    final scanId = scanDir.path.split('/').last;
    await _drive.deleteScanFolder(scanId);
  }
}