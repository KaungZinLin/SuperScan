import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:super_scan/constants.dart';
import 'package:super_scan/components/scan_meta.dart';
import 'package:super_scan/components/scan_storage.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_cropper/image_cropper.dart';

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
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz, color: kAccentColor),
            onPressed: _showScanOptions,
          ),
          IconButton(
            icon: Icon(Icons.ios_share, color: kAccentColor),
              onPressed: () => _showExportOptions(context),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _images.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GestureDetector(
                onLongPress: () async {
                  final edited = await editScanImage(_images[index]);
                  if (edited != null && context.mounted) {
                    await imageCache.evict(FileImage(edited));
                    setState(() {

                    }); // refresh viewer
                  }
                },
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
    );
  }

  /* ───────────────── OPTIONS ───────────────── */

  Future<void> _showScanOptions() async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Options for “${_meta.name}”', style: kTextLetterSpacing),
        content: const Text(
          'What would you like to do?',
          style: kTextLetterSpacing,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: kTextLetterSpacing),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _renameScan();
            },
            child: const Text(
                'Rename',
                style: TextStyle(
                fontWeight: .bold, letterSpacing: 0.0
                )
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteScan();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red, fontWeight: .bold, letterSpacing: 0.0),
            ),
          ),
        ],
      ),
    );
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
            child: const Text('Save', style: kTextLetterSpacing),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty) return;

    await ScanStorage.renameScan(
      scanDir: widget.scanDir,
      newName: result,
    );

    // ✅ Update UI without leaving screen
    setState(() {
      _meta = _meta.copyWith(name: result);
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
            child: const Text('Delete', style: kTextLetterSpacing),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ScanStorage.deleteScan(widget.scanDir);

    if (context.mounted) {
      Navigator.pop(context, true); // Refresh HomeScreen
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
          SnackBar(content: Text('Failed to share PDF: $e')),
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
          SnackBar(content: Text('Failed to share images: $e')),
        );
      }
    }
  }

  Future<File?> editScanImage(File imageFile) async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Edit Scan',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: false,
          hideBottomControls: false,
          showCropGrid: true,
        ),
        IOSUiSettings(
          title: 'Edit Scan',
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

  Future<void> _onReorder(int oldIndex, int newIndex) async {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final file = _images.removeAt(oldIndex);
      _images.insert(newIndex, file);
    });

    // 🔥 Persist order by renaming files
    for (int i = 0; i < _images.length; i++) {
      final newPath =
          '${widget.scanDir.path}/page_${i + 1}.jpg';

      if (_images[i].path != newPath) {
        await _images[i].rename(newPath);
        _images[i] = File(newPath);
      }
    }

    setState(() {}); // refresh UI
  }
}