import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter/foundation.dart';
import 'package:super_scan/components/platform_helper.dart';
import 'package:super_scan/constants.dart';
import 'dart:io';
import 'package:super_scan/components/scan_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:super_scan/widgets/no_scans_widgets.dart';
import 'scan_viewer_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  dynamic _scannedDocuments;
  List<Directory> _savedScans = [];

  /// Helper to handle the scanner calls and catch platform errors
  Future<void> _processScan(Future<dynamic> scanTask) async {
    try {
      final result = await scanTask;

      List<String> images = [];

      if (result is Map) {
        if (result['images'] != null) {
          images = List<String>.from(result['images']);
        } else if (result['Uri'] != null) {
          // iOS legacy keys
          images = List<String>.from(result['Uri']);
        }
      } else if (result is List) {
        // Some iOS versions return List<String>
        images = List<String>.from(result);
      }

      if (images.isEmpty) {
        if (!mounted) return;
        setState(() {
          _scannedDocuments = 'No images returned.';
        });
        return;
      }

      final scanDir = await ScanStorage.saveScanImages(images);

      if (!mounted) return;
      setState(() {
        _scannedDocuments = 'Scan saved to:\n${scanDir.path}';
      });
    } on PlatformException catch (e) {
      debugPrint('Scan error: $e');
      if (!mounted) return;
      setState(() {
        _scannedDocuments = 'Failed to scan document.';
      });
    }

    await _loadSavedScans();
  }

  Future<void> _loadSavedScans() async {
    final dir = await getApplicationDocumentsDirectory();
    final scansDir = Directory('${dir.path}/scans');

    if (!await scansDir.exists()) {
      setState(() {
        _savedScans = [];
      });
      return;
    }

    final scanFolders = scansDir
        .listSync()
        .whereType<Directory>()
        .toList();

    // Sort newest first
    scanFolders.sort(
          (a, b) => b.path.compareTo(a.path),
    );

    setState(() {
      _savedScans = scanFolders;
    });
  }

  void _openScanViewer(Directory scanDir) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScanViewerScreen(scanDir: scanDir),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadSavedScans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Completely removed FAB on desktop
      floatingActionButton: PlatformHelper.isDesktop ? null :
      FloatingActionButton.extended(
        // Removed elevation from floating action button
        elevation: 0.0,
        icon: Icon(Icons.document_scanner, size: 35.0),
        label: Text('Scan'),
        onPressed: () {
          _processScan(FlutterDocScanner().getScannedDocumentAsImages(
              page: 4));
        },
      ),
      // Changed appBar name to Sync on desktop
      appBar: AppBar(
          title: Text(PlatformHelper.isDesktop ? 'Sync' : 'Home'),
          // Added sync button and marked as Work In Progress
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.cloud_sync, color: kAccentColor,),
              onPressed: () {
                Alert(
                  context: context,
                  type: AlertType.warning,
                  title: 'Coming soon...',
                  desc: 'SuperScan does not support Sync yet',
                  style: AlertStyle(
                    isCloseButton: true,
                    isOverlayTapDismiss: true,
                    alertBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      side: BorderSide(
                        color: kAccentColor,
                      ),
                    ),
                    // Fix the Title Color
                    titleStyle: TextStyle(
                      // 2. Explicitly toggle color based on brightness
                      color: Theme
                          .of(context)
                          .brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    descStyle: TextStyle(
                      color: Theme
                          .of(context)
                          .brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.black87,
                    ),
                  ),
                  buttons: [
                    DialogButton(
                      color: kAccentColor,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('OK', style: TextStyle(color: Colors
                          .white)),
                    ),
                  ],
                ).show();
              },
            ),
          ]
      ),

        body: SafeArea(
          child: _savedScans.isEmpty
              ? EmptyScansPlaceholder()
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _savedScans.length,
            itemBuilder: (context, index) {
              final scanDir = _savedScans[index];

              final pages = scanDir
                  .listSync()
                  .whereType<File>()
                  .where((f) => f.path.endsWith('.jpg'))
                  .length;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: const Icon(Icons.document_scanner),
                  title: Text('Scan ${index + 1}'),
                  subtitle: Text('$pages page(s)'),
                  onTap: () {
                    _openScanViewer(scanDir);
                  },
                ),
              );
            },
          ),
        ),
    );
  }
}