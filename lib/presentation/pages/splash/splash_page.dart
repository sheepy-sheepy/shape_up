// lib/presentation/pages/splash/splash_page.dart
import 'package:flutter/material.dart';
import 'package:shape_up/data/repositories/app_repository_provider.dart';
import 'package:shape_up/presentation/blocs/auth/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authState = context.read<AuthBloc>().state;

    if (authState.isAuthenticated && authState.user != null) {
      debugPrint('👤 User authenticated: ${authState.user!.email}');
      debugPrint(
          '👤 Has completed params from Supabase: ${authState.user!.hasCompletedInitialParams}');

      // Проверяем наличие всех необходимых данных
      final hasAllData = authState.user!.height != null &&
          authState.user!.weight != null &&
          authState.user!.birthDate != null;

      // Используем hasCompletedInitialParams из Supabase как основной источник
      if (authState.user!.hasCompletedInitialParams && hasAllData) {
        debugPrint('➡️ Redirecting to main page');
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        debugPrint('➡️ Redirecting to initial params page');
        Navigator.pushReplacementNamed(context, '/initial-params');
      }
    } else {
      debugPrint('➡️ Redirecting to login page');
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlutterLogo(size: 100),
            SizedBox(height: 24),
            Text(
              'Shape Up',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 48),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
