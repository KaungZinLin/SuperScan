import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:super_scan/helpers/platform_helper.dart';
import 'package:super_scan/constants.dart';
import 'package:super_scan/models/scan_meta.dart';
import 'package:super_scan/services/scan_storage.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:super_scan/screens/reorder_pages_page.dart';
import 'package:super_scan/controllers/sync_controller.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ScanViewerController extends ChangeNotifier {
  // Alternative to !mounted in the view - don't understand it yet
  bool _isDisposed = false;
  bool get isMounted => !_isDisposed;

  late ScanMeta meta;
  late List<File> images;

  bool isLoading = false;

  @override
  void dispose() {
    _isDisposed =
        true; // Mark as disposed - Alternative to !mounted in the view - don't understand it yet
    super.dispose();
  }

  void loadMeta(Directory scanDir) {
    final metaFile = File('${scanDir.path}/meta.json');
    final json = jsonDecode(metaFile.readAsStringSync());
    meta = ScanMeta.fromJson(json);
  }

  void loadImages(Directory scanDir) {
    images =
        scanDir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.jpg'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));
  }

  void showContextMenu(
    BuildContext context,
    Offset tapPosition,
    int index,
    scanDir,
  ) async {
    // 2. Identify where on the screen the menu should appear
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

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
            title: Text('Crop and Rotate', style: kTextLetterSpacing),
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
            title: Text(
              'Delete this Page',
              style: TextStyle(color: Colors.red, letterSpacing: 0.0),
            ),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );

    // 3. Handle the result
    if (selectedAction == null) return;

    switch (selectedAction) {
      case 'edit':
        isLoading = true; // Start loading animation
        notifyListeners(); // Notify to display animation

        try {
          final edited = await editScanImage(images[index]);
          if (edited != null && isMounted) {
            // Replace the File object in the list
            images[index] = File(edited.path);

            // Evict old image from memory cache
            imageCache.evict(FileImage(images[index]));
          }
        } catch (e) {
          debugPrint("Error editing image: $e");
        } finally {
          isLoading = false; // Stop animation
          notifyListeners(); // Notify to stop animation
        }
        break;
      case 'delete':
        isLoading = true; // Start loading animation
        notifyListeners(); // Notify to display animation

        try {
          await ScanStorage.removePageByFile(imageFile: images[index]);

          if (!isMounted) return;

          await reloadImages(scanDir, refreshUI: true);
        } catch (e) {
          debugPrint('Failed to delete: $e');
        } finally {
          if (isMounted) {
            isLoading = false; // Stop animation
            notifyListeners(); // Notify to display animation
          }
        }

        if (!isMounted) return;

        reloadImages(scanDir); // Refresh images
        notifyListeners(); // Notify about image updates

        isLoading = false; // Stop animation
        notifyListeners(); // Notify to stop animation
        break;
      case 'reorder':
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReorderPagesPage(
              scanDir: scanDir,
              onReorderDone: () {
                reloadImages(
                  scanDir,
                  refreshUI: true,
                ); // <-- reload the parent UI immediately
              },
            ),
          ),
        );
        break;
    }
  }

  // AI generated code
  Future<void> reloadImages(Directory scanDir, {bool refreshUI = false}) async {
    try {
      // 1. Use STREAM (list()) instead of Sync to keep the UI buttery smooth
      final List<File> fetchedImages = await scanDir
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.jpg'))
          .cast<File>()
          .toList();

      // 2. Sort safely
      fetchedImages.sort((a, b) => a.path.compareTo(b.path));

      // Update the local variable
      images = fetchedImages;

      // 3. Evict from cache (Correctly done)
      for (final img in images) {
        await FileImage(img).evict();
      }

      // 4. Check mount status before touching UI
      if (refreshUI && isMounted) {
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error reloading images: $e");
    }
  }

  /* ───────────────── RENAME (NO POP) ───────────────── */

  Future<void> renameScan(BuildContext context, scanDir) async {
    final controller = TextEditingController(text: meta.name);

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
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text(
              'Save',
              style: TextStyle(fontWeight: .bold, letterSpacing: 0.0),
            ),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty) return;

    await ScanStorage.renameScan(scanDir: scanDir, newName: result);

    meta = meta.copyWith(name: result);
    notifyListeners();

    Fluttertoast.showToast(
      msg: "Renamed successfully",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
    );
  }

  /* ───────────────── DELETE (POP + REFRESH) ───────────────── */

  Future<void> deleteScan(BuildContext context, scanDir) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete scan?', style: kTextLetterSpacing),
        content: Text(
          '“${meta.name}” will be permanently deleted.',
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
            child: const Text(
              'Delete',
              style: TextStyle(fontWeight: .bold, letterSpacing: 0.0),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ScanStorage.deleteScan(scanDir);
    await SyncController.deleteScan(scanDir);

    if (context.mounted) {
      Navigator.pop(context, true);
      Fluttertoast.showToast(
        msg: PlatformHelper.isDesktop
            ? 'Deleted from Google Drive'
            : 'Deleted permanently',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
      );
    }
  }

  Future<void> showExportOptions(BuildContext context, scanDir) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Share “${meta.name}”', style: kTextLetterSpacing),
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
              await shareAsPdf(context, scanDir);
            },
            child: const Text(
              'PDF',
              style: TextStyle(letterSpacing: 0.0, fontWeight: .bold),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await shareAsImages(context, scanDir);
            },
            child: const Text(
              'Images',
              style: TextStyle(letterSpacing: 0.0, fontWeight: .bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> shareAsPdf(BuildContext context, scanDir) async {
    try {
      // Get PDF file from your ScanStorage (it doesn't auto-save, just generates)
      final pdfFile = await ScanStorage.generatePdf(
        scanDir,
        fileName: meta.name,
      );

      if (pdfFile.existsSync()) {
        final params = ShareParams(files: [XFile(pdfFile.path)]);

        await SharePlus.instance.share(params);
      }
    } catch (e) {
      if (context.mounted) {
        Fluttertoast.showToast(
          msg: "Failed to share PDF: $e",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
        );
      }
    }
  }

  Future<void> shareAsImages(BuildContext context, Directory scanDir) async {
    // Specified scanDir to be a type of Directory to fix the image export issue
    try {
      // Get image files from scan folder
      final imageFiles = scanDir
          .listSync()
          .whereType<File>()
          .where((File f) => f.path.toLowerCase().endsWith('.jpg'))
          .toList();

      if (imageFiles.isNotEmpty) {
        final xFiles = imageFiles.map((f) => XFile(f.path)).toList();
        final params = ShareParams(files: xFiles);
        await SharePlus.instance.share(params);
      }
    } catch (e) {
      if (context.mounted) {
        Fluttertoast.showToast(
          msg: "Failed to share images: $e",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
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

  Future<void> showAddMorePagesDialog(BuildContext context, scanDir) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'How would you like to add more scans?',
            style: kTextLetterSpacing,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel', style: kTextLetterSpacing),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                importImages(context, scanDir);
              },
              child: const Text(
                'From Photo Library',
                style: TextStyle(fontWeight: .bold, letterSpacing: 0.0),
              ),
            ),
            TextButton(
              onPressed: () => addMorePages(context, scanDir),
              child: const Text(
                'From Camera',
                style: TextStyle(fontWeight: .bold, letterSpacing: 0.0),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> addMorePages(BuildContext context, scanDir) async {
    try {
      isLoading = true; // Start loading animation
      notifyListeners(); // Notify to display animation

      final result = await FlutterDocScanner().getScannedDocumentAsImages(
        page: 4,
      );

      List<String> images = [];

      if (result is Map && result['images'] != null) {
        images = List<String>.from(result['images']);
      } else if (result is List) {
        images = List<String>.from(result);
      }

      if (images.isEmpty) return;

      await ScanStorage.appendPages(scanDir: scanDir, imageUris: images);

      if (images.isEmpty) return;

      reloadImages(scanDir); // Refresh images
      notifyListeners(); // Notify to refresh animation

      isLoading = false; // End loading animation
      notifyListeners(); // Notify to stop animation

      Fluttertoast.showToast(
        msg: "Added pages",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
      );
    } catch (e) {
      if (!isMounted) return;
      isLoading = false; // End loading animation
      notifyListeners(); // Notify to stop animation
      Fluttertoast.showToast(
        msg: "Failed to add images: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
      );
    }
  }

  Future<void> importImages(BuildContext context, scanDir) async {
    try {
      isLoading = true; // Start loading animation
      notifyListeners(); // Notify to display animation

      final picker = ImagePicker();

      final pickedImages = await picker.pickMultiImage(imageQuality: 100);

      if (pickedImages.isEmpty) return;

      final imagePaths = pickedImages.map((e) => e.path).toList();

      // Append imported images to the existing scan
      await ScanStorage.appendPages(scanDir: scanDir, imageUris: imagePaths);

      if (!isMounted) return;

      // clear image cache so imported images show up
      imageCache.clear();
      imageCache.clearLiveImages();

      reloadImages(scanDir); // Refresh images
      notifyListeners(); // Notify to refresh animation

      isLoading = false; // End loading animation
      notifyListeners(); // Notify to stop animation

      Fluttertoast.showToast(
        msg: "Imported images successfully",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
      );
    } catch (e) {
      if (!isMounted) return;
      isLoading = false; // End loading animation
      notifyListeners(); // Notify to stop animation
      Fluttertoast.showToast(
        msg: "Failed to import images: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
      );
    }
  }
}
