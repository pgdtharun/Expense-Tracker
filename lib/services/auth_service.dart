import 'package:firebase_auth/firebase_auth.dart';

/// Wraps Firebase Anonymous Authentication.
///
/// Anonymous auth is used (rather than a login screen) so the app is
/// self-contained for a demo/review, while still giving every install a
/// stable, unique [User.uid]. Expenses are scoped to that uid in Firestore
/// so multiple people running this app against the same Firebase project
/// don't see each other's data.
class AuthService {
  final FirebaseAuth _auth;

  AuthService({FirebaseAuth? firebaseAuth})
      : _auth = firebaseAuth ?? FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Signs the device in anonymously if it isn't already signed in.
  /// Returns the resulting [User].
  Future<User> ensureSignedIn() async {
    final existing = _auth.currentUser;
    if (existing != null) return existing;

    final credential = await _auth.signInAnonymously();
    final user = credential.user;
    if (user == null) {
      throw StateError('Anonymous sign-in succeeded but returned no user.');
    }
    return user;
  }
}
