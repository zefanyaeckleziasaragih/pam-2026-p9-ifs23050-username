import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_notifier.dart';
import 'providers/auth_provider.dart';
import 'providers/username_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/usernames/username_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UsernameProvider()),
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
      ],
      child: Consumer<ThemeNotifier>(
        builder: (context, theme, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "UsernameAI",
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: theme.themeMode,
            home: const _AppRoot(),
          );
        },
      ),
    );
  }
}

class _AppRoot extends StatelessWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return auth.isAuthenticated ? const UsernameScreen() : const LoginScreen();
  }
}
