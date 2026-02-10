import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:super_scan/components/platform_helper.dart';
import 'package:super_scan/constants.dart';
import 'package:super_scan/components/scan_meta.dart';
import 'package:super_scan/components/scan_storage.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'reorder_pages_page.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:super_scan/components/sync_controller.dart';

class ScanViewerScreen extends StatefulWidget {
  final Directory scanDir;

  const ScanViewerScreen({
    super.key,
    required this.scanDir,
  });

  @override
  State<ScanViewerScreen> createState() => _ScanViewerScreenState();
}

class _ScanViewerScreenState extends State<ScanViewerScreen> {
  late ScanMeta _meta;
  late List<File> _images;
  bool _loading = false;


  @override
  void initState() {
    super.initState();
    _loadMeta();
    _loadImages();
  }

  void _loadMeta() {
    final metaFile = File('${widget.scanDir.path}/meta.json');
    final json = jsonDecode(metaFile.readAsStringSync());
    _meta = ScanMeta.fromJson(json);
  }

  void _loadImages() {
    _images = widget.scanDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.jpg'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_meta.name, style: kTextLetterSpacing),
      ),
      body: Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _images.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GestureDetector(
                    // 1. Use onLongPressStart to get the tap coordinates
                    onLongPressStart: PlatformHelper.isDesktop
                        ? null
                        : (details) => _showContextMenu(context, details.globalPosition, index),
                    child: Image.file(
                      _images[index],
                      key: ValueKey(_images[index].lastModifiedSync().millisecondsSinceEpoch),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              );
            },
          ),
          if (_loading)
            Container(
              color: Colors.black45, // semi-transparent overlay
              child: const Center(
                child: SpinKitDualRing(color: kAccentColor,),
              )
            ),
        ]
      ),

      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(
              onTap: PlatformHelper.isDesktop ? null : () => showAddMorePagesDialog(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add,
                    color: PlatformHelper.isDesktop ? Colors.grey : kAccentColor,
                  ),
                  Text(
                    "Add",
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 0.0,
                      color: PlatformHelper.isDesktop ? Colors.grey : kAccentColor // or your default color
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {

              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.remove_red_eye, color: kAccentColor),
                  Text("MagicEyes", style: TextStyle(fontSize: 12, letterSpacing: 0.0, color: kAccentColor)),
                ],
              ),
            ),
            InkWell(
              onTap: () => _showExportOptions(context),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.ios_share, color: kAccentColor),
                  Text("Share", style: TextStyle(fontSize: 12, letterSpacing: 0.0, color: kAccentColor)),
                ],
              ),
            ),
            InkWell(
              onTap: PlatformHelper.isDesktop ? null : () => _renameScan(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.edit,
                    color: PlatformHelper.isDesktop ? Colors.grey : kAccentColor,
                  ),
                  Text(
                    "Rename",
                    style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 0.0,
                        color: PlatformHelper.isDesktop ? Colors.grey : kAccentColor // or your default color
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                _deleteScan();
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete, color: kAccentColor),
                  Text("Delete", style: TextStyle(fontSize: 12, letterSpacing: 0.0, color: kAccentColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* ───────────────── OPTIONS ───────────────── */

  void _showContextMenu(BuildContext context, Offset tapPosition, int index) async {
    // 2. Identify where on the screen the menu should appear
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final String? selectedAction = await showMenu<String>(
      context: context,
      // Defines the "box" the menu will point toward
      position: RelativeRect.fromRect(
        Rect.fromLTWH(tapPosition.dx, tapPosition.dy, 40, 40),
        Offset.zero & overlay.size,
      ),
      items: [
        const PopupMenuItem(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.crop),
            title: Text('Crop and Rotate', style: kTextLetterSpacing,),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'reorder',
          child: ListTile(
            leading: Icon(Icons.reorder),
            title: Text('Reorder', style: kTextLetterSpacing),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete_outline, color: Colors.red),
            title: Text('Delete this Page', style: TextStyle(color: Colors.red, letterSpacing: 0.0)),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );

    // 3. Handle the result
    if (selectedAction == null) return;

    switch (selectedAction) {
      case 'edit':
        setState(() => _loading = true);
        final edited = await editScanImage(_images[index]);
        if (edited != null && mounted) {
          // Replace the File object in the list
          _images[index] = File(edited.path);

          // Evict old image from memory cache
          imageCache.evict(FileImage(_images[index]));

          setState(() {}); // triggers rebuild

          setState(() => _loading = false);
        }
        break;
      case 'delete':
        setState(() => _loading = true);
        setState(() async {
          await ScanStorage.removePageByFile(
            imageFile: _images[index],
          );

          if (!mounted) return;

          setState(() {
            _reloadImages();
          });

          setState(() => _loading = false);
        });
        break;
      case 'reorder':
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReorderPagesPage(
              scanDir: widget.scanDir,
              onReorderDone: () {
                _reloadImages(refreshUI: true); // <-- reload the parent UI immediately
              },
            ),
          ),
        );
        break;
    }
  }

  Future<void> _reloadImages({bool refreshUI = false}) async {
    // Load all JPG files from folder
    _images = widget.scanDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.jpg'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    // Clear image cache so updated files are displayed
    for (final img in _images) {
      imageCache.evict(FileImage(img));
    }

    if (refreshUI && mounted) {
      setState(() {});
    }
  }

  /* ───────────────── RENAME (NO POP) ───────────────── */

  Future<void> _renameScan() async {
    final controller = TextEditingController(text: _meta.name);

    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rename scan', style: kTextLetterSpacing),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Scan name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: kTextLetterSpacing),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, controller.text.trim()),
            child: const Text('Save', style: TextStyle(fontWeight: .bold, letterSpacing: 0.0)),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty) return;

    await ScanStorage.renameScan(
      scanDir: widget.scanDir,
      newName: result,
    );

    setState(() {
      _meta = _meta.copyWith(name: result);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Renamed successfully', style: kTextLetterSpacing,),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  /* ───────────────── DELETE (POP + REFRESH) ───────────────── */

  Future<void> _deleteScan() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete scan?', style: kTextLetterSpacing),
        content: Text(
          '“${_meta.name}” will be permanently deleted.',
          style: kTextLetterSpacing,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: kTextLetterSpacing),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(fontWeight: .bold, letterSpacing: 0.0)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ScanStorage.deleteScan(widget.scanDir);
    await SyncController.deleteScan(widget.scanDir);

    if (context.mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: PlatformHelper.isDesktop ? Text('Deleted from Google Drive', style: kTextLetterSpacing,) : Text('Deleted locally and from Google Drive', style: kTextLetterSpacing,),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showExportOptions(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Share “${_meta.name}”', style: kTextLetterSpacing),
        content: const Text(
          'How would you like to share your scan?',
          style: kTextLetterSpacing,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _shareAsPdf();
            },
            child: const Text('PDF', style: TextStyle(
                letterSpacing: 0.0,
                fontWeight: .bold
            )),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _shareAsImages();
            },
            child: const Text('Images', style: TextStyle(
                letterSpacing: 0.0,
                fontWeight: .bold
            )),
          ),
        ],
      ),
    );
  }

  Future<void> _shareAsPdf() async {
    try {
      // Get PDF file from your ScanStorage (it doesn't auto-save, just generates)
      final pdfFile = await ScanStorage.generatePdf(widget.scanDir, fileName: _meta.name);

      if (pdfFile.existsSync()) {
        final params = ShareParams(
          files: [XFile(pdfFile.path)],
        );

        await SharePlus.instance.share(params);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share PDF: $e', style: kTextLetterSpacing,)),
        );
      }
    }
  }

  Future<void> _shareAsImages() async {
    try {
      // Get image files from scan folder
      final imageFiles = widget.scanDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.jpg'))
          .toList();

      if (imageFiles.isNotEmpty) {
        final xFiles = imageFiles.map((f) => XFile(f.path)).toList();
        final params = ShareParams(
          files: xFiles,
        );
        await SharePlus.instance.share(params);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share images: $e', style: kTextLetterSpacing,)),
        );
      }
    }
  }

  Future<File?> editScanImage(File imageFile) async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop & Rotate',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: false,
          hideBottomControls: false,
          showCropGrid: true,
        ),
        IOSUiSettings(
          title: 'Crop & Rotate',
          aspectRatioLockEnabled: false,
          rotateButtonsHidden: false,
          resetAspectRatioEnabled: true,
        ),
      ],
    );

    if (cropped == null) return null;

    // Replace original image
    final editedFile = File(cropped.path);
    await editedFile.copy(imageFile.path);

    return imageFile;

  }

  Future<void> showAddMorePagesDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(

          title: const Text('How would you like to add more scans?', style: kTextLetterSpacing,),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel', style: kTextLetterSpacing,),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _importImages();
              },
              child: const Text('From Photo Library', style: TextStyle(fontWeight: .bold, letterSpacing: 0.0)),
            ),
            TextButton(
              onPressed: () => _addMorePages(),
              child: const Text('From Camera', style: TextStyle(fontWeight: .bold, letterSpacing: 0.0)),
            ),
          ],
        );
      }
    );
  }

  Future<void> _addMorePages() async {
    try {
      setState(() => _loading = true);
      final result = await FlutterDocScanner()
          .getScannedDocumentAsImages(page: 4);

      List<String> images = [];

      if (result is Map && result['images'] != null) {
        images = List<String>.from(result['images']);
      } else if (result is List) {
        images = List<String>.from(result);
      }

      if (images.isEmpty) return;

      await ScanStorage.appendPages(
        scanDir: widget.scanDir,
        imageUris: images,
      );

      if (!mounted) return;

      setState(() {
        _reloadImages(); // same method you already use
      });

      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pages added', style: kTextLetterSpacing,),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add pages: $e', style: kTextLetterSpacing,),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _importImages() async {
    try {
      setState(() => _loading = true);

      final picker = ImagePicker();

      final pickedImages = await picker.pickMultiImage(
        imageQuality: 100,
      );

      if (pickedImages.isEmpty) return;

      final imagePaths = pickedImages.map((e) => e.path).toList();

      // Append imported images to the existing scan
      await ScanStorage.appendPages(
        scanDir: widget.scanDir,
        imageUris: imagePaths,
      );

      if (!mounted) return;

      // Important: clear image cache so imported images show up
      imageCache.clear();
      imageCache.clearLiveImages();

      setState(() {
        _reloadImages();
      });

      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Images imported successfully', style: kTextLetterSpacing,),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to import images: $e', style: kTextLetterSpacing,),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}