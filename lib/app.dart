import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_colors.dart';
import 'screens/splash/splash_screen.dart';

final _router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final onSplash = state.uri.path == '/';
    final onAuth = state.uri.path.startsWith('/auth');

    if (session == null && !onSplash && !onAuth) return '/auth/login';
    if (session != null && onAuth) return '/home';
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    // Placeholders — real screens added per stage
    GoRoute(
      path: '/auth/login',
      builder: (context, state) => const _PlaceholderScreen(label: 'Login — Stage 1'),
    ),
    GoRoute(
      path: '/quiz',
      builder: (context, state) => const _PlaceholderScreen(label: 'Quiz — Stage 2'),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const _PlaceholderScreen(label: 'City Map — Stage 3'),
    ),
  ],
);

class MoneyRushApp extends StatelessWidget {
  const MoneyRushApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MoneyRush',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.surface,
        ),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

// ignore: use_key_in_widget_constructors
class _PlaceholderScreen extends StatelessWidget {
  final String label;
  const _PlaceholderScreen({required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
