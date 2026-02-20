import 'package:flutter/material.dart';
import 'package:super_scan/constants.dart';
import 'package:super_scan/controllers/settings_controller.dart';
import 'package:super_scan/screens/about_screen.dart';
import 'package:super_scan/screens/donation_screen.dart';

class SettingsScreen extends StatefulWidget {
  static const String id = 'settings_screen';
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _viewController = SettingsController();

  @override
  void initState() {
    super.initState();
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
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.account_circle),
                  title: const Text(
                    'Google Account for Sync',
                    style: kTextLetterSpacing,
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
                      style: kTextLetterSpacing,
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
                      style: TextStyle(color: Colors.red, letterSpacing: 0.0),
                    ),
                    onTap: () {
                      _viewController.showSignOutOptions(context);
                    },
                  ),

                const Divider(),

                ListTile(
                  leading: const Icon(
                    Icons.favorite_border,
                    color: Colors.redAccent,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  title: const Text(
                    'Support SuperScan',
                    style: kTextLetterSpacing,
                  ),
                  subtitle: const Text(
                    'Help me cover development costs and remove ads',
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DonateScreen()),
                    );
                  },
                ),

                /// ABOUT
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About', style: kTextLetterSpacing),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AboutScreen()),
                    );
                  },
                ),
              ],
            ),
    );
  }
}
