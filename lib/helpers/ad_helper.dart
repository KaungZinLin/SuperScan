import 'dart:io';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2739815774817666/3187304336';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-2739815774817666/7226158673';
    } else {
      throw UnsupportedError('message');
    }
  }
}