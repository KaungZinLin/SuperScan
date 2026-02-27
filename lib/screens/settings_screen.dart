import 'dart:async';

import 'package:flutter/material.dart';
import 'package:super_scan/constants.dart';
import 'package:super_scan/controllers/settings_controller.dart';
import 'package:super_scan/helpers/platform_helper.dart';
import 'package:super_scan/helpers/url_launcher.dart';
import 'package:super_scan/screens/api_key_screen.dart';
import 'package:super_scan/screens/donation_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:super_scan/screens/platforms_screen.dart';

class SettingsScreen extends StatefulWidget {
  static const String id = 'settings_screen';
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _viewController = SettingsController();

  bool isConnected = false; // Declare default internet connection
  StreamSubscription?
  _internetConnectionStreamSubscription; // Start a stream and

  @override
  void dispose() {
    _internetConnectionStreamSubscription?.cancel();
    _viewController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Subscribe to the stream
    _internetConnectionStreamSubscription = InternetConnection().onStatusChange
        .listen((event) {
          switch (event) {
            case InternetStatus.connected:
              setState(() => isConnected = true);
              break;
            case InternetStatus.disconnected:
              setState(() => isConnected = false);
              break;
            default:
              setState(() => isConnected = false);
              break;
          }
        });

    _viewController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = _viewController.auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: _viewController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // Added internet connection warning
                if (!isConnected)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: _buildNoInternetWidget(context),
                  ),

                const SizedBox(height: 16),
                ListTile(
                  leading: const FaIcon(FontAwesomeIcons.google),
                  title: const Text(
                    'Google Account for Sync',
                  ),
                  subtitle: user != null
                      ? Text('${user.displayName} • ${user.email}')
                      : const Text('Not signed in'),
                ),

                if (user == null)
                  ListTile(
                    leading: const Icon(Icons.login),
                    title: const Text(
                      'Sign in with Google',
                    ),
                    onTap: () {
                      _viewController.signIn(context);
                    },
                  )
                else
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Sign out',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      _viewController.showSignOutOptions(context);
                    },
                  ),

                ListTile(
                  leading: const Icon(Icons.install_desktop),
                  trailing: const Icon(Icons.chevron_right),
                  title: const Text(
                    'Get SuperScan on Desktop',
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PlatformsScreen()),
                    );
                  },
                ),

                const Divider(),
                ListTile(
                  enabled: !PlatformHelper.isDesktop,
                  leading: const Icon(Icons.auto_awesome_outlined),
                  title: const Text(
                    'AI Configuration',
                  ),
                  subtitle: PlatformHelper.isDesktop
                      ? const Text(
                          'Due to platform limitations regarding OCR, you can only use AI features on mobile',
                        )
                      : null,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ApiKeyScreen()),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  enabled: !PlatformHelper.isDesktop,
                  leading: const Icon(
                    Icons.favorite_border,
                    color: Colors.redAccent,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  title: const Text('Donate'),
                  subtitle: Text(
                    PlatformHelper.isDesktop
                        ? 'Due to platform limitations, you can only donate on mobile'
                        : 'Support my work, remove ads, and get access to AI features',
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DonateScreen()),
                    );
                  },
                ),
                const Divider(),

                ListTile(
                  leading: const Icon(Icons.info_outline),
                  trailing: const Icon(Icons.chevron_right),
                  title: const Text('About'),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationIcon: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/app_icon.png',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      applicationName: 'SuperScan',
                      applicationVersion: '0.1 (Beta) (Build 7.1)',
                      applicationLegalese: '© 2026 Kaung Zin Lin',
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Text(
                            'Scan & Sync with SuperScan!',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text(
                    'Made with ❤️ by Kaung Zin Lin',
                  ),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () async {
                    launchMyURL('https://kaung.carrd.co/');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.article_outlined),
                  title: const Text(
                    'Terms of Service',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text(
                    'Privacy Policy',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),

                ListTile(
                  leading: const Icon(Icons.medical_information_outlined),
                  title: const Text('License'),
                  subtitle: const Text(
                    'MIT License © 2026',
                  ), // Keep it short here
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
                              ),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Close',
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),

                ListTile(
                  leading: const FaIcon(FontAwesomeIcons.flutter),
                  title: const Text(
                    'Built with Flutter',
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildNoInternetWidget(BuildContext context) {
    // Defining a red color with transparency to match your previous style
    final Color errorRed = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        // Using .withOpacity or .withAlpha for that soft background look
        color: errorRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: errorRed.withOpacity(0.3),
          width: 1,
        ), // Optional: subtle border
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min, // Keeps the box tight around the content
        children: [
          Icon(Icons.wifi_off_rounded, color: errorRed, size: 20),
          const SizedBox(width: 12),
          const Flexible(
            child: Text(
              'Internet is required for sync and sign in',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14, // Slightly smaller to ensure it fits on one line
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
