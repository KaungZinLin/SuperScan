import 'dart:io';
import 'dart:convert';
import 'package:googleapis/drive/v3.dart' as drive;
import 'google_auth_service.dart';
import 'package:super_scan/models/drive_scan.dart';
import 'package:super_scan/models/scan_meta.dart';
import 'package:path_provider/path_provider.dart';

class GoogleDriveService {
  GoogleDriveService._internal();

  static final GoogleDriveService instance = GoogleDriveService._internal();

  factory GoogleDriveService() => instance;

  Future<drive.DriveApi?> _api() async {
    final client = await GoogleAuthService.instance.getAuthenticatedClient();

    if (client == null) return null;

    return drive.DriveApi(client);
  }

  bool get isSignedIn => GoogleAuthService.instance.isSignedIn;

  // New upload scan written by AI to check for existing files
  Future<void> uploadScan(Directory scanDir) async {
  final api = await _api();

  if (api == null) {
    throw Exception("Not signed in");
  }

  final scanId =
      scanDir.path.split(Platform.pathSeparator).last;

  // Ensure folder structure
  final rootId = await _ensureFolder(api, "SuperScan", null);
  final syncedId = await _ensureFolder(api, "synced", rootId);
  final scanFolderId =
      await _ensureFolder(api, scanId, syncedId);

  // --------------------------------------------------
  // NEW: Fetch existing files in Drive folder
  // --------------------------------------------------
  final existing = await api.files.list(
    q: "'$scanFolderId' in parents and trashed=false",
    spaces: 'drive',
    $fields: 'files(id,name)',
  );

  final existingFiles = {
    for (final f in existing.files ?? [])
      if (f.name != null) f.name!: f.id!
  };

  // --------------------------------------------------
  // Upload (overwrite behavior)
  // --------------------------------------------------
  for (final entity in scanDir.listSync()) {
    if (entity is! File) continue;

    final fileName = entity.uri.pathSegments.last;

    // DELETE existing file with same name
    final existingId = existingFiles[fileName];
    if (existingId != null) {
      await api.files.delete(existingId);
    }

    final media =
        drive.Media(entity.openRead(), await entity.length());

    await api.files.create(
      drive.File()
        ..name = fileName
        ..parents = [scanFolderId],
      uploadMedia: media,
    );
  }
}

  // Future<void> uploadScan(Directory scanDir) async {
  //   final api = await _api();

  //   if (api == null) {
  //     throw Exception("Not signed in");
  //   }

  //   final scanId = scanDir.path.split(Platform.pathSeparator).last;

  //   final rootId = await _ensureFolder(api, "SuperScan", null);

  //   final syncedId = await _ensureFolder(api, "synced", rootId);

  //   final scanFolderId = await _ensureFolder(api, scanId, syncedId);

  //   for (final entity in scanDir.listSync()) {
  //     if (entity is! File) continue;

  //     final media = drive.Media(entity.openRead(), await entity.length());

  //     await api.files.create(
  //       drive.File()
  //         ..name = entity.uri.pathSegments.last
  //         ..parents = [scanFolderId],
  //       uploadMedia: media,
  //     );
  //   }
  // }

  // =============================
  // Delete scan
  // =============================

  Future<void> deleteScanFolder(String scanId) async {
    final api = await _api();

    if (api == null) return;

    final result = await api.files.list(
      q: "name='$scanId' and mimeType='application/vnd.google-apps.folder'",
    );

    if (result.files?.isEmpty ?? true) return;

    await api.files.delete(result.files!.first.id!);
  }

  Future<List<DriveScan>> fetchDriveScans() async {
    final api = await _api();
    if (api == null) return [];

    // 1. List scan folders
    final folders = await api.files.list(
      q: "mimeType = 'application/vnd.google-apps.folder' and trashed = false",
      spaces: 'drive',
    );

    if (folders.files == null) return [];

    final scans = <DriveScan>[];

    for (final folder in folders.files!) {
      final folderId = folder.id!;

      // 2. Find meta.json inside folder
      final metaResult = await api.files.list(
        q: "'$folderId' in parents and name = 'meta.json' and trashed = false",
        spaces: 'drive',
      );

      if (metaResult.files == null || metaResult.files!.isEmpty) continue;

      final metaFile = metaResult.files!.first;

      // 3. Download meta.json
      final media =
          await api.files.get(
                metaFile.id!,
                downloadOptions: drive.DownloadOptions.fullMedia,
              )
              as drive.Media;

      final content = await media.stream.transform(utf8.decoder).join();
      final meta = ScanMeta.fromJson(jsonDecode(content));

      scans.add(DriveScan(folderId: folderId, meta: meta));
    }

    // newest → oldest
    scans.sort((a, b) => b.meta.createdAt.compareTo(a.meta.createdAt));
    return scans;
  }

  Future<Directory> downloadScanFolder({
    required String folderId,
    required String folderName,
  }) async {
    final api = await _api();
    if (api == null) {
      throw Exception('Drive API not initialized');
    }

    final tempDir = await getTemporaryDirectory();
    final scanDir = Directory('${tempDir.path}/$folderName');

    if (!await scanDir.exists()) {
      await scanDir.create(recursive: true);
    }

    // List all files inside the Drive folder
    final result = await api.files.list(
      q: "'$folderId' in parents and trashed = false",
      spaces: 'drive',
      $fields: 'files(id,name,mimeType)',
    );

    final files = result.files ?? [];

    for (final file in files) {
      if (file.mimeType?.startsWith('image/') != true &&
          file.mimeType != 'application/json') {
        // skip non-image / non-json files
        continue;
      }

      final media = await api.files.get(
        file.id!,
        downloadOptions: drive.DownloadOptions.fullMedia,
      );

      // Cast to Media to access the stream
      final mediaStream = (media as drive.Media).stream;

      // Read all bytes
      final bytes = <int>[];
      await for (final chunk in mediaStream) {
        bytes.addAll(chunk);
      }

      final localFile = File('${scanDir.path}/${file.name}');
      await localFile.writeAsBytes(bytes);
    }

    return scanDir;
  }

  // =============================
  // Helpers
  // =============================

  Future<String> _ensureFolder(
    drive.DriveApi api,
    String name,
    String? parentId,
  ) async {
    final query = parentId == null
        ? "mimeType='application/vnd.google-apps.folder' and name='$name'"
        : "mimeType='application/vnd.google-apps.folder' and name='$name' and '$parentId' in parents";

    final existing = await api.files.list(q: query);

    if (existing.files?.isNotEmpty ?? false) {
      return existing.files!.first.id!;
    }

    final folder = await api.files.create(
      drive.File()
        ..name = name
        ..mimeType = 'application/vnd.google-apps.folder'
        ..parents = parentId == null ? null : [parentId],
    );

    return folder.id!;
  }
}
