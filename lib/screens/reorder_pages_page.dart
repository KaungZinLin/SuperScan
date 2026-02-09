import 'dart:io';
import 'package:flutter/material.dart';
import 'package:super_scan/components/scan_storage.dart';

class ReorderPagesPage extends StatefulWidget {
  final Directory scanDir;
  final VoidCallback? onReorderDone;

  const ReorderPagesPage({
    super.key,
    required this.scanDir,
    this.onReorderDone,
  });

  @override
  State<ReorderPagesPage> createState() => _ReorderPagesPageState();
}

class _ReorderPagesPageState extends State<ReorderPagesPage> {
  List<File> _pages = [];
  bool _dirty = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPages();
  }

  Future<void> _loadPages() async {
    final images = await ScanStorage.getScanImages(widget.scanDir);

    if (!mounted) return;

    setState(() {
      _pages = images;
      _loading = false;
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex--;
    }

    setState(() {
      final file = _pages.removeAt(oldIndex);
      _pages.insert(newIndex, file);
      _dirty = true;
    });
  }

  Future<void> _saveOrder() async {
    if (!_dirty) {
      Navigator.pop(context);
      return;
    }

    await ScanStorage.reorderPages(
      widget.scanDir,
      List<File>.from(_pages),
    );

    // Tell parent to reload
    widget.onReorderDone?.call();

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reorder'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _dirty ? _saveOrder : null,
            child: const Text('Done'),
          ),
        ],
      ),
      body: ReorderableListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pages.length,
        onReorder: _onReorder,
        proxyDecorator: (child, index, animation) {
          return Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(12),
            child: child,
          );
        },
        itemBuilder: (context, index) {
          final file = _pages[index];

          return Padding(
            key: ValueKey(file.path),
            padding: const EdgeInsets.only(bottom: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                color: Theme.of(context).colorScheme.surface,
                child: ListTile(
                  leading: Text(
                    '${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  title: Image.file(
                    file,
                    height: 140,
                    fit: BoxFit.contain,
                  ),
                  trailing: const Icon(Icons.drag_handle),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}