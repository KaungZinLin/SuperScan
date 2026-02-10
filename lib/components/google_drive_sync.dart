import 'dart:io';
import 'package:googleapis/drive/v3.dart' as drive;
import 'google_drive_service.dart';

class GoogleDriveSync {
  static Future<String> _ensureFolder(drive.DriveApi api,
      String name,
      String? parentId,) async {
    final q = parentId == null
        ? "mimeType='application/vnd.google-apps.folder' and name='$name' and trashed=false"
        : "mimeType='application/vnd.google-apps.folder' and name='$name' and '$parentId' in parents and trashed=false";

    final res = await api.files.list(q: q);
    if (res.files!.isNotEmpty) return res.files!.first.id!;

    final folder = drive.File()
      ..name = name
      ..mimeType = 'application/vnd.google-apps.folder'
      ..parents = parentId == null ? null : [parentId];

    final created = await api.files.create(folder);
    return created.id!;
  }

  static Future<void> uploadScan(Directory scanDir) async {
    final service = GoogleDriveService();
    final api = service.driveApi;

    if (api == null) {
      throw Exception('Google Drive not signed in');
    }

    final scanId = scanDir.path.split(Platform.pathSeparator).last;

    final rootId = await _ensureFolder(api, 'SuperScan', null);
    final syncedId = await _ensureFolder(api, 'synced', rootId);
    final scanFolderId = await _ensureFolder(api, scanId, syncedId);

    for (final entity in scanDir.listSync()) {
      if (entity is! File) continue;

      final media = drive.Media(
        entity.openRead(),
        await entity.length(),
      );

      final file = drive.File()
        ..name = entity.uri.pathSegments.last
        ..parents = [scanFolderId];

      await api.files.create(
        file,
        uploadMedia: media,
      );
    }
  }
}