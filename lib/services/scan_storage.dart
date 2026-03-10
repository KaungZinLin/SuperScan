import 'dart:io';
import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:super_scan/models/scan_meta.dart';

class ScanStorage {
  // Future-proof helper
  // This converts URI (returned from MLKit) -> valid file path expected by Flutter
  // Safe for iOS as it does nothing here
  static String _normalizePath(String uri) {
    final parsed = Uri.parse(uri);

    if (parsed.scheme == 'file') {
      return parsed.toFilePath();
    }

    return uri;
  }

  // Creates a new scan folder, saves images, and writes metadata
  static Future<Directory> saveScanImages(List<String> imageUris) async {
    final appDir = await getApplicationDocumentsDirectory();
    final scansDir = Directory('${appDir.path}/scans');

    if (!await scansDir.exists()) {
      await scansDir.create(recursive: true);
    }

    String defaultScanName() {
      final now = DateTime.now();
      return 'Scan ${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
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
      // file URIs on Android but plain paths on iOS.
      final normalizedPath = _normalizePath(imageUris[i]);

      final source = File(normalizedPath);
      final target = File('${scanDir.path}/${_pageName(i + 1)}');

      // Extra safety check before copying to permanent storage
      if (await source.exists()) {
        await source.copy(target.path);
      } else {
        debugPrint('Scan image missing: $normalizedPath');
      }
    }

    final meta = ScanMeta(name: defaultScanName(), createdAt: DateTime.now());

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

    await metaFile.writeAsString(jsonEncode(updatedMeta.toJson()));
  }

  // static String _two(int n) => n.toString().padLeft(2, '0');

  static Future<File> generatePdf(
    Directory scanDir, {
    required String fileName,
  }) async {
    final pdf = pw.Document();

    // Get all images sorted by filename
    final images =
        scanDir
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
    final safeFileName = fileName.replaceAll(
      RegExp(r'[\\/:*?"<>|]'),
      '_',
    ); // replace illegal characters
    final pdfFile = File('${tempDir.path}/$safeFileName.pdf');

    await pdfFile.writeAsBytes(await pdf.save());
    return pdfFile;
  }

  // Returns all image files in the scan folder as List of File
  static Future<List<File>> getScanImages(Directory scanDir) async {
    final files =
        scanDir
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
    final images =
        scanDir
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
    final remaining =
        scanDir
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

  static Future<void> removePageByFile({required File imageFile}) async {
    if (!await imageFile.exists()) return;

    await imageFile.delete();
  }

  // AI generated
  static Future<void> appendPages({
    required Directory scanDir,
    required List<String> imageUris,
  }) async {
    // 1Get existing pages
    final files = scanDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.jpg'))
        .toList();

    // Find highest page index
    int nextIndex = 1;

    final regex = RegExp(r'page_(\d+)\.jpg');

    for (final file in files) {
      final name = file.uri.pathSegments.last;
      final match = regex.firstMatch(name);

      if (match != null) {
        final index = int.parse(match.group(1)!);
        if (index >= nextIndex) {
          nextIndex = index + 1;
        }
      }
    }

    // 3️⃣ Append new pages
    for (final uri in imageUris) {
      final normalizedPath = _normalizePath(uri);

      final source = File(normalizedPath);
      final target = File('${scanDir.path}/${_pageName(nextIndex)}');

      if (await source.exists()) {
        await source.copy(target.path);
        nextIndex++; // IMPORTANT
      } else {
        debugPrint('Append page missing: $normalizedPath');
      }
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
