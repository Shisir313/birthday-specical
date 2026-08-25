import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'binita_screen.dart';

class SurpriseScreen extends StatefulWidget {
  const SurpriseScreen({super.key});

  @override
  State<SurpriseScreen> createState() => _SurpriseScreenState();
}

class _SurpriseScreenState extends State<SurpriseScreen>
    with TickerProviderStateMixin {
  // ── Phases ──────────────────────────────────────
  // 0 = idle, 1 = shaking, 2 = cracking, 3 = exploding, 4 = done
  int _phase = 0;
  int _tapCount = 0;

  // ── Controllers ─────────────────────────────────
  late AnimationController _shakeCtrl;
  late AnimationController _crackCtrl;
  late AnimationController _explodeCtrl;
  late AnimationController _glowCtrl;
  late AnimationController _floatCtrl;
  late AnimationController _ribbonCtrl;

  late Animation<double> _shake;
  late Animation<double> _crack; // 0→1 lid opens
  late Animation<double> _explodeScale; // box scales up then fades
  late Animation<double> _glow;
  late Animation<double> _floatY;
  late Animation<double> _ribbonWave;

  late ConfettiController _confetti1;
  late ConfettiController _confetti2;
  late ConfettiController _confetti3;

  // floating emojis that burst out
  final List<_FloatingEmoji> _floaters = [];
  final _rand = Random();

  @override
  void initState() {
    super.initState();

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _shake = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -14), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -14, end: 14), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 14, end: -10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));

    _crackCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _crack = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _crackCtrl, curve: Curves.easeOut));

    _explodeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _explodeScale = Tween<double>(
      begin: 1.0,
      end: 2.2,
    ).animate(CurvedAnimation(parent: _explodeCtrl, curve: Curves.easeIn));

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _glow = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _floatY = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    _ribbonCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _ribbonWave = Tween<double>(
      begin: -0.05,
      end: 0.05,
    ).animate(CurvedAnimation(parent: _ribbonCtrl, curve: Curves.easeInOut));

    _confetti1 = ConfettiController(duration: const Duration(seconds: 4));
    _confetti2 = ConfettiController(duration: const Duration(seconds: 4));
    _confetti3 = ConfettiController(duration: const Duration(seconds: 4));
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    _crackCtrl.dispose();
    _explodeCtrl.dispose();
    _glowCtrl.dispose();
    _floatCtrl.dispose();
    _ribbonCtrl.dispose();
    _confetti1.dispose();
    _confetti2.dispose();
    _confetti3.dispose();
    super.dispose();
  }

  // ── Tap handler ─────────────────────────────────
  Future<void> _onTap() async {
    if (_phase == 3 || _phase == 4) return;

    _tapCount++;

    if (_tapCount == 1) {
      // Phase 1 – shake
      setState(() => _phase = 1);
      await _shakeCtrl.forward(from: 0);
      _shakeCtrl.reset();
    } else if (_tapCount == 2) {
      // Phase 2 – crack open
      setState(() => _phase = 2);
      await _crackCtrl.forward();
    } else if (_tapCount >= 3) {
      // Phase 3 – explode!
      setState(() => _phase = 3);
      _spawnFloaters();
      _confetti1.play();
      _confetti2.play();
      _confetti3.play();
      await _explodeCtrl.forward();
      // Navigate to main screen
      if (!mounted) return;
      setState(() => _phase = 4);
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 900),
          pageBuilder: (_, __, ___) => const BinitaScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    }
  }

  void _spawnFloaters() {
    const emojis = ['🎉', '🎊', '🌸', '💖', '✨', '🎂', '👑', '🦋', '💫', '🌟'];
    for (int i = 0; i < 14; i++) {
      _floaters.add(
        _FloatingEmoji(
          emoji: emojis[_rand.nextInt(emojis.length)],
          x: _rand.nextDouble(),
          delay: _rand.nextDouble() * 400,
          size: 20 + _rand.nextDouble() * 22,
        ),
      );
    }
    setState(() {});
  }

  // ── Hint text per phase ─────────────────────────
  String get _hintText {
    switch (_phase) {
      case 0:
        return 'Tap the gift to start ✨';
      case 1:
        return 'Something is inside… tap again 🎁';
      case 2:
        return "It's opening! One more tap 💫";
      case 3:
        return 'Surprise! 🎉';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0517),
      body: Stack(
        children: [
          // ── Background ──
          _buildBackground(),

          // ── Floating emojis burst ──
          if (_phase == 3)
            ..._floaters.map((f) => _FloatingEmojiWidget(data: f, size: size)),

          // ── Confetti ──
          Align(
            alignment: Alignment.topLeft,
            child: ConfettiWidget(
              confettiController: _confetti1,
              blastDirection: pi / 4,
              numberOfParticles: 30,
              colors: const [
                Color(0xFFFF3CAC),
                Color(0xFFFFD700),
                Color(0xFF784BA0),
                Color(0xFF38EF7D),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti2,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 40,
              colors: const [
                Color(0xFFFF6FB4),
                Color(0xFFFFE66D),
                Color(0xFF2B86C5),
                Color(0xFFF093FB),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: ConfettiWidget(
              confettiController: _confetti3,
              blastDirection: 3 * pi / 4,
              numberOfParticles: 30,
              colors: const [
                Color(0xFFFF3CAC),
                Color(0xFFFFD700),
                Color(0xFF11998E),
                Color(0xFFFF6B35),
              ],
            ),
          ),

          // ── Main content ──
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

                // ── "A surprise for you" heading ──
                _buildHeading(),

                const Spacer(flex: 1),

                // ── The gift box ──
                _buildGiftBox(),

                const Spacer(flex: 1),

                // ── Tap hint ──
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    _hintText,
                    key: ValueKey(_phase),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white54,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // ── Tap dots indicator ──
                _buildDots(),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Background ──────────────────────────────────
  Widget _buildBackground() {
    return AnimatedBuilder(
      animation: _glow,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.2),
            radius: 1.2,
            colors: [
              const Color(0xFF3D0B6E).withValues(alpha: _glow.value * 0.6),
              const Color(0xFF1A0530),
              const Color(0xFF0D0517),
            ],
          ),
        ),
      ),
    );
  }

  // ── Heading ─────────────────────────────────────
  Widget _buildHeading() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (b) => const LinearGradient(
            colors: [Color(0xFFFF3CAC), Color(0xFFFFD6E7), Color(0xFFFF6FB4)],
          ).createShader(b),
          child: Text(
            '🎁  A Surprise  🎁',
            style: GoogleFonts.pacifico(fontSize: 28, color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'specially wrapped for you',
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.white38),
        ),
      ],
    );
  }

  // ── Gift box ────────────────────────────────────
  Widget _buildGiftBox() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _shake,
        _crack,
        _explodeScale,
        _glow,
        _floatY,
        _ribbonWave,
      ]),
      builder: (_, __) {
        // Phase 3: scale up and fade
        if (_phase == 3) {
          return Opacity(
            opacity: (1 - _explodeCtrl.value).clamp(0.0, 1.0),
            child: Transform.scale(
              scale: _explodeScale.value,
              child: _giftBoxGraphic(),
            ),
          );
        }

        // Phase 0-2: float + shake
        return Transform.translate(
          offset: Offset(_shake.value, _floatY.value),
          child: GestureDetector(onTap: _onTap, child: _giftBoxGraphic()),
        );
      },
    );
  }

  Widget _giftBoxGraphic() {
    final lidAngle = -_crack.value * (pi / 2.2); // lid tilts back on crack
    final lidOffsetY = _crack.value * -30.0;

    return SizedBox(
      width: 220,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Glow behind box ──
          AnimatedBuilder(
            animation: _glow,
            builder: (_, __) => Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(
                      0xFFFF3CAC,
                    ).withValues(alpha: _glow.value * 0.45),
                    blurRadius: 60,
                    spreadRadius: 20,
                  ),
                  BoxShadow(
                    color: const Color(
                      0xFF784BA0,
                    ).withValues(alpha: _glow.value * 0.3),
                    blurRadius: 90,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),

          // ── Box body ──
          Positioned(
            bottom: 0,
            child: CustomPaint(
              size: const Size(180, 140),
              painter: _BoxBodyPainter(),
            ),
          ),

          // ── Ribbon vertical (on body) ──
          Positioned(
            bottom: 0,
            child: SizedBox(
              width: 180,
              height: 140,
              child: Center(
                child: Container(
                  width: 22,
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFFF3CAC).withValues(alpha: 0.9),
                        const Color(0xFFFF6FB4).withValues(alpha: 0.9),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Lid (animates open) ──
          Positioned(
            top: 0,
            child: Transform(
              alignment: Alignment.bottomCenter,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(lidAngle)
                ..translate(0.0, lidOffsetY),
              child: CustomPaint(
                size: const Size(192, 50),
                painter: _LidPainter(),
              ),
            ),
          ),

          // ── Ribbon horizontal (on lid) ──
          Positioned(
            top: 0,
            child: Transform(
              alignment: Alignment.bottomCenter,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(lidAngle)
                ..translate(0.0, lidOffsetY),
              child: SizedBox(
                width: 192,
                height: 50,
                child: Center(
                  child: Container(
                    width: 192,
                    height: 22,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFF3CAC).withValues(alpha: 0.9),
                          const Color(0xFFFF6FB4).withValues(alpha: 0.9),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Bow on top of lid ──
          Positioned(
            top: 0,
            child: Transform(
              alignment: Alignment.bottomCenter,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(lidAngle)
                ..translate(0.0, lidOffsetY - 28),
              child: Transform.rotate(
                angle: _ribbonWave.value,
                child: CustomPaint(
                  size: const Size(80, 56),
                  painter: _BowPainter(),
                ),
              ),
            ),
          ),

          // ── Stars popping out when cracked ──
          if (_phase >= 2) ..._burstStars(),
        ],
      ),
    );
  }

  List<Widget> _burstStars() {
    const positions = [
      Offset(-60, -60),
      Offset(60, -60),
      Offset(-80, 0),
      Offset(80, 0),
      Offset(-50, -90),
      Offset(50, -90),
    ];
    const emojis = ['✨', '💫', '🌟', '💖', '🎉', '🌸'];
    return List.generate(positions.length, (i) {
      return AnimatedBuilder(
        animation: _crackCtrl,
        builder: (_, __) => Positioned(
          left: 110 + positions[i].dx * _crackCtrl.value,
          top: 90 + positions[i].dy * _crackCtrl.value,
          child: Opacity(
            opacity: _crackCtrl.value,
            child: Text(
              emojis[i],
              style: TextStyle(fontSize: 18 + (i % 3) * 4.0),
            ),
          ),
        ),
      );
    });
  }

  // ── Tap progress dots ───────────────────────────
  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final done = _tapCount > i;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: done ? 24 : 10,
          height: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            gradient: done
                ? const LinearGradient(
                    colors: [Color(0xFFFF3CAC), Color(0xFF784BA0)],
                  )
                : null,
            color: done ? null : Colors.white.withValues(alpha: 0.15),
            boxShadow: done
                ? [
                    BoxShadow(
                      color: const Color(0xFFFF3CAC).withValues(alpha: 0.5),
                      blurRadius: 8,
                    ),
                  ]
                : [],
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────
// Floating emoji that bursts out
// ─────────────────────────────────────────────────
class _FloatingEmoji {
  final String emoji;
  final double x; // 0..1 horizontal position
  final double delay; // ms
  final double size;
  _FloatingEmoji({
    required this.emoji,
    required this.x,
    required this.delay,
    required this.size,
  });
}

class _FloatingEmojiWidget extends StatefulWidget {
  final _FloatingEmoji data;
  final Size size;
  const _FloatingEmojiWidget({required this.data, required this.size});

  @override
  State<_FloatingEmojiWidget> createState() => _FloatingEmojiWidgetState();
}

class _FloatingEmojiWidgetState extends State<_FloatingEmojiWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _y;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _y = Tween<double>(
      begin: 0.6,
      end: -0.2,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _opacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 3),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 2),
    ]).animate(_ctrl);

    Future.delayed(Duration(milliseconds: widget.data.delay.toInt()), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Positioned(
        left: widget.data.x * widget.size.width,
        top: _y.value * widget.size.height,
        child: Opacity(
          opacity: _opacity.value,
          child: Text(
            widget.data.emoji,
            style: TextStyle(fontSize: widget.data.size),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// CustomPainters for gift box
// ─────────────────────────────────────────────────
class _BoxBodyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Main box
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF3D0B6E), Color(0xFF2D0B4E), Color(0xFF1A0530)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final rr = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(16),
    );
    canvas.drawRRect(rr, bodyPaint);

    // Border
    final borderPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF3CAC), Color(0xFF784BA0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRRect(rr, borderPaint);

    // Polka dots
    final dotPaint = Paint()..color = const Color(0xFFFF3CAC).withOpacity(0.12);
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 5; col++) {
        if ((row + col) % 2 == 0) continue;
        canvas.drawCircle(
          Offset(20 + col * 35.0, 20 + row * 32.0),
          7,
          dotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_BoxBodyPainter _) => false;
}

class _LidPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF5B0FA0), Color(0xFF3D0B6E)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final rr = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(10),
    );
    canvas.drawRRect(rr, paint);

    final border = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF3CAC), Color(0xFF784BA0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRRect(rr, border);
  }

  @override
  bool shouldRepaint(_LidPainter _) => false;
}

class _BowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFF6FB4), Color(0xFFFF3CAC)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Left loop
    final leftPath = Path()
      ..moveTo(cx, cy)
      ..cubicTo(cx - 10, cy - 30, cx - 50, cy - 30, cx - 38, cy - 5)
      ..cubicTo(cx - 25, cy + 5, cx - 10, cy - 5, cx, cy);
    canvas.drawPath(leftPath, paint);

    // Right loop
    final rightPath = Path()
      ..moveTo(cx, cy)
      ..cubicTo(cx + 10, cy - 30, cx + 50, cy - 30, cx + 38, cy - 5)
      ..cubicTo(cx + 25, cy + 5, cx + 10, cy - 5, cx, cy);
    canvas.drawPath(rightPath, paint);

    // Knot circle
    canvas.drawCircle(Offset(cx, cy), 10, paint);

    // Tails
    final tailPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF3CAC), Color(0xFFFF6FB4)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(cx - 6, cy + 8),
      Offset(cx - 18, cy + 30),
      tailPaint,
    );
    canvas.drawLine(
      Offset(cx + 6, cy + 8),
      Offset(cx + 18, cy + 30),
      tailPaint,
    );
  }

  @override
  bool shouldRepaint(_BowPainter _) => false;
}
