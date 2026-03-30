import 'package:flutter/foundation.dart';
import 'dart:io';

class GoogleOAuthConfig {
  GoogleOAuthConfig._();

  static const clientId =
      '345114505131-apvjsl69dognfrhghpni6mbeb57v22d1.apps.googleusercontent.com';

  // 345114505131-apvjsl69dognfrhghpni6mbeb57v22d1.apps.googleusercontent.com

  // Only used on desktop platforms
  static const clientSecret = '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';

  static bool get isDesktop =>
      !kIsWeb &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS);
}