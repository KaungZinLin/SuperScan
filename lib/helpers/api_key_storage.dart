import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_scan/constants.dart';

class ApiKeyStorage {
  static const _keyName = 'openai_api_key';

  // Save the API key
  static Future<void> saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, apiKey);
  }

  static Future<String?> loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.get(_keyName);
    return prefs.getString(_keyName);
  }

  static Future<void> deleteApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyName);
  }
}
