import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  GoogleAuthService._();
  static final instance = GoogleAuthService._();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: const ['email', 'profile'],
  );

  GoogleSignInAccount? _user;

  GoogleSignInAccount? get currentUser => _user;
  bool get isSignedIn => _user != null;

  /* ───────── SIGN IN ───────── */

  Future<bool> signIn() async {
    try {
      _user = await _googleSignIn.signIn();
      return _user != null;
    } catch (e) {
      print('Google sign-in error: $e');
      return false;
    }
  }

  /* ───────── RESTORE SESSION ───────── */

  Future<void> tryRestoreSession() async {
    try {
      _user = await _googleSignIn.signInSilently();
    } catch (_) {}
  }

  /* ───────── SIGN OUT ───────── */

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _user = null;
  }
}