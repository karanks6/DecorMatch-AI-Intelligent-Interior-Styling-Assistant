import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Stream of auth state changes (logged in / logged out)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Currently signed-in user (or null)
  User? get currentUser => _auth.currentUser;

  /// Sign up with email and password
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Sign in with email and password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Send password reset email
  Future<void> resetPassword({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
