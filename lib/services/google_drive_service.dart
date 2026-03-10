import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'google_auth_service.dart';
import 'package:super_scan/models/drive_scan.dart';
import 'package:super_scan/models/scan_meta.dart';
import 'package:path_provider/path_provider.dart';

class GoogleDriveService {
  GoogleDriveService._internal();

  static final GoogleDriveService instance = GoogleDriveService._internal();
  final Map<String, String> _folderCache =
      {}; // Cache drive folder IDs to avoid multiple network calls

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

    final scanId = scanDir.path.split(Platform.pathSeparator).last;

    // Ensure folder structure
    final rootId = await _ensureFolder(api, "SuperScan", null);
    final syncedId = await _ensureFolder(api, "synced", rootId);
    final scanFolderId = await _ensureFolder(api, scanId, syncedId);

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
        if (f.name != null) f.name!: f.id!,
    };

    // --------------------------------------------------
    // Upload (overwrite behavior) OLD UPLOAD
    // --------------------------------------------------
    // --------------------------------------------------
    // SMART SYNC (MD5 based)
    // --------------------------------------------------

    final tasks = <Future<void> Function()>[];

    for (final entity in scanDir.listSync()) {
      if (entity is! File) continue;

      tasks.add(() async {
        final fileName = entity.uri.pathSegments.last;

        final localBytes = await entity.readAsBytes();
        final localMd5 = base64.encode(md5.convert(localBytes).bytes);

        final existingId = existingFiles[fileName];

        if (existingId != null) {
          // Fetch Drive file metadata including checksum
          final driveFile = await api.files.get(
            existingId,
            $fields: 'id,name,md5Checksum',
          ) as drive.File;

          final driveMd5 = driveFile.md5Checksum;

          if (driveMd5 == localMd5) {
            //  File is identical → skip
            return;
          }

          // File changed → delete and reupload
          await api.files.delete(existingId);
        }

        // Upload new or changed file
        final media = drive.Media(entity.openRead(), await entity.length());

        await api.files.create(
          drive.File()
            ..name = fileName
            ..parents = [scanFolderId],
          uploadMedia: media,
        );
      });
    }

