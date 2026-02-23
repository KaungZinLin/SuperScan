import 'dart:io';
import 'package:flutter/material.dart';
import '../services/ocr_service.dart';
import 'package:super_scan/services/scan_storage.dart';

class MagicEyesController extends ChangeNotifier {
  bool isProcessing = false;
  String extractedText = "";

  int progressCurrent = 0;
  int progressTotal = 0;

  // Load scan images
  Future<List<File>> loadImages(Directory scanDir) async {
    final files = await ScanStorage.getScanImages(scanDir);

    debugPrint("MagicEyes: found ${files.length} pages");

    return files;
  }

  // Run OCR
  Future<void> runOCR(Directory scanDir) async {
    if (isProcessing) return;

    isProcessing = true;
    extractedText = "";
    progressCurrent = 0;
    notifyListeners();

    final images = await loadImages(scanDir);

    extractedText = await OCRService.instance.extractBatch(
      images,
      onProgress: (current, total) {
        progressCurrent = current;
        progressTotal = total;
        notifyListeners();
      },
    );

    isProcessing = false;
    notifyListeners();
  }
}