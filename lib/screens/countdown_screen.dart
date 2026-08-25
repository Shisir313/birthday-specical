import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'surprise_screen.dart';

// ── Unlock date: June 29 at midnight (00:00) ──────
final _unlockTime = DateTime(2026, 6, 29, 0, 0, 0);

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen>
    with TickerProviderStateMixin {
  late Timer _timer;
  Duration _remaining = Duration.zero;
  bool _unlocked = false;

  late AnimationController _glowCtrl;
  late AnimationController _floatCtrl;
  late AnimationController _sparkCtrl;
  late AnimationController _unlockCtrl;

  late Animation<double> _glow;
  late Animation<double> _floatY;
  late Animation<double> _sparkRotate;
  late Animation<double> _unlockScale;
  late Animation<double> _unlockFade;

  late ConfettiController _confetti1;
  late ConfettiController _confetti2;

  final _rand = Random();
  final List<_Star> _stars = [];

  @override
  void initState() {
    super.initState();

    // Generate background stars
    for (int i = 0; i < 60; i++) {
      _stars.add(
        _Star(
          x: _rand.nextDouble(),
          y: _rand.nextDouble(),
          size: 1.0 + _rand.nextDouble() * 2.5,
          opacity: 0.2 + _rand.nextDouble() * 0.6,
          phase: _rand.nextDouble() * 2 * pi,
        ),
      );
    }

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _glow = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _floatY = Tween<double>(
      begin: -12,
      end: 12,
    ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    _sparkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _sparkRotate = Tween<double>(begin: 0, end: 2 * pi).animate(_sparkCtrl);

    _unlockCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _unlockScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _unlockCtrl, curve: Curves.elasticOut));
    _unlockFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _unlockCtrl, curve: Curves.easeIn));

    _confetti1 = ConfettiController(duration: const Duration(seconds: 5));
    _confetti2 = ConfettiController(duration: const Duration(seconds: 5));

    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final now = DateTime.now();
    final diff = _unlockTime.difference(now);
    if (diff.isNegative) {
      if (!_unlocked) _onUnlock();
      if (mounted) setState(() => _remaining = Duration.zero);
    } else {
      if (mounted) setState(() => _remaining = diff);
    }
  }

  Future<void> _onUnlock() async {
    _unlocked = true;
    _confetti1.play();
    _confetti2.play();
    await _unlockCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 1000),
        pageBuilder: (_, __, ___) => const SurpriseScreen(),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(anim),
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _glowCtrl.dispose();
    _floatCtrl.dispose();
    _sparkCtrl.dispose();
    _unlockCtrl.dispose();
    _confetti1.dispose();
    _confetti2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF04010E),
      body: Stack(
        children: [
          // ── Starfield ──
          CustomPaint(
            size: size,
            painter: _StarfieldPainter(_stars, _glowCtrl.value),
          ),

          // ── Background radial glow ──
          AnimatedBuilder(
            animation: _glow,
            builder: (_, __) => Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.3),
                  radius: 1.1,
                  colors: [
                    const Color(
                      0xFF3D0B6E,
                    ).withValues(alpha: _glow.value * 0.5),
                    const Color(0xFF1A0530).withValues(alpha: 0.8),
                    const Color(0xFF04010E),
                  ],
                ),
              ),
            ),
          ),

          // ── Orbiting sparkles ──
          AnimatedBuilder(
            animation: _sparkRotate,
            builder: (_, __) => CustomPaint(
              size: size,
              painter: _OrbitPainter(_sparkRotate.value, _glow.value),
            ),
          ),

          // ── Confetti ──
          Align(
            alignment: Alignment.topLeft,
            child: ConfettiWidget(
              confettiController: _confetti1,
              blastDirection: pi / 4,
              numberOfParticles: 35,
              colors: const [
                Color(0xFFFF3CAC),
                Color(0xFFFFD700),
                Color(0xFF784BA0),
                Color(0xFF38EF7D),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: ConfettiWidget(
              confettiController: _confetti2,
              blastDirection: 3 * pi / 4,
              numberOfParticles: 35,
              colors: const [
                Color(0xFFFF6FB4),
                Color(0xFFFFE66D),
                Color(0xFF2B86C5),
                Color(0xFFF093FB),
              ],
            ),
          ),

          // ── Main content ──
          SafeArea(
            child: _unlocked ? _buildUnlockReveal() : _buildCountdown(size),
          ),
        ],
      ),
    );
  }

  // ── Countdown UI ────────────────────────────────
  Widget _buildCountdown(Size size) {
    final days = _remaining.inDays;
    final hours = _remaining.inHours.remainder(24);
    final minutes = _remaining.inMinutes.remainder(60);
    final seconds = _remaining.inSeconds.remainder(60);

    return Column(
      children: [
        const Spacer(flex: 2),

        // Lock icon with glow
        AnimatedBuilder(
          animation: _floatY,
          builder: (_, child) => Transform.translate(
            offset: Offset(0, _floatY.value),
            child: child,
          ),
          child: AnimatedBuilder(
            animation: _glow,
            builder: (_, __) => Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF3CAC), Color(0xFF784BA0)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(
                      0xFFFF3CAC,
                    ).withValues(alpha: _glow.value * 0.7),
                    blurRadius: 40,
                    spreadRadius: 8,
                  ),
                  BoxShadow(
                    color: const Color(
                      0xFF784BA0,
                    ).withValues(alpha: _glow.value * 0.4),
                    blurRadius: 70,
                    spreadRadius: 15,
                  ),
                ],
              ),
              child: const Icon(
                Icons.lock_rounded,
                color: Colors.white,
                size: 42,
              ),
            ),
          ),
        ),

        const SizedBox(height: 32),

        // "A Surprise for You" heading
        ShaderMask(
          shaderCallback: (b) => const LinearGradient(
            colors: [Color(0xFFFF3CAC), Color(0xFFFFD6E7), Color(0xFFFF6FB4)],
          ).createShader(b),
          child: Text(
            'A Surprise for You',
            style: GoogleFonts.pacifico(
              fontSize: 28,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),

        const SizedBox(height: 10),

        Text(
          'from Shisir  💖',
          style: GoogleFonts.greatVibes(
            fontSize: 26,
            color: const Color(0xFFFF6FB4).withValues(alpha: 0.85),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'unlocks on June 29 at midnight',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white30,
            letterSpacing: 0.5,
          ),
        ),

        const Spacer(flex: 1),

        // Countdown tiles
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _tile(days, 'DAYS'),
              _separator(),
              _tile(hours, 'HRS'),
              _separator(),
              _tile(minutes, 'MIN'),
              _separator(),
              _tile(seconds, 'SEC'),
            ],
          ),
        ),

        const Spacer(flex: 1),

        // Hint message
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xFFFF3CAC).withValues(alpha: 0.07),
              border: Border.all(
                color: const Color(0xFFFF3CAC).withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              '🎁  Something special is being wrapped for you.\nCome back on your birthday to open it! 🎂',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.6),
                height: 1.7,
              ),
            ),
          ),
        ),

        const Spacer(flex: 2),

        // Tiny footer
        Text(
          '✨  Happy Birthday Binita  ✨',
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.white24,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _tile(int value, String label) {
    return AnimatedBuilder(
      animation: _glow,
      builder: (_, __) => Container(
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF3D0B6E).withValues(alpha: 0.85),
              const Color(0xFF1A0530).withValues(alpha: 0.9),
            ],
          ),
          border: Border.all(
            color: const Color(0xFFFF3CAC).withValues(alpha: _glow.value * 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(
                0xFFFF3CAC,
              ).withValues(alpha: _glow.value * 0.2),
              blurRadius: 16,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value.toString().padLeft(2, '0'),
              style: GoogleFonts.poppins(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 9,
                color: const Color(0xFFFF6FB4).withValues(alpha: 0.8),
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _separator() {
    return AnimatedBuilder(
      animation: _glow,
      builder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text(
          ':',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: const Color(0xFFFF3CAC).withValues(alpha: _glow.value),
          ),
        ),
      ),
    );
  }

  // ── Unlock reveal ────────────────────────────────
  Widget _buildUnlockReveal() {
    return Center(
      child: AnimatedBuilder(
        animation: _unlockCtrl,
        builder: (_, child) => FadeTransition(
          opacity: _unlockFade,
          child: ScaleTransition(scale: _unlockScale, child: child),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 20),
            ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                colors: [Color(0xFFFF3CAC), Color(0xFFFFD6E7)],
              ).createShader(b),
              child: Text(
                'It\'s Time!',
                style: GoogleFonts.pacifico(fontSize: 36, color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your surprise is unlocking… 🎁',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.white60),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Star data + painters
// ─────────────────────────────────────────────────
class _Star {
  final double x, y, size, opacity, phase;
  const _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.phase,
  });
}

class _StarfieldPainter extends CustomPainter {
  final List<_Star> stars;
  final double time;
  _StarfieldPainter(this.stars, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in stars) {
      final twinkle = (sin(s.phase + time * 3) * 0.3 + 0.7).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: s.opacity * twinkle)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        s.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StarfieldPainter old) => true;
}

class _OrbitPainter extends CustomPainter {
  final double angle;
  final double glow;
  _OrbitPainter(this.angle, this.glow);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.32;
    final orbitR = size.width * 0.38;

    final sparkles = [
      (0.0, '✨', 14.0),
      (pi * 0.5, '🌸', 12.0),
      (pi, '💫', 14.0),
      (pi * 1.5, '💖', 12.0),
      (pi * 0.25, '⭐', 10.0),
      (pi * 0.75, '🌟', 10.0),
      (pi * 1.25, '✦', 10.0),
      (pi * 1.75, '✦', 10.0),
    ];

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (final s in sparkles) {
      final a = angle + s.$1;
      final x = cx + orbitR * cos(a);
      final y = cy + orbitR * sin(a) * 0.35; // elliptical orbit
      textPainter.text = TextSpan(
        text: s.$3 > 11 ? s.$2 : '✦',
        style: TextStyle(
          fontSize: s.$3,
          color: Colors.white.withValues(alpha: glow * 0.5),
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(_OrbitPainter old) => true;
}
