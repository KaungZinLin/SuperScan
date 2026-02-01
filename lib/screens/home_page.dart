import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.document_scanner),
        onPressed: () {
          Alert(
            context: context,
            type: AlertType.none,
            title: 'Scan Options',
            desc: 'Choose your preferred scanning format',
            style: const AlertStyle(
              isCloseButton: true,
              isOverlayTapDismiss: true,
            ),
            buttons: [
              DialogButton(
                onPressed: () {
                  Navigator.pop(context);
                  _processScan(FlutterDocScanner().getScanDocuments(page: 4));
                },
                child: const Text('Scan', style: TextStyle(color: Colors.white)),
              ),
              DialogButton(
                onPressed: () {
                  Navigator.pop(context);
                  _processScan(FlutterDocScanner().getScannedDocumentAsImages(page: 4));
                },
                child: const Text('Image', style: TextStyle(color: Colors.white)),
              ),
              DialogButton(
                onPressed: () {
                  Navigator.pop(context);
                  _processScan(FlutterDocScanner().getScannedDocumentAsPdf(page: 4));
                },
                child: const Text('PDF', style: TextStyle(color: Colors.white)),
              ),
              DialogButton(
                onPressed: () {
                  Navigator.pop(context);
                  _processScan(FlutterDocScanner().getScanDocumentsUri(page: 4));
                },
                child: const Text('URI', style: TextStyle(color: Colors.white)),
              )
            ],
          ).show();
        },
      ),
      appBar: AppBar(
        title: const Text('Home'),
      ),

      body: SafeArea(
        child: Column(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _scannedDocuments != null
                      ? Text(_scannedDocuments.toString())
                      : const Text("No Documents Scanned"),
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