import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

class BirthdayConfetti extends StatelessWidget {
  final ConfettiController controller;

  const BirthdayConfetti({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ConfettiWidget(
      confettiController: controller,
      blastDirection: pi / 2,
      emissionFrequency: 0.05,
      numberOfParticles: 20,
      gravity: 0.1,
      shouldLoop: false,
      blastDirectionality: BlastDirectionality.explosive,
      colors: const [
        Color(0xFFFF6B9D),
        Color(0xFFFFE66D),
        Color(0xFF4ECDC4),
        Color(0xFFFF6B35),
        Color(0xFFA8EDEA),
        Color(0xFFFED9B7),
      ],
    );
  }
}
