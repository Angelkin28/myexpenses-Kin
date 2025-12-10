import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/lottie_loader.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Navigate after 2 seconds
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(seconds: 2));
      if (context.mounted) {
        context.go('/login');
      }
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LottieLoader(
              assetName: 'Money.lottie', 
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
