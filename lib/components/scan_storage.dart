import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:super_scan/components/scan_meta.dart';

class ScanStorage {
  /// Creates a new scan folder, saves images, and writes metadata
  static Future<Directory> saveScanImages(List<String> imageUris) async {
    final appDir = await getApplicationDocumentsDirectory();
    final scansDir = Directory('${appDir.path}/scans');

    if (!await scansDir.exists()) {
      await scansDir.create(recursive: true);
    }


    String _defaultScanName() {
      final now = DateTime.now();
      return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    }

    // Use timestamp ONLY for internal folder identity
    final now = DateTime.now();
    final scanDir = Directory(
      '${scansDir.path}/scan_${now.millisecondsSinceEpoch}',
    );

    await scanDir.create();

    // Copy scanned images
    for (int i = 0; i < imageUris.length; i++) {
      final source = File(imageUris[i]);
      final target = File('${scanDir.path}/${_pageName(i + 1)}');
      await source.copy(target.path);
    }

    // Human-readable default name (for UI only)
    final displayName =
        '${now.year}-${_two(now.month)}-${_two(now.day)} '
        '${_two(now.hour)}:${_two(now.minute)}';

    // Save metadata
    // final metaFile = File('${scanDir.path}/meta.json');
    // await metaFile.writeAsString(
    //   jsonEncode({
    //     'name': displayName,
    //     'createdAt': now.millisecondsSinceEpoch,
    //   }),
    // );
    final meta = ScanMeta(
      name: _defaultScanName(),
      createdAt: DateTime.now(),
    );

    final metaFile = File('${scanDir.path}/meta.json');
    await metaFile.writeAsString(jsonEncode(meta.toJson()));



    return scanDir;
  }

  static String _pageName(int index) {
    return 'page_${index.toString().padLeft(3, '0')}.jpg';
  }

  static Future<void> deleteScan(Directory scanDir) async {
    if (await scanDir.exists()) {
      await scanDir.delete(recursive: true);
    }
  }

  static Future<void> renameScan({
    required Directory scanDir,
    required String newName,
  }) async {
    final metaFile = File('${scanDir.path}/meta.json');

    if (!metaFile.existsSync()) {
      throw Exception('meta.json not found');
    }

    final json = jsonDecode(await metaFile.readAsString());
    final meta = ScanMeta.fromJson(json);

    final updatedMeta = ScanMeta(
      name: newName,
      createdAt: meta.createdAt, // keep original date
    );

    await metaFile.writeAsString(
      jsonEncode(updatedMeta.toJson()),
    );
  }

  static String _two(int n) => n.toString().padLeft(2, '0');

  static Future<File> generatePdf(Directory scanDir, {required String fileName}) async {
    final pdf = pw.Document();

    // Get all images sorted by filename
    final images = scanDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.jpg'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    for (final imgFile in images) {
      final imageBytes = await imgFile.readAsBytes();
      final image = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(child: pw.Image(image));
          },
        ),
      );
    }

    // Create a temporary file with the user-chosen name
    final tempDir = await getTemporaryDirectory();
    final safeFileName = fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_'); // replace illegal characters
    final pdfFile = File('${tempDir.path}/$safeFileName.pdf');

    await pdfFile.writeAsBytes(await pdf.save());
    return pdfFile;
  }

  /// Returns all image files in the scan folder as List<File>
  static Future<List<File>> getScanImages(Directory scanDir) async {
    final files = scanDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.jpg'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    return files;
  }

  static Future<void> removePage({
    required Directory scanDir,
    required int pageIndex, // 0-based index
  }) async {
    final images = scanDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.jpg'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    if (pageIndex < 0 || pageIndex >= images.length) {
      throw RangeError('Invalid page index');
    }

    // Delete the selected page
    await images[pageIndex].delete();

    // Re-number remaining pages
    final remaining = scanDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.jpg'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    for (int i = 0; i < remaining.length; i++) {
      final newPath = '${scanDir.path}/${_pageName(i + 1)}';

      if (remaining[i].path != newPath) {
        await remaining[i].rename(newPath);
      }
    }
  }

  static Future<void> removePageByFile({
    required File imageFile,
  }) async {
    if (!await imageFile.exists()) return;

    await imageFile.delete();
  }

  static Future<void> appendPages({
    required Directory scanDir,
    required List<String> imageUris,
  }) async {
    if (imageUris.isEmpty) return;

    // Get existing pages
    final existingImages = scanDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.jpg'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    int startIndex = existingImages.length;

    for (int i = 0; i < imageUris.length; i++) {
      final source = File(imageUris[i]);
      final target = File(
          '${scanDir.path}/${_pageName(startIndex + i + 1)}'
      );

      await source.copy(target.path);
    }
  }

  static Future<void> reorderPages(
      Directory scanDir,
      List<File> orderedFiles,
      ) async {
    final dirPath = scanDir.path;

    // Step 1: temp rename (prevents overwrite)
    for (int i = 0; i < orderedFiles.length; i++) {
      final tempFile = File('$dirPath/_tmp_$i.jpg');
      orderedFiles[i] = await orderedFiles[i].rename(tempFile.path);
    }

    // Step 2: final rename
    for (int i = 0; i < orderedFiles.length; i++) {
      final finalFile = File('$dirPath/page_${i + 1}.jpg');
      orderedFiles[i] = await orderedFiles[i].rename(finalFile.path);
    }
  }
}