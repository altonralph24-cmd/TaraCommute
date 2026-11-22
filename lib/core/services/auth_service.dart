import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  static const String authRedirectUrl =
      'com.bueraglobal.taracommute://login-callback';

  User? get currentUser => _client.auth.currentUser;

  bool get isLoggedIn => currentUser != null;

  bool get isEmailVerified =>
      currentUser?.emailConfirmedAt != null;

  String? get currentUserEmail => currentUser?.email;

  String? get currentUserFullName {
    final metadata = currentUser?.userMetadata;
    return metadata?['full_name'] as String?;
  }

  Future<AuthResponse> register({
    required String email,
    required String password,
    String? fullName,
  }) async {
    final trimmedName = fullName?.trim();

    return await _client.auth.signUp(
      email: email.trim(),
      password: password,
      emailRedirectTo: authRedirectUrl,
      data: trimmedName == null || trimmedName.isEmpty
          ? null
          : {
              'full_name': trimmedName,
            },
    );
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> resetPassword({
    required String email,
  }) async {
    await _client.auth.resetPasswordForEmail(
      email.trim(),
      redirectTo: authRedirectUrl,
    );
  }

  Future<void> resendVerificationEmail({
    required String email,
  }) async {
    await _client.auth.resend(
      type: OtpType.signup,
      email: email.trim(),
      emailRedirectTo: authRedirectUrl,
    );
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }

  Stream<AuthState> get authStateChanges {
    return _client.auth.onAuthStateChange;
  }
}
