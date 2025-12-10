import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieLoader extends StatelessWidget {
  final String assetName;
  final double height;
  final Widget? fallback;

  const LottieLoader({
    super.key,
    required this.assetName,
    this.height = 200,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/lottie/$assetName',
      height: height,
      errorBuilder: (context, error, stackTrace) {
        return fallback ?? const CircularProgressIndicator();
      },
    );
  }
}
