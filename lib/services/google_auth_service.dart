import 'package:flutter/cupertino.dart';
import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart';
import 'package:http/http.dart' as http;
import 'package:super_scan/helpers/auth_restore_result.dart';
import 'package:super_scan/helpers/toast_helper.dart';
import 'google_oauth_config.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class GoogleAuthService {
  GoogleAuthService._internal();

  static final GoogleAuthService instance = GoogleAuthService._internal();

  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    params: GoogleSignInParams(
      clientId: GoogleOAuthConfig.clientId,
      clientSecret: GoogleOAuthConfig.clientSecret,
      scopes: const [
        'openid',
        'email',
        'profile',
        'https://www.googleapis.com/auth/drive.file',
      ],
    ),
  );

  GoogleUser? _user;

  GoogleUser? get currentUser => _user;
  bool get isSignedIn => _user != null;

  Future<AuthRestoreResult> initialize() async {
    return await restoreSession();
  }

  Future<bool> signIn() async {
    try {
      final creds = await _googleSignIn.signIn();
      if (creds == null) {
        _user = null;
        return false;
      }

      _user = GoogleUser.fromIdToken(creds.accessToken, creds.idToken);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('google_email', _user?.email ?? '');
      await prefs.setString('google_name', _user?.displayName ?? '');

      return true;
    } catch (e) {
      _user = null;
      return false;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('google_email');
    await prefs.remove('google_name');

    _user = null;
  }

  Future<AuthRestoreResult> restoreSession() async {
    try {
      final creds = await _googleSignIn.silentSignIn();

      if (creds == null) {
        _user = null;
        return AuthRestoreResult.none;
      }

      _user = GoogleUser.fromIdToken(creds.accessToken, creds.idToken);

      if (_user?.email == null || _user?.displayName == null) {
        return AuthRestoreResult.expired;
      }

      return AuthRestoreResult.restored;
    } catch (_) {
      _user = null;
      return AuthRestoreResult.expired;
    }
  }

  Future<Map<String, dynamic>> _fetchProfile(String token) async {
    final response = await http.get(
      Uri.parse('https://www.googleapis.com/oauth2/v3/userinfo'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }

    return {};
  }

  Future<http.Client?> getAuthenticatedClient() async {
    if (_user == null) return null;
    return _GoogleHttpClient({'Authorization': 'Bearer ${_user!.accessToken}'});
  }
}

class _GoogleHttpClient extends http.BaseClient {
  final Map<String, String> headers;
  final http.Client base = http.Client();

  _GoogleHttpClient(this.headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(headers);
    return base.send(request);
  }
}

class GoogleUser {
  final String accessToken;
  final String? idToken;

  final String? email;
  final String? displayName;

  GoogleUser({
    required this.accessToken,
    this.idToken,
    this.email,
    this.displayName,
  });

  /// Decode the ID token manually to extract email and displayName
  factory GoogleUser.fromIdToken(String accessToken, String? idToken) {
    String? email;
    String? displayName;

    if (idToken != null) {
      try {
        // JWT format: header.payload.signature
        final parts = idToken.split('.');
        if (parts.length == 3) {
          final payload = parts[1];
          final normalized = base64Url.normalize(payload);
          final decoded = utf8.decode(base64Url.decode(normalized));
          final Map<String, dynamic> data = json.decode(decoded);
          email = data['email'] as String?;
          displayName = data['name'] as String?;
        }
      } catch (_) {
        // silently fail, keep email & name null
      }
    }

    return GoogleUser(
      accessToken: accessToken,
      idToken: idToken,
      email: email,
      displayName: displayName,
    );
  }

  /// Simple helper to get auth headers
  Future<Map<String, String>> get authHeaders async {
    return {
      'Authorization': 'Bearer $accessToken',
    };
  }
}