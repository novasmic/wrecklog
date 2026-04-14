import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  FirebaseAuth? _authInstance;
  FirebaseAuth get _auth {
    try {
      _authInstance ??= FirebaseAuth.instance;
    } catch (_) {}
    return _authInstance ?? FirebaseAuth.instance;
  }

  User? get currentUser { try { return _auth.currentUser; } catch (_) { return null; } }
  bool get isSignedIn => currentUser != null;
  String? get uid => currentUser?.uid;

  AuthService() {
    try {
      _auth.authStateChanges().listen((_) => notifyListeners());
    } catch (_) {}
  }

  Future<void> _ensureFirebase() async {
    if (Firebase.apps.isNotEmpty) return;
    await Firebase.initializeApp().timeout(const Duration(seconds: 10));
  }

  Future<void> signIn(String email, String password) async {
    await _ensureFirebase();
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> register(String email, String password) async {
    await _ensureFirebase();
    await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _ensureFirebase();
    await _auth.signOut();
  }

  Future<void> sendPasswordReset(String email) async {
    await _ensureFirebase();
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> deleteAccount() async {
    await _ensureFirebase();
    await currentUser?.delete();
  }

  /// Human-readable message from FirebaseAuthException codes.
  static String friendlyError(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':       return 'No account found with that email.';
        case 'wrong-password':       return 'Incorrect password.';
        case 'email-already-in-use': return 'An account already exists with that email.';
        case 'invalid-email':        return 'Please enter a valid email address.';
        case 'weak-password':        return 'Password must be at least 6 characters.';
        case 'network-request-failed': return 'No internet connection.';
        case 'too-many-requests':    return 'Too many attempts. Please try again later.';
        default:
          return 'Error: ${e.code}. Please try again.';
      }
    }
    return 'Error: $e';
  }
}
