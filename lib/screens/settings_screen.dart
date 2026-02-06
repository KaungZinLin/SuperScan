import 'package:flutter/material.dart';
import 'package:super_scan/screens/about_screen.dart';

class SettingsScreen extends StatelessWidget {
  static const String id = 'settings_screen';
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),

          // --- ABOUT SECTION ---
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AboutScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }


}

// Widget _buildSectionHeader(String title) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//     child: Text(
//       title.toUpperCase(),
//       style: const TextStyle(
//         fontSize: 12,
//         fontWeight: FontWeight.bold,
//         color: Colors.blueAccent,
//         letterSpacing: 0.0,
//       ),
//     ),
//   );
// }