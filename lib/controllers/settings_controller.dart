import 'package:flutter/material.dart';
import 'package:super_scan/constants.dart';
import 'package:super_scan/services/google_auth_service.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
        Fluttertoast.showToast(
          msg: "Signed in successfully",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Failed to sign in",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
        );
      }

      notifyListeners();
    } on PlatformException catch (e) {
      Fluttertoast.showToast(
        msg: "Authentication error: [${e.code}] ${e.message}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Unexpected error: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
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

    Fluttertoast.showToast(
      msg: "Signed out",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
    );
  }

  Future<void> showSignOutOptions(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Are you sure you want to sign out?',
            style: kTextLetterSpacing,
          ),
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
