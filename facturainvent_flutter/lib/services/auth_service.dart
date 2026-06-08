import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mantiene una sesión anónima (la app actual usa CloudKit sin login,
/// así que el equivalente más cercano es Firebase Anonymous Auth).
/// Más adelante se puede vincular con Apple/Google sign-in.
class AuthService {
  final FirebaseAuth _auth;

  AuthService(this._auth);

  Future<User> ensureSignedIn() async {
    final user = _auth.currentUser;
    if (user != null) return user;
    final cred = await _auth.signInAnonymously();
    return cred.user!;
  }

  Stream<User?> authState() => _auth.authStateChanges();
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(FirebaseAuth.instance);
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authState();
});
