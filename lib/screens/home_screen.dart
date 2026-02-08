import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:super_scan/components/action_button.dart';
import 'package:super_scan/components/expandable_fab.dart';
import 'package:super_scan/components/platform_helper.dart';
import 'package:super_scan/components/saved_scan.dart';
import 'package:super_scan/components/scan_meta.dart';
import 'package:super_scan/constants.dart';
import 'dart:io';
import 'package:super_scan/components/scan_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:super_scan/widgets/no_scans_widgets.dart';
import 'scan_viewer_screen.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:super_scan/components/scan_search_delegate.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  dynamic _scannedDocuments;
  // List<Directory> _savedScans = [];
  List<SavedScan> _savedScans = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<SavedScan> get _filteredScans {
    if (_searchQuery.isEmpty) return _savedScans;

    final query = _searchQuery.toLowerCase();

    return _savedScans.where((scan) {
      final name = scan.meta.name.toLowerCase();
      return name.contains(query);
    }).toList();
  }

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
      setState(() => _savedScans = []);
      return;
    }

    final folders = scansDir.listSync().whereType<Directory>();

    final scans = <SavedScan>[];

    for (final folder in folders) {
      final metaFile = File('${folder.path}/meta.json');
      if (!metaFile.existsSync()) continue;

      final metaJson = jsonDecode(metaFile.readAsStringSync());
      scans.add(
        SavedScan(
          dir: folder,
          meta: ScanMeta.fromJson(metaJson),
        ),
      );
    }

    // Sort newest → oldest
    scans.sort((a, b) => b.meta.createdAt.compareTo(a.meta.createdAt));

    setState(() {
      _savedScans = scans;
    });
  }

  Future<void> _renameScan(SavedScan scan) async {
    final controller = TextEditingController(text: scan.meta.name);

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename scan', style: kTextLetterSpacing,),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Scan Name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: kTextLetterSpacing,),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, controller.text.trim()),
              child: const Text('Save', style: TextStyle(fontWeight: .bold, letterSpacing: 0.0)),
            ),
          ],
        );
      },
    );


    if (result == null || result.isEmpty) return;

    await ScanStorage.renameScan(
      scanDir: scan.dir,
      newName: result,
    );

    await _loadSavedScans();
    // Use ScaffoldMessenger to show the snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Renamed successfully', style: kTextLetterSpacing,),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _showScanOptions(SavedScan scan) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Options for “${scan.meta.name}”', style: kTextLetterSpacing,),
          content: const Text('What would you like to do?', style: kTextLetterSpacing,),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                style: kTextLetterSpacing,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _renameScan(scan);
              },
              child: const Text('Rename', style: TextStyle(
                  letterSpacing: 0.0,
                  fontWeight: .bold
              )),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteScan(scan);
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                    letterSpacing: 0.0,
                    fontWeight: .bold
                ),
              ),
            ),

          ],
        );
      },
    );
  }

  Future<void> _deleteScan(SavedScan scan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete scan?', style: kTextLetterSpacing,),
          content: Text(
            '“${scan.meta.name}” will be permanently deleted.',
            style: kTextLetterSpacing,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel', style: kTextLetterSpacing,),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete', style: TextStyle(fontWeight: .bold, letterSpacing: 0.0)),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await ScanStorage.deleteScan(scan.dir);
    await _loadSavedScans();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Deleted permanently', style: kTextLetterSpacing,),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openScanViewer(Directory scanDir) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ScanViewerScreen(scanDir: scanDir),
      ),
    );

    await _loadSavedScans();
  }

  Future<void> _importImages() async {
    try {
      final picker = ImagePicker();

      final images = await picker.pickMultiImage(
        imageQuality: 100,
      );

      if (images.isEmpty) return;

      final paths = images.map((e) => e.path).toList();

      final scanDir = await ScanStorage.saveScanImages(paths);

      if (!mounted) return;

      await _loadSavedScans();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Imported images successfully', style: kTextLetterSpacing,),
            behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to improt images: $e', style: kTextLetterSpacing,),
            behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat.yMd().add_jm().format(date);
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
          ExpandableFab(
            children: [
              ActionButton(
                icon: Icon(Icons.photo_library, color: Colors.white,),
                onPressed: () {
                  _importImages();
                },
              ),
              ActionButton(
                icon: Icon(Icons.camera_alt, color: Colors.white,),
                onPressed: () {
                  _processScan(FlutterDocScanner().getScannedDocumentAsImages(
                      page: 4));
                },
              ),
            ],
            distance: 20,
          ),
      // Changed appBar name to Sync on desktop
      appBar: AppBar(
        centerTitle: true,
        title: Text('Home', style: kTextLetterSpacing,),
        leading: IconButton(
          icon: Icon(Icons.cloud_sync, color: kAccentColor),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: kAccentColor,),
            onPressed: () => showSearch(
              context: context,
              delegate: ScanSearchDelegate(_savedScans),
            ),
          ),
        ],
      ),

        body: SafeArea(
          child: _filteredScans.isEmpty
              ? EmptyScansPlaceholder()
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredScans.length,
            itemBuilder: (context, index) {
              final savedScan = _filteredScans[index];
              final scanDir = savedScan.dir;
              final meta = savedScan.meta;

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
                elevation: 0.0,
                color: kAccentColor.withAlpha(20),
                child: ListTile(
                  // leading: const Icon(Icons.document_scanner),
                  trailing: const Icon(Icons.chevron_right),
                  title: Text(meta.name, style: kTextLetterSpacing,),
                  subtitle: Text(
                    '$pages page(s) • ${_formatDate(meta.createdAt)}',
                    style: kTextLetterSpacing,
                  ),
                  onLongPress: () => _showScanOptions(savedScan),
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