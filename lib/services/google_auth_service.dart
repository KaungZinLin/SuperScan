import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'google_oauth_config.dart';

class GoogleAuthService {
  GoogleAuthService._internal();

  static final GoogleAuthService instance =
  GoogleAuthService._internal();

  factory GoogleAuthService() => instance;

  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: GoogleOAuthConfig.serverClientId,
    scopes: const [
      'email',
      'profile',
      'https://www.googleapis.com/auth/drive.file',
    ],
  );

  GoogleSignInAccount? _user;

  GoogleSignInAccount? get currentUser => _user;

  bool get isSignedIn => _user != null;

  // Call once at app startup
  Future<void> initialize() async {
    await restoreSession();
  }

  Future<bool> signIn() async {
    try {
      final account = await _googleSignIn.signIn();

      if (account == null) {
        _user = null;
        return false;
      }

      _user = account;
      return true;
    } catch (e) {
      print('Google Sign-In error: $e');
      _user = null;
      return false;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _user = null;
  }

  Future<void> restoreSession() async {
    try {
      _user = await _googleSignIn.signInSilently();
    } catch (_) {
      _user = null;
    }
  }

  /// THIS replaces your old getHttpClient
  Future<http.Client?> getAuthenticatedClient() async {
    if (_user == null) return null;

    final headers = await _user!.authHeaders;

    return _GoogleHttpClient(headers);
  }
}

class _GoogleHttpClient extends http.BaseClient {
  final Map<String, String> headers;
  final http.Client base = http.Client();

  _GoogleHttpClient(this.headers);

  @override
  Future<http.StreamedResponse> send(
      http.BaseRequest request) {
    request.headers.addAll(headers);
    return base.send(request);
  }
}