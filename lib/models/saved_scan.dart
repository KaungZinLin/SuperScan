import 'dart:io';
import 'scan_meta.dart';

class SavedScan {
  final Directory dir;
  final ScanMeta meta;

  SavedScan({
    required this.dir,
    required this.meta,
  });
}