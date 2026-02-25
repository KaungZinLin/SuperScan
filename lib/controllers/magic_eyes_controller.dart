import 'dart:io';
import 'package:flutter/material.dart';
import '../services/ocr_service.dart';
import 'package:super_scan/services/scan_storage.dart';
import 'package:super_scan/services/ai_service.dart';

class MagicEyesController extends ChangeNotifier {
  bool isProcessing = false;
  String extractedText = "";

  int progressCurrent = 0;
  int progressTotal = 0;

  // AI State
  String summaryText = "";
  bool isSummarizing = false;

  // Proofread
  String proofreadResultText = "";
  bool isProofreading = false;

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

  Future<String> runOCRforChat(Directory scanDir) async {
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

    return extractedText; // <--- return it
  }

  // Summarize
  Future<void> summarizeFromScan(Directory scanDir) async {
    if (isSummarizing) return;

    isSummarizing = true;
    summaryText = "";
    notifyListeners();

    try {
      // Redo OCR
      await runOCR(scanDir);

      if (extractedText.trim().isEmpty) {
        summaryText = "No text detected.";
        isSummarizing = false;
        notifyListeners();
        return;
      }

      // Stram AI Summary
      await AIService.instance.streamSummary(
        extractedText,
        onChunk: (chunk) {
          summaryText += chunk;
          notifyListeners();
        },
      );
    } catch (e) {
      summaryText = "Failed to generate summary.";
    }

    isSummarizing = false;
    notifyListeners();
  }

  // Proofread
  Future<void> proofreadFromScan(Directory scanDir) async {
    if (isProofreading) return;

    isProofreading = true;
    proofreadResultText = "";
    notifyListeners();

    try {
      // Redo OCR
      await runOCR(scanDir);

      if (extractedText.trim().isEmpty) {
        proofreadResultText = "No text detected.";
        isProofreading = false;
        notifyListeners();
        return;
      }

      // Stram AI Summary
      await AIService.instance.streamProofread(
        extractedText,
        onChunk: (chunk) {
          proofreadResultText += chunk;
          notifyListeners();
        },
      );
    } catch (e) {
      proofreadResultText = "Failed to get proofread results.";
    }

    isProofreading = false;
    notifyListeners();
  }
}
