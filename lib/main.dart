import 'package:flutter/material.dart';

import 'core/auth/auth_session.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/account_switch_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const WheelApp());
}

class WheelApp extends StatelessWidget {
  const WheelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeLibre',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AuthSession.instance,
      builder: (context, _) {
        if (AuthSession.instance.isAuthenticated) {
          return const HomeScreen();
        }

        return const AccountSwitchScreen();
      },
    );
  }
}
