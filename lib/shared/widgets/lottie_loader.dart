import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieLoader extends StatefulWidget {
  final String assetName;
  final double height;
  final double? width;
  final BoxFit fit;
  final Widget? fallback;
  final bool repeat;
  final bool animate;
  final bool playOnce;

  const LottieLoader({
    super.key,
    required this.assetName,
    this.height = 200,
    this.width,
    this.fit = BoxFit.contain,
    this.fallback,
    this.repeat = false,
    this.animate = true,
    this.playOnce = false,
  });

  @override
  State<LottieLoader> createState() => _LottieLoaderState();
}

class _LottieLoaderState extends State<LottieLoader>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/lottie/${widget.assetName}',
      height: widget.height,
      width: widget.width,
      fit: widget.fit,
      repeat: widget.repeat,
      animate: widget.animate && !widget.playOnce,
      controller: widget.playOnce
          ? (_controller ??= AnimationController(vsync: this))
          : null,
      onLoaded: (composition) {
        if (widget.playOnce) {
          try {
            _controller ??= AnimationController(vsync: this);
            _controller?.duration = composition.duration;
            _controller?.forward();
          } catch (e) {
            print('Lottie playOnce error: $e');
          }
        }
      },
      errorBuilder: (context, error, stackTrace) {
        print('Error loading Lottie: $error');
        return widget.fallback ??
            const SizedBox(height: 200, child: CircularProgressIndicator());
      },
    );
  }
}
