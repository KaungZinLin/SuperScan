import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class PlatformHelper {
  static bool get isWeb => kIsWeb;

  static bool get isDesktop {
    if (isWeb) return false;
    return Platform.isMacOS || Platform.isWindows || Platform.isLinux;
  }

  static bool get isMobile {
    if (isWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }
}