import 'dart:io';
import 'package:flutter/material.dart';
import 'package:super_scan/controllers/scan_viewer_controller.dart';
import 'package:super_scan/helpers/platform_helper.dart';
import 'package:super_scan/constants.dart';

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
        title: Text(_viewController.meta.name, style: kTextLetterSpacing),
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
                    // 1. Use onLongPressStart to get the tap coordinates
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
              color: Colors.black45, // semi-transparent overlay
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
                  : () => _viewController.showAddMorePagesDialog(
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
                          : kAccentColor, // or your default color
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {},
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.remove_red_eye, color: kAccentColor),
                  Text(
                    "MagicEyes",
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 0.0,
                      color: kAccentColor,
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
                  Icon(Icons.ios_share, color: kAccentColor),
                  Text(
                    "Share",
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 0.0,
                      color: kAccentColor,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: PlatformHelper.isDesktop
                  ? null
                  : () => _viewController.renameScan(context, widget.scanDir),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.edit,
                    color: PlatformHelper.isDesktop
                        ? Colors.grey
                        : kAccentColor,
                  ),
                  Text(
                    "Rename",
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 0.0,
                      color: PlatformHelper.isDesktop
                          ? Colors.grey
                          : kAccentColor, // or your default color
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
                  Icon(Icons.delete, color: kAccentColor),
                  Text(
                    "Delete",
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 0.0,
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
}
