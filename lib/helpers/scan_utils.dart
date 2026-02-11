import 'dart:io';

class ScanUtils {
  static String scanId(Directory scanDir) {
    return scanDir.path.split(Platform.pathSeparator).last;
  }

  static DateTime lastModified(Directory scanDir) {
    DateTime latest = DateTime.fromMillisecondsSinceEpoch(0);

    for (final entity in scanDir.listSync(recursive: true)) {
      if (entity is File) {
        final m = entity.lastModifiedSync();
        if (m.isAfter(latest)) latest = m;
      }
    }
    return latest;
  }
}