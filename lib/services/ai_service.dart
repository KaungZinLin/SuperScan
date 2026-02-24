import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:super_scan/helpers/api_key_storage.dart';
import 'package:super_scan/helpers/api_key_storage.dart';

class AIService {
  AIService._();
  static final AIService instance = AIService._();

  static const String _endpoint = "https://api.openai.com/v1/chat/completions";

  // Chunk text
  List<String> _chunkText(String text, {int maxChars = 6000}) {
    final chunks = <String>[];

    int start = 0;
    while (start < text.length) {
      int end = start + maxChars;
      if (end > text.length) end = text.length;

      chunks.add(text.substring(start, end));
      start = end;
    }

    return chunks;
  }

  // Stream summary
  Future<void> streamSummary(
    String text, {
    required void Function(String chunk) onChunk,
  }) async {
    final chunks = _chunkText(text);

    for (int i = 0; i < chunks.length; i++) {
      final result = await _summarizeChunk(chunks[i], i + 1, chunks.length);

      // gradual UI streaming
      final words = result.split(" ");

      for (final word in words) {
        onChunk("$word ");
        await Future.delayed(const Duration(milliseconds: 20));
      }
    }
  }

  // Summarize single chunk
  Future<String> _summarizeChunk(String chunk, int index, int total) async {
    final _apiKey =
        await ApiKeyStorage.loadApiKey(); // Get API key from storage
    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_apiKey",
      },
      body: jsonEncode({
        "model": "gpt-4o-mini",
        "messages": [
          {
            "role": "system",
            "content": "You summarize scanned documents clearly and concisely.",
          },
          {
            "role": "user",
            "content":
                "Summarize this document part ($index/$total):\n\n$chunk",
          },
        ],
        "temperature": 0.3,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("AI request failed: ${response.body}");
    }

    final data = jsonDecode(response.body);

    return data["choices"][0]["message"]["content"];
  }

  // Stream proofread
  Future<void> streamProofread(
    String text, {
    required void Function(String chunk) onChunk,
  }) async {
    final chunks = _chunkText(text);

    for (int i = 0; i < chunks.length; i++) {
      final result = await _proofreadChunk(chunks[i], i + 1, chunks.length);

      // gradual UI streaming
      final words = result.split(" ");

      for (final word in words) {
        onChunk("$word ");
        await Future.delayed(const Duration(milliseconds: 20));
      }
    }
  }

  // Summarize single chunk
  Future<String> _proofreadChunk(String chunk, int index, int total) async {
    final _apiKey =
        await ApiKeyStorage.loadApiKey(); // Get API key from storage
    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_apiKey",
      },
      body: jsonEncode({
        "model": "gpt-4o-mini",
        "messages": [
          {
            "role": "system",
            "content":
                "You proofread scanned documents clearly and concisely. Check if any info is wrong and point out the mistakes. The info is from OCR so expect typos.",
          },
          {
            "role": "user",
            "content":
                "Proofread this document part ($index/$total):\n\n$chunk",
          },
        ],
        "temperature": 0.3,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("AI request failed: ${response.body}");
    }

    final data = jsonDecode(response.body);

    return data["choices"][0]["message"]["content"];
  }
}
