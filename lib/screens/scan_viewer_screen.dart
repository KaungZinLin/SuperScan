import 'dart:io';
import 'package:flutter/material.dart';


class ScanViewerScreen extends StatelessWidget {
  final Directory scanDir;

  const ScanViewerScreen({
    super.key,
    required this.scanDir,
  });

  @override
  Widget build(BuildContext context) {
    final images = scanDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.jpg'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                images[index],
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }
}