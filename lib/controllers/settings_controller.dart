import 'package:flutter/material.dart';
import 'package:super_scan/constants.dart';
import 'package:super_scan/services/google_auth_service.dart';
import 'package:flutter/services.dart';

class SettingsController extends ChangeNotifier {
  final auth = GoogleAuthService.instance;
  bool isLoading = false;

  // AI generated code
  Future<void> signIn(BuildContext context) async {
    try {
      isLoading = true; // Start loading animation
      notifyListeners(); // Notify to display animation

      // Changed from GoogleSignInAccount? to dynamic/var
      final result = await auth.signIn();

      // If result is a bool and it's true, or if it's an object and not null
      if (result == true || (result is! bool)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signed in successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign-in failed'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      notifyListeners();
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Authentication error: [${e.code}] ${e.message}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 10),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unexpected error: $e'),
          backgroundColor: Colors.orange,
        ),
      );
    } finally {
      isLoading = false; // Stop animation
      notifyListeners(); // Notify to stop animation
    }
  }

  Future<void> signOut(BuildContext context) async {
    isLoading = true; // Start animation
    notifyListeners(); // Notify about animation

    await auth.signOut();

    isLoading = false; // Stop animation
    notifyListeners(); // Notify about animation

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Signed out'), behavior: .floating),
    );
  }

  Future<void> showSignOutOptions(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Are you sure you want to sign out?', style: kTextLetterSpacing),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: kTextLetterSpacing),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                signOut(context);
              },
              child: const Text(
                'Sign Out',
                style: TextStyle(
                  letterSpacing: 0.0,
                  fontWeight: .bold,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
