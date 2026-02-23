import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  OCRService._();
  static final OCRService instance = OCRService._();

  final TextRecognizer _recognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  // Extract text from one image
  Future<String> extractImage(File file) async {
    final inputImage = InputImage.fromFile(file);
    final result = await _recognizer.processImage(inputImage);
    return result.text;
  }

  // Extract text from MULTIPLE images (async sequential)
  Future<String> extractBatch(
    List<File> images, {
    void Function(int current, int total)? onProgress,
  }) async {
    final buffer = StringBuffer();

    for (int i = 0; i < images.length; i++) {
      final text = await extractImage(images[i]);

      buffer.writeln(text);
      buffer.writeln("\n--- PAGE ${i + 1} ---\n");

      onProgress?.call(i + 1, images.length);

      // tiny yield → prevents UI starvation
      await Future.delayed(const Duration(milliseconds: 10));
    }

    return buffer.toString();
  }

  void dispose() {
    _recognizer.close();
  }
}