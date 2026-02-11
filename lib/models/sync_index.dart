import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class SyncIndex {
  static const _fileName = 'sync_index.json';

  static Future<Map<String, int>> load() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_fileName');

    if (!file.existsSync()) return {};
    return Map<String, int>.from(jsonDecode(await file.readAsString()));
  }

  static Future<void> save(Map<String, int> index) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_fileName');
    await file.writeAsString(jsonEncode(index));
  }
}