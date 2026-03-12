import 'dart:async';
import 'package:flutter/material.dart';
import 'package:super_scan/helpers/platform_helper.dart';
import 'package:super_scan/constants.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:super_scan/services/google_auth_service.dart';

class EmptyScansPlaceHolder extends StatefulWidget {
  const EmptyScansPlaceHolder({super.key});

  @override
  State<EmptyScansPlaceHolder> createState() => _EmptyScansPlaceHolderState();
}

class _EmptyScansPlaceHolderState extends State<EmptyScansPlaceHolder> {
  bool isConnected = false; // Declare default internet connection
  StreamSubscription?
  _internetConnectionStreamSubscription; // Start a stream and

  final auth = GoogleAuthService.instance; // Get an instance of the Auth service

  @override
  void initState() {
    _internetConnectionStreamSubscription =
        InternetConnection().onStatusChange.listen(_internetListener);
    super.initState();
  }

  void _internetListener(InternetStatus event) {
    if (!mounted) return;
    switch (event) {
      case InternetStatus.connected:
        setState(() => isConnected = true);
        break;
      case InternetStatus.disconnected:
        setState(() => isConnected = false);
        break;
    }
  }

  // Dispose the subscription to prevent memory leak
  @override
  void dispose() {
    _internetConnectionStreamSubscription?.cancel();
    _internetConnectionStreamSubscription = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = auth.currentUser; // Declare current user

    if (PlatformHelper.isDesktop) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isConnected) ...[
              const Icon(Icons.wifi_off_rounded, size: 80, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'No Internet Connection',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ] else if (user == null) ...[
              const Icon(Icons.person_add_rounded, size: 80, color: kAccentColor),
              const SizedBox(height: 16),
              const Text(
                'Not Signed In',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const Opacity(
                opacity: 0.6,
                child: Text(
                  'Sign in to get synced scans. Go to Settings > Sign In',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ] else ... [
              Icon(Icons.document_scanner_rounded, size: 80, color: kAccentColor),
              const SizedBox(height: 16),
              const Text(
                "No Scans Yet",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              )
            ],
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.document_scanner_rounded, size: 80, color: kAccentColor),
          const SizedBox(height: 16),
          Text(
            'No Scans Yet',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Opacity(
            opacity: 0.6,
            child: Text(
              'Start scanning by pressing “+”',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
