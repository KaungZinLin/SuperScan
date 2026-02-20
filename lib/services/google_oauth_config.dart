import 'dart:io';
import 'package:flutter/foundation.dart';

class GoogleOAuthConfig {
  GoogleOAuthConfig._();

  static const webClientId =
      '345114505131-apvjsl69dognfrhghpni6mbeb57v22d1.apps.googleusercontent.com';

  static String? get serverClientId {
    if (kIsWeb) return webClientId;

    if (Platform.isAndroid ||
        Platform.isWindows ||
        Platform.isLinux) {
      return webClientId;
    }

    return null;
  }
}