// run 3 uploads simultaneously
    await _runWithLimit(tasks, 3);
    // final tasks = <Future<void> Function()>[];
    //
    // for (final entity in scanDir.listSync()) {
    //   if (entity is! File) continue;
    //
    //   tasks.add(() async {
    //     final fileName = entity.uri.pathSegments.last;
    //
    //     final existingId = existingFiles[fileName];
    //     if (existingId != null) {
    //       await api.files.delete(existingId);
    //     }
    //
    //     final media = drive.Media(entity.openRead(), await entity.length());
    //
    //     await api.files.create(
    //       drive.File()
    //         ..name = fileName
    //         ..parents = [scanFolderId],
    //       uploadMedia: media,
    //     );
    //   });
    // }
    //
    // // run 3 uploads simultaneously
    // await _runWithLimit(tasks, 3);
    // for (final entity in scanDir.listSync()) {
    //   if (entity is! File) continue;

    //   final fileName = entity.uri.pathSegments.last;

    //   // DELETE existing file with same name
    //   final existingId = existingFiles[fileName];
    //   if (existingId != null) {
    //     await api.files.delete(existingId);
    //   }

    //   final media =
    //       drive.Media(entity.openRead(), await entity.length());

    //   await api.files.create(
    //     drive.File()
    //       ..name = fileName
    //       ..parents = [scanFolderId],
    //     uploadMedia: media,
    //   );
    // }
  }

  // =============================
  // Delete scan
  // =============================

  // Deletes a scan folder under SuperScan/synced by scanId - AI
  Future<void> deleteScanFolder(String scanId) async {
    final api = await _api();
    if (api == null) return;

    // Get SuperScan folder
    final rootResult = await api.files.list(
      q: "name='SuperScan' and mimeType='application/vnd.google-apps.folder' and trashed=false",
    );
    if (rootResult.files == null || rootResult.files!.isEmpty) return;
    final rootId = rootResult.files!.first.id!;

    // Get synced folder
    final syncedResult = await api.files.list(
      q: "'$rootId' in parents and name='synced' and trashed=false",
    );
    if (syncedResult.files == null || syncedResult.files!.isEmpty) return;
    final syncedId = syncedResult.files!.first.id!;

    // Find the scan folder inside synced
    final scanResult = await api.files.list(
      q: "name='$scanId' and mimeType='application/vnd.google-apps.folder' and '$syncedId' in parents",
    );
    if (scanResult.files == null || scanResult.files!.isEmpty) return;

    // Delete
    await api.files.delete(scanResult.files!.first.id!);
  }

  // Future<void> deleteScanFolder(String scanId) async {
  //   final api = await _api();

  //   if (api == null) return;

  //   final result = await api.files.list(
  //     q: "name='$scanId' and mimeType='application/vnd.google-apps.folder'",
  //   );

  //   if (result.files?.isEmpty ?? true) return;

  //   await api.files.delete(result.files!.first.id!);
  // }
  // Fetches all scans under SuperScan/synced: ai WRITTEN
  Future<List<DriveScan>> fetchDriveScans() async {
    final api = await _api();
    if (api == null) return [];

    // Get SuperScan folder
    final rootResult = await api.files.list(
      q: "name='SuperScan' and mimeType='application/vnd.google-apps.folder' and trashed=false",
    );

    print(
      "SuperScan folders: ${rootResult.files?.map((f) => f.name).toList()}",
    );

    // Step 2: Check synced
    if (rootResult.files?.isNotEmpty ?? false) {
      final superScanId = rootResult.files!.first.id!;
      final syncedResult = await api.files.list(
        q: "'$superScanId' in parents and name='synced' and trashed=false",
      );
      print(
        "Synced folders: ${syncedResult.files?.map((f) => f.name).toList()}",
      );

      if (syncedResult.files?.isNotEmpty ?? false) {
        final syncedId = syncedResult.files!.first.id!;
        final scanFoldersResult = await api.files.list(
          q: "'$syncedId' in parents and mimeType='application/vnd.google-apps.folder' and trashed=false",
        );
        print(
          "Scan folders under synced: ${scanFoldersResult.files?.map((f) => f.name).toList()}",
        );
      }
    }

    if (rootResult.files == null || rootResult.files!.isEmpty) return [];
    final rootId = rootResult.files!.first.id!;

    // Get synced folder
    final syncedResult = await api.files.list(
      q: "'$rootId' in parents and name='synced' and trashed=false",
    );
    if (syncedResult.files == null || syncedResult.files!.isEmpty) return [];
    final syncedId = syncedResult.files!.first.id!;

    // List all scan folders inside synced
    final scanFoldersResult = await api.files.list(
      q: "'$syncedId' in parents and mimeType='application/vnd.google-apps.folder' and trashed=false",
    );
    final scanFolders = scanFoldersResult.files ?? [];

    final scans = <DriveScan>[];

    for (final folder in scanFolders) {
      final folderId = folder.id!;

      // 4️⃣ Look for meta.json in this scan folder
      final metaResult = await api.files.list(
        q: "'$folderId' in parents and name='meta.json' and trashed=false",
        spaces: 'drive',
      );

      if (metaResult.files == null || metaResult.files!.isEmpty) continue;
      print(
        "Folder ${folder.name} contains: ${metaResult.files?.map((f) => f.name).toList()}",
      );

      final metaFile = metaResult.files!.first;

      // 5️⃣ Download meta.json
      final media =
          await api.files.get(
                metaFile.id!,
                downloadOptions: drive.DownloadOptions.fullMedia,
              )
              as drive.Media;

      final content = await media.stream.transform(utf8.decoder).join();
      final meta = ScanMeta.fromJson(jsonDecode(content));

      scans.add(DriveScan(folderId: folderId, meta: meta));
      print("Added scan: ${meta.name} from folder ${folder.name}"); // Debug
    }

    // newest → oldest
    scans.sort((a, b) => b.meta.createdAt.compareTo(a.meta.createdAt));
    return scans;
  }
  // Future<List<DriveScan>> fetchDriveScans() async {
  //   final api = await _api();
  //   if (api == null) return [];

  //   // 1. List scan folders
  //   final folders = await api.files.list(
  //     q: "mimeType = 'application/vnd.google-apps.folder' and trashed = false",
  //     spaces: 'drive',
  //   );

  //   if (folders.files == null) return [];

  //   final scans = <DriveScan>[];

  //   for (final folder in folders.files!) {
  //     final folderId = folder.id!;

  //     // 2. Find meta.json inside folder
  //     final metaResult = await api.files.list(
  //       q: "'$folderId' in parents and name = 'meta.json' and trashed = false",
  //       spaces: 'drive',
  //     );

  //     if (metaResult.files == null || metaResult.files!.isEmpty) continue;

  //     final metaFile = metaResult.files!.first;

  //     // 3. Download meta.json
  //     final media =
  //         await api.files.get(
  //               metaFile.id!,
  //               downloadOptions: drive.DownloadOptions.fullMedia,
  //             )
  //             as drive.Media;

  //     final content = await media.stream.transform(utf8.decoder).join();
  //     final meta = ScanMeta.fromJson(jsonDecode(content));

  //     scans.add(DriveScan(folderId: folderId, meta: meta));
  //   }

  //   // newest → oldest
  //   scans.sort((a, b) => b.meta.createdAt.compareTo(a.meta.createdAt));
  //   return scans;
  // }

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
    final cacheKey = "$parentId/$name";
    if (_folderCache.containsKey(cacheKey)) {
      return _folderCache[cacheKey]!;
    }

    final query = parentId == null
        ? "mimeType='application/vnd.google-apps.folder' and name='$name'"
        : "mimeType='application/vnd.google-apps.folder' and name='$name' and '$parentId' in parents";

    final existing = await api.files.list(q: query);

    if (existing.files?.isNotEmpty ?? false) {
      // return existing.files!.first.id!;
      final id = existing.files!.first.id!;
      _folderCache[cacheKey] = id;
      return id;
    }

    final folder = await api.files.create(
      drive.File()
        ..name = name
        ..mimeType = 'application/vnd.google-apps.folder'
        ..parents = parentId == null ? null : [parentId],
    );

    final id = folder.id!;
    _folderCache[cacheKey] = id;
    return id;
  }

  Future<void> _runWithLimit(
    List<Future<void> Function()> tasks,
    int limit,
  ) async {
    final executing = <Future<void>>[];

    for (final task in tasks) {
      final future = task();

      // remove when finished
      executing.add(
        future.whenComplete(() {
          executing.remove(future);
        }),
      );

      if (executing.length >= limit) {
        await Future.any(executing);
      }
    }

    await Future.wait(executing);
  }
}
