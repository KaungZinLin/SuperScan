import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:super_scan/controllers/scan_viewer_controller.dart';
import 'package:super_scan/helpers/add_more_pages_results.dart';
import 'package:super_scan/helpers/import_images_result.dart';
import 'package:super_scan/helpers/platform_helper.dart';
import 'package:super_scan/constants.dart';
import 'package:super_scan/helpers/toast_helper.dart';
import 'package:super_scan/localization/locales.dart';
import 'package:super_scan/models/singletons_data.dart';
import 'package:super_scan/screens/half_popup_screen.dart';
import 'package:super_scan/screens/magic_eyes_screen.dart';

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
    final errorMessage = LocaleData.unexpected_error.getString(context); // Get it while context is safe
    final addPagesSuccess = LocaleData.add_pages_success.getString(context);
    final addPagesFailed = LocaleData.add_pages_failed.getString(context);
    final fromCameraIOS = LocaleData.from_camera.getString(context);
    final fromPhotosIOS = LocaleData.from_photos.getString(context);

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text(_viewController.meta.name)),
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
                  : () => showAddMorePagesDialog(context, widget.scanDir, errorMessage, addPagesSuccess, addPagesFailed, fromCameraIOS, fromPhotosIOS),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_rounded,
                    color: PlatformHelper.isDesktop
                        ? Colors.grey
                        : kAccentColor,
                  ),
                  Text(
                    LocaleData.add.getString(context),
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
                  : () {
                    if (appData.entitlementIsActive) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MagicEyesScreen(scanDir: widget.scanDir),
                        ),
                      );
                    } else {
                      showModalBottomSheet<void>(
                        context: context,
                          builder: (BuildContext context) => HalfPopupScreen(
                            title: LocaleData.support_title.getString(context),
                            subtitle: LocaleData.support_subtitle.getString(context),
                            body: '',
                            iconData: Icons.favorite,
                          ),
                      );
                    }
                  },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
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
                  Icon(Icons.ios_share_rounded, color: kAccentColor),
                  Text(
                    LocaleData.share_button.getString(context),
                    style: TextStyle(fontSize: 12, color: kAccentColor),
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
                        ToastHelper.show(LocaleData.rename_failed.getString(context));
                      }
                    },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.edit_rounded,
                    color: PlatformHelper.isDesktop
                        ? Colors.grey
                        : kAccentColor,
                  ),
                  Text(
                    LocaleData.rename.getString(context),
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
                  Icon(Icons.delete_rounded, color: kAccentColor),
                  Text(
                    LocaleData.delete.getString(context),
                    style: TextStyle(fontSize: 12, color: kAccentColor),
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
    BuildContext context,
    Directory scanDir,
      String errorMessage,
      String addPagesSuccess,
      String addPagesFailed,
      String cameraiOS,
      String photosiOS,
  ) async {
    if (!Platform.isIOS) {
      try {
        final result = await _viewController.addMorePages(scanDir);

        if (!mounted) return;

        if (result == AddMorePagesResults.success) {
          ToastHelper.show(addPagesSuccess);
        } else {
          ToastHelper.show(addPagesFailed);
        }
      } catch (e) {
        if (!mounted) return;
        ToastHelper.show('$errorMessage: $e');
      }
    } else {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(LocaleData.add_question.getString(context)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(LocaleData.cancel.getString(context)),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    final result = await _viewController.importImages(scanDir);

                    if (!mounted) return;

                    if (result == ImportImagesResult.success) {
                      ToastHelper.show(addPagesSuccess);
                    } else {
                      ToastHelper.show(addPagesFailed);
                    }
                  } catch (e) {
                    if (!mounted) return;
                    ToastHelper.show('$errorMessage $e');
                  }
                },
                child: Text(
                  photosiOS,
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
                      ToastHelper.show(addPagesSuccess);
                    } else {
                      ToastHelper.show(addPagesFailed);
                    }
                  } catch (e) {
                    if (!mounted) return;
                    ToastHelper.show('$errorMessage $e');
                  }
                },
                child: Text(
                  cameraiOS,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      );
    }
  }
}
