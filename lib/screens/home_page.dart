import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  dynamic _scannedDocuments;

  /// Helper to handle the scanner calls and catch platform errors
  Future<void> _processScan(Future<dynamic> scanTask) async {
    dynamic result;
    try {
      result = await scanTask ?? 'No documents returned';
    } on PlatformException {
      result = 'Failed to get scanned documents.';
    }

    if (!mounted) return;
    setState(() {
      _scannedDocuments = result;
    });
  }

  // Desktop check
  bool get isDesktop {
    if (kIsWeb) return false;
    return Platform.isMacOS || Platform.isWindows || Platform.isLinux;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        // Removed elevation from floating action button
        elevation: 0.0,
        child: Icon(Icons.document_scanner),
        onPressed: () {
          // Added desktop check and prevented users from scanning if they're on desktop
          if (isDesktop) {
            Alert(
              context: context,
              type: AlertType.warning,
              title: 'Scanning Not Available',
              desc: 'Scanning documents is not available on desktop versions of SuperScan',
              style: AlertStyle(
              isCloseButton: true,
              isOverlayTapDismiss: true,
              alertBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
                side: BorderSide(
                  color: Colors.indigo,
                ),
              ),
              // Fix the Title Color
              titleStyle: TextStyle(
                // 2. Explicitly toggle color based on brightness
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                fontWeight: FontWeight.bold,
              ),
              descStyle: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.black87,
              ),
            ),
              buttons: [
                DialogButton(
                  color: Colors.indigo,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK', style: TextStyle(color: Colors.white)),
                ),
              ],
            ).show();
          } else {
            Alert(
              context: context,
              type: AlertType.info,
              title: 'Scan Options',
              desc: 'Choose your preferred scanning format',
              // Set custom broder radius and color
              style: AlertStyle(
                isCloseButton: true,
                isOverlayTapDismiss: true,
                alertBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  side: BorderSide(
                    color: Colors.indigo,
                  ),
                ),
                // Fix the Title Color
                titleStyle: TextStyle(
                  // 2. Explicitly toggle color based on brightness
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                descStyle: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.black87,
                ),
              ),
              // Removed URI scanning and default "Image" scanning
              buttons: [
                DialogButton(
                  color: Colors.indigo,
                  onPressed: () {
                    Navigator.pop(context);
                    _processScan(FlutterDocScanner().getScannedDocumentAsImages(page: 4));
                  },
                  child: const Text('Image', style: TextStyle(color: Colors.white)),
                ),
                DialogButton(
                  color: Colors.indigo,
                  onPressed: () {
                    Navigator.pop(context);
                    _processScan(FlutterDocScanner().getScannedDocumentAsPdf(page: 4));
                  },
                  child: const Text('PDF', style: TextStyle(color: Colors.white)),
                ),
              ],
            ).show();
          }
        },
      ),
      // Changed appBar name to Sync on desktop
      appBar: AppBar(
        title: Text(isDesktop ? 'Sync' : 'Home'),
          // Added sync button and marked as Work In Progress
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.sync),
              onPressed: () {
                Alert(
                  context: context,
                  type: AlertType.warning,
                  title: 'Work in Progress',
                  desc: 'SuperScan does not support Sync yet',
                  style: AlertStyle(
                    isCloseButton: true,
                    isOverlayTapDismiss: true,
                    alertBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      side: BorderSide(
                        color: Colors.indigo,
                      ),
                    ),
                    // Fix the Title Color
                    titleStyle: TextStyle(
                      // 2. Explicitly toggle color based on brightness
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    descStyle: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.black87,
                    ),
                  ),
                  buttons: [
                    DialogButton(
                      color: Colors.indigo,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('OK', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ).show();
              },
            ),
          ]
      ),

      body: SafeArea(
        child: Column(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Different "no scans" text for different platforms
                  _scannedDocuments != null
                      ? Text(_scannedDocuments.toString())
                      : Text(isDesktop ? 'No Synced Scans Yet.' : 'No Scans Yet.'),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

            ],
          ),
        ),
      ),
    );
  }
}

// Removed URI Scanning Option as it is Android-only
// DialogButton(
//   onPressed: () {
//     Navigator.pop(context);
//     _processScan(FlutterDocScanner().getScanDocumentsUri(page: 4));
//   },
//   child: const Text('URI', style: TextStyle(color: Colors.white)),
// )

// Removed Default Scanning Option that saves as images
// DialogButton(
//   onPressed: () {
//     Navigator.pop(context);
//     _processScan(FlutterDocScanner().getScanDocuments(page: 4));
//   },
//   child: const Text('Scan', style: TextStyle(color: Colors.white)),
// ),