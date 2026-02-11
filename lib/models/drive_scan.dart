import 'package:googleapis/drive/v3.dart' as drive;
import 'scan_meta.dart';

class DriveScan {
  final String folderId;
  final ScanMeta meta;

  DriveScan({
    required this.folderId,
    required this.meta,
  });
}