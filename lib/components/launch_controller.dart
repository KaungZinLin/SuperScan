import 'dart:async';

class LaunchController {
  Future<void> initializeApp() async {
    await Future.delayed(const Duration(seconds: 3));
  }
}