import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  // Get the currently signed-in user.
  User? get currentUser => _client.auth.currentUser;

  // Check whether a user is signed in.
  bool get isLoggedIn => currentUser != null;

  // Register a new user using email and password.
  Future<AuthResponse> register({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(
      email: email.trim(),
      password: password,
    );
  }

  // Sign in an existing user.
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  // Send a password reset email.
  Future<void> resetPassword({
    required String email,
  }) async {
    await _client.auth.resetPasswordForEmail(
      email.trim(),
    );
  }

  // Sign out the current user.
  Future<void> logout() async {
    await _client.auth.signOut();
  }

  // Listen for authentication changes.
  Stream<AuthState> get authStateChanges {
    return _client.auth.onAuthStateChange;
  }
}
