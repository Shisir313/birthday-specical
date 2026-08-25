import 'package:flutter/material.dart';
import 'dart:math';

class GlowPhotoFrame extends StatelessWidget {
  final Widget child;
  final double glowIntensity;

  const GlowPhotoFrame({
    super.key,
    required this.child,
    required this.glowIntensity,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow ring
        Container(
          width: 210,
          height: 210,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFFFF3CAC,
                ).withValues(alpha: glowIntensity * 0.5),
                blurRadius: 40,
                spreadRadius: 10,
              ),
              BoxShadow(
                color: const Color(
                  0xFF784BA0,
                ).withValues(alpha: glowIntensity * 0.4),
                blurRadius: 60,
                spreadRadius: 15,
              ),
            ],
          ),
        ),

        // Rotating sparkle ring
        SizedBox(
          width: 220,
          height: 220,
          child: CustomPaint(painter: _SparkleRingPainter(glowIntensity)),
        ),

        // Gradient border circle
        Container(
          width: 190,
          height: 190,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const SweepGradient(
              colors: [
                Color(0xFFFF3CAC),
                Color(0xFFFFD6E7),
                Color(0xFF784BA0),
                Color(0xFFFF3CAC),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFFFF3CAC,
                ).withValues(alpha: glowIntensity * 0.6),
                blurRadius: 20,
                spreadRadius: 3,
              ),
            ],
          ),
        ),

        // White inner circle (clip area)
        ClipOval(
          child: Container(
            width: 176,
            height: 176,
            color: Colors.transparent,
            child: child,
          ),
        ),
      ],
    );
  }
}

class _SparkleRingPainter extends CustomPainter {
  final double intensity;
  _SparkleRingPainter(this.intensity);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFD6E7).withValues(alpha: intensity * 0.9)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    for (int i = 0; i < 12; i++) {
      final angle = (i / 12) * 2 * pi;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      canvas.drawCircle(Offset(x, y), 3, paint);
    }
  }

  @override
  bool shouldRepaint(_SparkleRingPainter old) => old.intensity != intensity;
}

/// Shows Binita's photo inside the glow frame.
class PhotoPlaceholder extends StatelessWidget {
  const PhotoPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        'assets/images/binita.jpg',
        width: 176,
        height: 176,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 176,
          height: 176,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2D0B4E), Color(0xFF784BA0), Color(0xFFFF3CAC)],
            ),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("🌸", style: TextStyle(fontSize: 52)),
              SizedBox(height: 4),
              Text(
                "B",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
