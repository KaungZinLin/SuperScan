import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class PlatformHelper {
  // Check if the app is running on the Web
  static bool get isWeb => kIsWeb;

  // Check for Desktop Platforms
  static bool get isDesktop {
    if (isWeb) return false;
    return Platform.isMacOS || Platform.isWindows || Platform.isLinux;
  }

  // Check for Mobile Platforms
  static bool get isMobile {
    if (isWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }
}