import 'package:flutter/material.dart';
import 'dart:math';

class SparklesBackground extends StatefulWidget {
  const SparklesBackground({super.key});

  @override
  State<SparklesBackground> createState() => _SparklesBackgroundState();
}

class _SparklesBackgroundState extends State<SparklesBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_SparkleData> _sparkles = [];
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    for (int i = 0; i < 20; i++) {
      _sparkles.add(
        _SparkleData(
          x: _rng.nextDouble(),
          y: _rng.nextDouble(),
          size: _rng.nextDouble() * 6 + 3,
          phase: _rng.nextDouble() * pi * 2,
          speed: _rng.nextDouble() * 0.5 + 0.5,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Stack(
          children: _sparkles.map((s) {
            final opacity =
                (sin(_controller.value * pi * 2 * s.speed + s.phase) + 1) / 2;
            return Positioned(
              left: s.x * size.width,
              top: s.y * size.height,
              child: Opacity(
                opacity: opacity * 0.8,
                child: Container(
                  width: s.size,
                  height: s.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFFD6E7),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6FB4).withValues(alpha: 0.6),
                        blurRadius: s.size * 2,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _SparkleData {
  final double x, y, size, phase, speed;
  _SparkleData({
    required this.x,
    required this.y,
    required this.size,
    required this.phase,
    required this.speed,
  });
}
