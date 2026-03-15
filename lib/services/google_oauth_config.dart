import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GoogleOAuthConfig {
  GoogleOAuthConfig._();

  // We read from the .env file instead of hardcoding
  static String get clientId => dotenv.env['GOOGLE_CLIENT_ID'] ?? 'YOUR_CLIENT_ID_HERE';

  static String get clientSecret => dotenv.env['GOOGLE_CLIENT_SECRET'] ?? 'YOUR_CLIENT_SECRET_HERE';

  static bool get isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);
}