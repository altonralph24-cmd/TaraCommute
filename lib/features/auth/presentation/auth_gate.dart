
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/auth_service.dart';
import 'login_page.dart';

class AuthGate extends StatelessWidget {
  final Widget authenticatedPage;

  const AuthGate({
    super.key,
    required this.authenticatedPage,
  });

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<AuthState>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        final session = snapshot.data?.session ??
            Supabase.instance.client.auth.currentSession;

        if (session != null) {
          return authenticatedPage;
        }

        return const LoginPage();
      },
    );
  }
}
