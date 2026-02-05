import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ScanStorage {
  /// Creates a new scan folder and copies images into it
  static Future<Directory> saveScanImages(List<String> imageUris) async {
    final appDir = await getApplicationDocumentsDirectory();
    final scansDir = Directory('${appDir.path}/scans');

    if (!await scansDir.exists()) {
      await scansDir.create(recursive: true);
    }

    final scanDir = Directory(
      '${scansDir.path}/scan_${DateTime.now().millisecondsSinceEpoch}',
    );

    await scanDir.create();

    for (int i = 0; i < imageUris.length; i++) {
      final source = File(imageUris[i]);
      final target = File('${scanDir.path}/page_${i + 1}.jpg');
      await source.copy(target.path);
    }

    return scanDir;
  }
}