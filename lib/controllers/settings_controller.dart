import 'package:flutter/material.dart';
import 'package:super_scan/constants.dart';
import 'package:super_scan/services/google_auth_service.dart';
import 'package:flutter/services.dart';
import 'package:windows_toast/windows_toast.dart';

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
        WindowsToast.show(
            'Signed in successfully',
            context,
            30,
        );
      } else {
        WindowsToast.show(
            'Signed in failed',
            context,
            30,
        );
      }

      notifyListeners();
    } on PlatformException catch (e) {
      WindowsToast.show(
            'Authentication error: ${e.code} ${e.message}',
            context,
            30,
        );
    } catch (e) {
      WindowsToast.show(
            'Unexpected error: $e',
            context,
            30,
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

    WindowsToast.show(
        'Signed out',
        context,
        30,
    );
  }

  Future<void> showSignOutOptions(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Are you sure you want to sign out?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
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
