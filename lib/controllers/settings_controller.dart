import 'package:flutter/material.dart';
import 'package:super_scan/helpers/sign_in_result.dart';
import 'package:super_scan/helpers/sign_out_result.dart';
import 'package:super_scan/services/google_auth_service.dart';
import 'package:flutter/services.dart';
import 'package:windows_toast/windows_toast.dart';

class SettingsController extends ChangeNotifier {
  final auth = GoogleAuthService.instance;
  bool isLoading = false;

  // New sign-in SAFE!!!
  Future<SignInResult> signIn() async {
    try {
      isLoading = true;
      notifyListeners();

      final result = await auth.signIn();

      if (result == true || (result is! bool)) {
        return SignInResult.success;
      } else {
        return SignInResult.failed;
      }
    } on PlatformException catch (e) {
      throw Exception('Authentication error: ${e.code} ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // AI generated code
  // Future<void> signIn(BuildContext context) async {
  //   try {
  //     isLoading = true; // Start loading animation
  //     notifyListeners(); // Notify to display animation
  //
  //     // Changed from GoogleSignInAccount? to dynamic/var
  //     final result = await auth.signIn();
  //
  //     // If result is a bool and it's true, or if it's an object and not null
  //     if (result == true || (result is! bool)) {
  //       WindowsToast.show(
  //           'Signed in successfully',
  //           context,
  //           30,
  //       );
  //     } else {
  //       WindowsToast.show(
  //           'Signed in failed',
  //           context,
  //           30,
  //       );
  //     }
  //
  //     notifyListeners();
  //   } on PlatformException catch (e) {
  //     WindowsToast.show(
  //           'Authentication error: ${e.code} ${e.message}',
  //           context,
  //           30,
  //       );
  //   } catch (e) {
  //     WindowsToast.show(
  //           'Unexpected error: $e',
  //           context,
  //           30,
  //       );
  //   } finally {
  //     isLoading = false; // Stop animation
  //     notifyListeners(); // Notify to stop animation
  //   }
  // }

  Future<SignOutResult> signOut() async {
    try {
      isLoading = true; // Start animation
      notifyListeners(); // Notify about animation

      await auth.signOut();
      debugPrint('Sign in okay:');

      return SignOutResult.success;

    } catch (e) {
      debugPrint('Sign out failed: $e');
      return SignOutResult.failed;
    } finally {
      isLoading = false; // Stop animation
      notifyListeners(); // Notify about animation
    }
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
              onPressed: () async {
                Navigator.pop(context);

                signOut();

                final result = await signOut();

                if (!context.mounted) return;

                if (result == SignOutResult.success) {
                  WindowsToast.show('Signed out', context, 30);
                } else {
                  WindowsToast.show('Sign out failed', context, 30);
                }
              },
              child: const Text(
                'Sign Out',
                style: TextStyle(
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
