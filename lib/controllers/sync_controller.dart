import 'dart:io';

import '../models/sync_index.dart';
import '../helpers/scan_utils.dart';

import '../services/google_auth_service.dart';
import '../services/google_drive_service.dart';

class SyncController {
  SyncController._();

  static final GoogleDriveService _drive =
      GoogleDriveService.instance;

  static final GoogleAuthService _auth =
      GoogleAuthService.instance;

  static Future<void> syncScans(
      List<Directory> scans, {
        bool force = false,
      }) async {
    if (!_auth.isSignedIn) return;

    final index = await SyncIndex.load();

    final tasks = <Future<void>>[];

    for (final scan in scans) {
      final id = ScanUtils.scanId(scan);

      final localTime =
      ScanUtils.lastModified(scan);

      final lastSynced =
      DateTime.fromMillisecondsSinceEpoch(
        index[id] ?? 0,
      );

      if (!force && !localTime.isAfter(lastSynced)) {
        continue;
      }

      tasks.add(() async {
        await _drive.uploadScan(scan);

        index[id] =
            DateTime.now().millisecondsSinceEpoch;
      }());
    }

    if (tasks.isEmpty) return;

    await Future.wait(tasks);

    await SyncIndex.save(index);
  }

  static Future<void> deleteScan(
      Directory scanDir) async {
    if (!_auth.isSignedIn) return;

    final id = ScanUtils.scanId(scanDir);

    await _drive.deleteScanFolder(id);
  }
}