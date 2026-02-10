import 'package:flutter/material.dart';
import 'package:super_scan/constants.dart';
import 'package:super_scan/screens/about_screen.dart';
import 'package:super_scan/components/google_auth_service.dart';
import 'package:super_scan/components/google_drive_service.dart';
import 'package:super_scan/screens/donation_screen.dart';

class SettingsScreen extends StatefulWidget {
  static const String id = 'settings_screen';
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final auth = GoogleAuthService.instance;
  bool _loading = false;

  final _driveService = GoogleDriveService();

  Future<void> _signIn() async {
    setState(() => _loading = true);
    final success = await _driveService.signIn(); // <- important!
    setState(() => _loading = false);

    if (success) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signed in as ${_driveService.currentUser!.email}'), behavior: SnackBarBehavior.floating,),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign-in failed'), behavior: SnackBarBehavior.floating,),
      );
    }
  }

  Future<void> _signOut() async {
    setState(() => _loading = true);
    await _driveService.signOut(); // <- important!
    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Signed out')),
    );
    setState(() {

    });
  }

  Future<void> _showSignOutOptions() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Would you like to sign out?', style: kTextLetterSpacing,),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                style: kTextLetterSpacing,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _signOut();
              },
              child: const Text('Sign Out', style: TextStyle(
                  letterSpacing: 0.0,
                  fontWeight: .bold,
                  color: Colors.red,
              )),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        children: [
          const SizedBox(height: 16),

          /* ───────── GOOGLE ACCOUNT ───────── */

          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text(
              'Google Account for Sync',
              style: kTextLetterSpacing,
            ),
            subtitle: user != null
                ? Text('${user.displayName}・${user.email}')
                : const Text('Not signed in'),
          ),

          if (user == null)
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text(
                'Sign in with Google',
                style: kTextLetterSpacing,
              ),
              onTap: _signIn,
            )
          else
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Sign out',
                style: TextStyle(
                  color: Colors.red,
                  letterSpacing: 0.0,
                ),
              ),
              onTap: _showSignOutOptions,
            ),

          const Divider(),

          /* ───────── ABOUT ───────── */
          ListTile(
            leading: const Icon(Icons.favorite_border, color: Colors.redAccent),
            trailing: const Icon(Icons.chevron_right),
            title: const Text('Support SuperScan', style: kTextLetterSpacing,),
            subtitle: const Text('Help me cover development costs and remove ads'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DonateScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text(
              'About',
              style: kTextLetterSpacing,
            ),
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