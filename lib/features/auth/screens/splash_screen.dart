import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/lottie_loader.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Simulate Lottie animation time (2s)
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    // In real app, check auth status here
    // For now, go to Login
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LottieLoader(
              assetName: 'loading.json', 
              fallback: const CircularProgressIndicator(),
            ),
            const SizedBox(height: 16),
             const Text('MyExpenses', style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF6C63FF)
             )),
          ],
        ),
      ),
    );
  }
}
