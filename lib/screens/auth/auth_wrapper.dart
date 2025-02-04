import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/user_settings_provider.dart';
import 'login_screen.dart';
import '../main_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (authProvider.isAuthenticated) {
          // We are authenticated
          return const MainScreen();
        }

        // Not authenticated
        return const LoginScreen();
        }
      },
    );
  }
}
