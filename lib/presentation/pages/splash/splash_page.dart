// lib/presentation/pages/splash/splash_page.dart
import 'package:flutter/material.dart';
import 'package:shape_up/presentation/pages/auth/login_page.dart';
import 'package:shape_up/presentation/pages/onboarding/initial_params_page.dart';
import 'package:shape_up/presentation/pages/main/main_page.dart';

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
    // Имитация загрузки
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    // В реальном приложении здесь будет проверка из SharedPreferences
    final isAuthenticated = false;
    final hasCompletedParams = false;
    
    if (isAuthenticated) {
      if (hasCompletedParams) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const InitialParamsPage()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
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