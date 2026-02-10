import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'drive_scan.dart';
import 'package:super_scan/components/scan_meta.dart';
import 'dart:io';                          // for Directory, File
import 'package:path_provider/path_provider.dart';



/// Singleton service to manage Google Sign-In and Drive API
class GoogleDriveService {
  static final GoogleDriveService _instance = GoogleDriveService._();
  GoogleDriveService._();
  factory GoogleDriveService() => _instance;

  GoogleSignInAccount? _currentUser;
  drive.DriveApi? _driveApi;

  GoogleSignInAccount? get currentUser => _currentUser;
  drive.DriveApi? get driveApi => _driveApi;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveFileScope],
  );

  // Call this on app start
  Future<void> restoreSignIn() async {
    _currentUser ??= _googleSignIn.currentUser ?? await _googleSignIn.signInSilently();
    if (_currentUser != null && _driveApi == null) {
      final authHeaders = await _currentUser!.authHeaders;
      _driveApi = drive.DriveApi(_GoogleAuthClient(authHeaders));
    }
  }

  Future<bool> signIn() async {
    _currentUser = await _googleSignIn.signIn();
    if (_currentUser == null) return false;

    final authHeaders = await _currentUser!.authHeaders;
    _driveApi = drive.DriveApi(_GoogleAuthClient(authHeaders));
    return true;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
    _driveApi = null;
  }

  Future<void> deleteScanFolder(String scanId) async {
    if (_driveApi == null) return;

    // Find folder in Drive
    final result = await _driveApi!.files.list(
      q: "name = '$scanId' and mimeType = 'application/vnd.google-apps.folder' and trashed = false",
      spaces: 'drive',
    );

    if (result.files == null || result.files!.isEmpty) return;

    final folderId = result.files!.first.id!;
    await _driveApi!.files.delete(folderId);
  }

  bool get isSignedIn => _currentUser != null && _driveApi != null;


  Future<List<DriveScan>> fetchDriveScans() async {
    if (_driveApi == null) return [];

    // 1. List scan folders
    final folders = await _driveApi!.files.list(
      q: "mimeType = 'application/vnd.google-apps.folder' and trashed = false",
      spaces: 'drive',
    );

    if (folders.files == null) return [];

    final scans = <DriveScan>[];

    for (final folder in folders.files!) {
      final folderId = folder.id!;

      // 2. Find meta.json inside folder
      final metaResult = await _driveApi!.files.list(
        q: "'$folderId' in parents and name = 'meta.json' and trashed = false",
        spaces: 'drive',
      );

      if (metaResult.files == null || metaResult.files!.isEmpty) continue;

      final metaFile = metaResult.files!.first;

      // 3. Download meta.json
      final media = await _driveApi!.files.get(
        metaFile.id!,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final content = await media.stream.transform(utf8.decoder).join();
      final meta = ScanMeta.fromJson(jsonDecode(content));

      scans.add(
        DriveScan(
          folderId: folderId,
          meta: meta,
        ),
      );
    }

    // newest → oldest
    scans.sort((a, b) => b.meta.createdAt.compareTo(a.meta.createdAt));
    return scans;
  }

  Future<Directory> downloadScanFolder({
    required String folderId,
    required String folderName,
  }) async {
    if (_driveApi == null) {
      throw Exception('Drive API not initialized');
    }

    final tempDir = await getTemporaryDirectory();
    final scanDir = Directory('${tempDir.path}/$folderName');

    if (!await scanDir.exists()) {
      await scanDir.create(recursive: true);
    }

    // List all files inside the Drive folder
    final result = await _driveApi!.files.list(
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

      final media = await _driveApi!.files.get(
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
}


class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();
  _GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }

}