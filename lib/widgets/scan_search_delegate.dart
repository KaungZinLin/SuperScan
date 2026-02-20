import 'package:flutter/material.dart';
import 'package:super_scan/models/saved_scan.dart';
import 'package:super_scan/screens/scan_viewer_screen.dart';

class ScanSearchDelegate extends SearchDelegate<SavedScan?> {
  final List<SavedScan> allScans;

  ScanSearchDelegate(this.allScans);

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(
      icon: const Icon(Icons.clear),
      onPressed: () => query = '',
    ),
  ];

  @override
  Widget buildLeading(BuildContext context) =>
      BackButton(onPressed: () => close(context, null));

  @override
  Widget buildResults(BuildContext context) {
    final results = _filtered();

    if (results.isEmpty) {
      return const Center(child: Text('No scans found'));
    }

    return _buildList(context, results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildList(context, _filtered());
  }

  List<SavedScan> _filtered() {
    final q = query.toLowerCase();
    return allScans
        .where((scan) => scan.meta.name.toLowerCase().contains(q))
        .toList();
  }

  Widget _buildList(BuildContext context, List<SavedScan> scans) {
    return ListView.builder(
      itemCount: scans.length,
      itemBuilder: (context, index) {
        final scan = scans[index];
        return ListTile(
          title: Text(scan.meta.name),
          onTap: () {
            close(context, scan);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ScanViewerScreen(scanDir: scan.dir),
              ),
            );
          },
        );
      },
    );
  }
}