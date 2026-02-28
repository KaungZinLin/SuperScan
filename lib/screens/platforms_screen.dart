import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:super_scan/constants.dart';

class PlatformsScreen extends StatelessWidget {
  const PlatformsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Get SuperScan on Desktop'),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 32),

            // Platform Sections
            _platformSection(
              context,
              icon: FontAwesomeIcons.apple,
              title: "macOS",
              description:
                  "Optimized for Apple Silicon. Requires macOS 12.0 or later.",
              version: "v1.2.4 (Universal)",
              onDownload: () => _handleDownload('macos'),
            ),

            _platformSection(
              context,
              icon: FontAwesomeIcons.windows,
              title: "Windows",
              description:
                  "Native .exe installer for Windows 10 and 11. Support for both x64 and ARM64 architectures.",
              version: "v1.2.4 (msix)",
              onDownload: () => _handleDownload('windows'),
            ),

            _platformSection(
              context,
              icon: FontAwesomeIcons.linux,
              title: "Linux",
              description:
                  "Available as an AppImage or Snap. Tested on Ubuntu, Fedora, and Arch Linux distributions.",
              version: "v1.2.4 (AppImage)",
              onDownload: () => _handleDownload('linux'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.devices, color: Colors.blueAccent, size: 28),
            const SizedBox(width: 8),
            Text(
              "Get SuperScan",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          "Sync your documents to desktop using Google Drive",
          style: TextStyle(color: Colors.grey, height: 1.4),
        ),
      ],
    );
  }

  Widget _platformSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required String version,
    required VoidCallback onDownload,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(icon, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                version,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(height: 1.4),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              // icon: const Icon(Icons.download_rounded, size: 18),
              label: Text("Coming soon"),
              style: OutlinedButton.styleFrom(
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: kAccentColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: onDownload,
            ),
          ),
        ],
      ),
    );
  }

  void _handleDownload(String platform) {
    // Logic to open your download URL
    debugPrint("Downloading for $platform...");
  }
}
