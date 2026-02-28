import 'dart:io';
import 'package:flutter/material.dart';
import 'package:super_scan/controllers/scan_viewer_controller.dart';
import 'package:super_scan/helpers/add_more_pages_results.dart';
import 'package:super_scan/helpers/import_images_result.dart';
import 'package:super_scan/helpers/platform_helper.dart';
import 'package:super_scan/constants.dart';
import 'package:super_scan/screens/magic_eyes_screen.dart';
import 'package:windows_toast/windows_toast.dart';

class ScanViewerScreen extends StatefulWidget {
  final Directory scanDir;

  const ScanViewerScreen({super.key, required this.scanDir});

  @override
  State<ScanViewerScreen> createState() => _ScanViewerScreenState();
}

class _ScanViewerScreenState extends State<ScanViewerScreen> {
  final _viewController = ScanViewerController();

  @override
  void initState() {
    super.initState();
    _viewController.loadMeta(widget.scanDir);
    _viewController.loadImages(widget.scanDir);

    _viewController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_viewController.meta.name),
      ),
      body: Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _viewController.images.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GestureDetector(
                    onLongPressStart: PlatformHelper.isDesktop
                        ? null
                        : (details) => _viewController.showContextMenu(
                      context,
                      details.globalPosition,
                      index,
                      widget.scanDir,
                    ),
                    child: Image.file(
                      _viewController.images[index],
                      key: ValueKey(
                        _viewController.images[index]
                            .lastModifiedSync()
                            .millisecondsSinceEpoch,
                      ),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              );
            },
          ),
          if (_viewController.isLoading)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(
              onTap: PlatformHelper.isDesktop
                  ? null
                  : () => showAddMorePagesDialog(
                context,
                widget.scanDir,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add,
                    color: PlatformHelper.isDesktop
                        ? Colors.grey
                        : kAccentColor,
                  ),
                  Text(
                    "Add",
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 0.0,
                      color: PlatformHelper.isDesktop
                          ? Colors.grey
                          : kAccentColor,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: PlatformHelper.isDesktop
                  ? null
                  : () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MagicEyesScreen(scanDir: widget.scanDir),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome_outlined,
                    color: PlatformHelper.isDesktop
                        ? Colors.grey
                        : kAccentColor,
                  ),
                  Text(
                    "MagicEyes",
                    style: TextStyle(
                      fontSize: 12,
                      color: PlatformHelper.isDesktop
                          ? Colors.grey
                          : kAccentColor,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () =>
                  _viewController.showExportOptions(context, widget.scanDir),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.ios_share_outlined, color: kAccentColor),
                  Text(
                    "Share",
                    style: TextStyle(
                      fontSize: 12,
                      color: kAccentColor,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: PlatformHelper.isDesktop
                  ? null
                  : () {
                try {
                  _viewController.renameScan(context, widget.scanDir);
                } catch (e) {
                  WindowsToast.show('Failed to rename', context, 30);
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.edit_outlined,
                    color: PlatformHelper.isDesktop
                        ? Colors.grey
                        : kAccentColor,
                  ),
                  Text(
                    "Rename",
                    style: TextStyle(
                      fontSize: 12,
                      color: PlatformHelper.isDesktop
                          ? Colors.grey
                          : kAccentColor,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                _viewController.deleteScan(context, widget.scanDir);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete_outline, color: kAccentColor),
                  Text(
                    "Delete",
                    style: TextStyle(
                      fontSize: 12,
                      color: kAccentColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showAddMorePagesDialog(
      BuildContext context, Directory scanDir) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'How would you like to add more scans?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  final result = await _viewController.importImages(scanDir);

                  if (!mounted) return;

                  if (result == ImportImagesResult.success) {
                    WindowsToast.show('Images imported successfully', context, 30);
                  } else {
                    WindowsToast.show('Failed to import images', context, 30);
                  }
                } catch (e) {
                  if (!mounted) return;
                  WindowsToast.show('Unexpected error: $e', context, 30);
                }
              },
              child: const Text(
                'From Photo Library',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  final result = await _viewController.addMorePages(scanDir);

                  if (!mounted) return;

                  if (result == AddMorePagesResults.success) {
                    WindowsToast.show('Pages added successfully', context, 30);
                  } else {
                    WindowsToast.show('Failed to add pages', context, 30);
                  }
                } catch (e) {
                  if (!mounted) return;
                  WindowsToast.show('Unexpected error: $e', context, 30);
                }
              },
              child: const Text(
                'From Camera',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}