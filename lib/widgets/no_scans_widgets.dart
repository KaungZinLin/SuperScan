import 'package:flutter/material.dart';
import 'package:super_scan/components/platform_helper.dart';
import 'package:super_scan/constants.dart';

class EmptyScansPlaceholder extends StatelessWidget {
  const EmptyScansPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Elegant Icon with subtle background
          Icon(
            PlatformHelper.isDesktop ? Icons.cloud_sync_outlined : Icons.document_scanner_outlined,
            size: 80,
            color: kAccentColor,
          ),
          const SizedBox(height: 16),
          // Title
          Text(
            PlatformHelper.isDesktop ? 'No Synced Scans' : 'No Scans Yet',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          // Description
          Opacity(
            opacity: 0.6,
            child: Text(
              PlatformHelper.isDesktop
                  ? 'Check your connection or sign in'
                  : 'Start scanning by pressing “+”',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}