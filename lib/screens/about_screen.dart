import 'package:flutter/material.dart';
import 'package:super_scan/components/url_launcher.dart';
import 'package:super_scan/constants.dart';

class AboutScreen extends StatelessWidget {
  static const String id = 'settings_screen';
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),

          // Add temporary settings page to make the app feel more "complete."
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/app_icon.png',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SuperScan (Alpha)',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Version 0.26.0.13',
                        style: TextStyle(color: color.onSurfaceVariant, fontSize: 13, letterSpacing: 0.0),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // --- ABOUT SECTION ---
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Made with ❤️ by Kaung Zin Lin', style: kTextLetterSpacing,),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await launchMyURL('https://kaung.carrd.co/');
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Terms of Service', style: kTextLetterSpacing,),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy', style: kTextLetterSpacing,),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.medical_information_outlined),
            title: const Text('License'),
            subtitle: const Text('MIT License © 2026', style: kTextLetterSpacing,), // Keep it short here
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('License'),
                    content: const SingleChildScrollView(
                      child: Text(
                        'MIT License\n\n'
                            'Copyright (c) 2026 Kaung Zin Lin\n\n'
                            'Permission is hereby granted, free of charge, to any person obtaining a copy '
                            'of this software and associated documentation files (the "Software"), to deal '
                            'in the Software without restriction, including without limitation the rights '
                            'to use, copy, modify, merge, publish, distribute, sublicense, and/or sell '
                            'copies of the Software, and to permit persons to whom the Software is '
                            'furnished to do so, subject to the following conditions:\n\n'
                            'The above copyright notice and this permission notice shall be included in all '
                            'copies or substantial portions of the Software.\n\n'
                            'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR '
                            'IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, '
                            'FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE '
                            'AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER '
                            'LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, '
                            'OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE '
                            'SOFTWARE.',
                        style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 0.0
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close', style: kTextLetterSpacing,),
                      ),
                    ],
                  );
                },
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.description_outlined),
            trailing: const Icon(Icons.chevron_right),
            title: const Text('Acknowledgements'),
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: 'SuperScan',
                applicationVersion: '0.26.0.13',
                applicationLegalese: '© 2026 Kaung Zin Lin',
              );
            },
          )
        ],
      ),
    );
  }

}