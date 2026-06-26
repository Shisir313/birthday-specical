import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';

// ─────────────────────────────────────────────────
// Quiz data
// ─────────────────────────────────────────────────
class _Q {
  final String question;
  final List<String> options;
  final int correct; // index into options
  final String hint;

  const _Q({
    required this.question,
    required this.options,
    required this.correct,
    required this.hint,
  });
}

const _questions = [
  _Q(
    question: "Where's your favourite place to eat keema noodles? 🍜",
    options: ["Momo Mania", "Binus", "Foodzone", "Street Corner"],
    correct: 1,
    hint: "Think of your campus canteen days 😏",
  ),
  _Q(
    question: "Where did you first meet your friend? 🤝",
    options: ["Library", "Megha", "Canteen", "Online"],
    correct: 1,
    hint: "It's a place with a name, not a thing 😊",
  ),
  _Q(
    question: "What's your most favourite relationship in the world? 💞",
    options: ["Friends", "Partner", "Family", "Herself"],
    correct: 2,
    hint: "Blood is thicker than water 🥰",
  ),
];

// ─────────────────────────────────────────────────
// VirtualHugSection — full widget
// ─────────────────────────────────────────────────
class VirtualHugSection extends StatefulWidget {
  const VirtualHugSection({super.key});

  @override
  State<VirtualHugSection> createState() => _VirtualHugSectionState();
}

class _VirtualHugSectionState extends State<VirtualHugSection>
    with TickerProviderStateMixin {
  // 0 = intro, 1 = quiz, 2 = hug
  int _stage = 0;
  int _qIndex = 0;
  int _score = 0;
  int? _selected;
  bool _answered = false;
  bool _wrongShake = false;

  late AnimationController _glowCtrl;
  late AnimationController _hugCtrl;
  late AnimationController _shakeCtrl;
  late AnimationController _slideCtrl;

  late Animation<double> _glow;
  late Animation<double> _hugScale;
  late Animation<double> _hugBounce;
  late Animation<double> _shake;
  late Animation<Offset> _slide;

  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _glow = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    _hugCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _hugScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _hugCtrl, curve: Curves.elasticOut));
    _hugBounce = Tween<double>(
      begin: 1.0,
      end: 1.12,
    ).animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shake = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -12), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -12, end: 12), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 12, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: 0), weight: 1),
    ]).animate(_shakeCtrl);

    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _slide = Tween<Offset>(
      begin: const Offset(1.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));

    _confetti = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _hugCtrl.dispose();
    _shakeCtrl.dispose();
    _slideCtrl.dispose();
    _confetti.dispose();
    super.dispose();
  }

  // ── Quiz logic ──────────────────────────────────
  void _startQuiz() {
    setState(() {
      _stage = 1;
      _qIndex = 0;
      _score = 0;
      _selected = null;
      _answered = false;
    });
    _slideCtrl.forward(from: 0);
  }

  Future<void> _onOptionTap(int idx) async {
    if (_answered) return;
    final correct = _questions[_qIndex].correct;
    setState(() {
      _selected = idx;
      _answered = true;
    });

    if (idx == correct) {
      _score++;
    } else {
      setState(() => _wrongShake = true);
      await _shakeCtrl.forward(from: 0);
      setState(() => _wrongShake = false);
    }

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    if (_qIndex < _questions.length - 1) {
      setState(() {
        _qIndex++;
        _selected = null;
        _answered = false;
      });
      _slideCtrl.forward(from: 0);
    } else {
      // All done
      setState(() => _stage = 2);
      _hugCtrl.forward(from: 0);
      _confetti.play();
    }
  }

  // ── Build ────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSectionHeader(),
        const SizedBox(height: 20),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: _stage == 0
              ? _buildIntro()
              : _stage == 1
              ? _buildQuiz()
              : _buildHug(),
        ),
      ],
    );
  }

  // ── Section header ──────────────────────────────
  Widget _buildSectionHeader() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (b) => const LinearGradient(
            colors: [Color(0xFFFF6FB4), Color(0xFFFFD6E7), Color(0xFFFF3CAC)],
          ).createShader(b),
          child: Text(
            '🤗  Virtual Hug  🤗',
            style: GoogleFonts.pacifico(fontSize: 24, color: Colors.white),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'only Bishakha can unlock this 🔐',
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.white30),
        ),
      ],
    );
  }

  // ── Intro card ──────────────────────────────────
  Widget _buildIntro() {
    return AnimatedBuilder(
      animation: _glow,
      builder: (_, __) => Container(
        key: const ValueKey('intro'),
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFF6FB4).withValues(alpha: 0.18),
              const Color(0xFF784BA0).withValues(alpha: 0.12),
            ],
          ),
          border: Border.all(
            color: const Color(0xFFFF6FB4).withValues(alpha: _glow.value * 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(
                0xFFFF3CAC,
              ).withValues(alpha: _glow.value * 0.18),
              blurRadius: 30,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          children: [
            // Big hug emoji
            Transform.scale(
              scale: _hugBounce.value,
              child: const Text('🤗', style: TextStyle(fontSize: 64)),
            ),
            const SizedBox(height: 16),
            Text(
              'Hey Bishakha! 🌸',
              style: GoogleFonts.pacifico(fontSize: 20, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              'There\'s a warm virtual hug waiting for you!\nBut first — answer 3 questions\nabout your own life to unlock it 🔐\n\nOnly YOU would know these answers 💖',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.7),
                height: 1.7,
              ),
            ),
            const SizedBox(height: 24),
            // Start button
            GestureDetector(
              onTap: _startQuiz,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 36,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF3CAC), Color(0xFF784BA0)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF3CAC).withValues(alpha: 0.45),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🧠', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Text(
                      'Start the Quiz',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Quiz card ───────────────────────────────────
  Widget _buildQuiz() {
    final q = _questions[_qIndex];

    return SlideTransition(
      position: _slide,
      child: Container(
        key: ValueKey(_qIndex),
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF2D0B4E).withValues(alpha: 0.9),
              const Color(0xFF1A0530).withValues(alpha: 0.95),
            ],
          ),
          border: Border.all(
            color: const Color(0xFFFF6FB4).withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF3CAC).withValues(alpha: 0.2),
              blurRadius: 25,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress row
            Row(
              children: [
                ...List.generate(_questions.length, (i) {
                  final done = i < _qIndex;
                  final active = i == _qIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(right: 6),
                    width: active ? 28 : 10,
                    height: 10,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      gradient: done || active
                          ? const LinearGradient(
                              colors: [Color(0xFFFF3CAC), Color(0xFF784BA0)],
                            )
                          : null,
                      color: done || active
                          ? null
                          : Colors.white.withValues(alpha: 0.15),
                    ),
                  );
                }),
                const Spacer(),
                Text(
                  'Q${_qIndex + 1} / ${_questions.length}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Question
            AnimatedBuilder(
              animation: _shake,
              builder: (_, child) => Transform.translate(
                offset: Offset(_wrongShake ? _shake.value : 0, 0),
                child: child,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: const Color(0xFFFF3CAC).withValues(alpha: 0.1),
                  border: Border.all(
                    color: const Color(0xFFFF3CAC).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  q.question,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.92),
                    height: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Options
            ...List.generate(q.options.length, (i) {
              return _buildOption(i, q.options[i], q.correct);
            }),

            // Hint (shown after wrong answer)
            if (_answered && _selected != q.correct) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFFFFD700).withValues(alpha: 0.1),
                  border: Border.all(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        q.hint,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFFFFD700).withValues(alpha: 0.8),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOption(int idx, String label, int correctIdx) {
    Color borderColor = Colors.white.withValues(alpha: 0.12);
    Color bgColor = Colors.white.withValues(alpha: 0.05);
    Widget? trailingIcon;

    if (_answered && _selected == idx) {
      if (idx == correctIdx) {
        borderColor = const Color(0xFF38EF7D);
        bgColor = const Color(0xFF38EF7D).withValues(alpha: 0.12);
        trailingIcon = const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF38EF7D),
          size: 20,
        );
      } else {
        borderColor = const Color(0xFFFF3CAC);
        bgColor = const Color(0xFFFF3CAC).withValues(alpha: 0.12);
        trailingIcon = const Icon(
          Icons.cancel_rounded,
          color: Color(0xFFFF3CAC),
          size: 20,
        );
      }
    } else if (_answered && idx == correctIdx) {
      // Show correct answer even when wrong was selected
      borderColor = const Color(0xFF38EF7D).withValues(alpha: 0.5);
      bgColor = const Color(0xFF38EF7D).withValues(alpha: 0.07);
      trailingIcon = Icon(
        Icons.check_circle_outline_rounded,
        color: const Color(0xFF38EF7D).withValues(alpha: 0.7),
        size: 18,
      );
    }

    return GestureDetector(
      onTap: () => _onOptionTap(idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: bgColor,
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            // Letter badge
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + idx), // A B C D
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.88),
                  fontWeight: _answered && idx == correctIdx
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            ),
            if (trailingIcon != null) trailingIcon,
          ],
        ),
      ),
    );
  }

  // ── Hug reveal ──────────────────────────────────
  Widget _buildHug() {
    final perfect = _score == _questions.length;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // Confetti
        ConfettiWidget(
          confettiController: _confetti,
          blastDirectionality: BlastDirectionality.explosive,
          numberOfParticles: 35,
          colors: const [
            Color(0xFFFF3CAC),
            Color(0xFFFFD700),
            Color(0xFF784BA0),
            Color(0xFF38EF7D),
            Color(0xFFFF6FB4),
            Color(0xFF2B86C5),
          ],
        ),

        ScaleTransition(
          scale: _hugScale,
          child: Container(
            key: const ValueKey('hug'),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3D0B6E), Color(0xFF1A0530)],
              ),
              border: Border.all(
                color: const Color(0xFFFF3CAC).withValues(alpha: 0.6),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF3CAC).withValues(alpha: 0.35),
                  blurRadius: 40,
                  spreadRadius: 6,
                ),
              ],
            ),
            child: Column(
              children: [
                // Score badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF3CAC), Color(0xFF784BA0)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    perfect
                        ? '🏆 Perfect Score! $_score/${_questions.length}'
                        : '⭐ Score: $_score/${_questions.length}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Animated hug emoji
                AnimatedBuilder(
                  animation: _glowCtrl,
                  builder: (_, __) => Transform.scale(
                    scale: 1.0 + (_glow.value - 0.7) * 0.15,
                    child: Text(
                      '🤗',
                      style: TextStyle(fontSize: perfect ? 80 : 64),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                ShaderMask(
                  shaderCallback: (b) => const LinearGradient(
                    colors: [
                      Color(0xFFFFD6E7),
                      Color(0xFFFF6FB4),
                      Color(0xFFFFD6E7),
                    ],
                  ).createShader(b),
                  child: Text(
                    perfect ? 'You know her so well! 💖' : 'Almost there! 💪',
                    style: GoogleFonts.pacifico(
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // The hug message
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xFFFF3CAC).withValues(alpha: 0.08),
                    border: Border.all(
                      color: const Color(0xFFFF6FB4).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    perfect
                        ? 'Bishakha,\n\nYou know yourself so well! 🌸\n\nThis is a warm, tight virtual hug\ncoming straight from the heart. 🫂\n\nYou deserve every bit of joy today.\nHappy 21st Birthday! ✨💖'
                        : 'Bishakha,\n\nNot a perfect score — but close! 🥰\nYou still get all the love.\n\nSending you warmth & the biggest\nvirtual hug on your special day. 🤗💖',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.88),
                      height: 1.8,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Floating hearts row
                _buildFloatingHearts(),

                const SizedBox(height: 20),

                // Play again button
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _stage = 0;
                      _qIndex = 0;
                      _score = 0;
                      _selected = null;
                      _answered = false;
                    });
                    _hugCtrl.reset();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: Colors.white.withValues(alpha: 0.07),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.replay_rounded,
                          size: 16,
                          color: Colors.white38,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Try Again',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingHearts() {
    const hearts = ['💗', '💖', '💝', '💓', '💞', '❤️'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(hearts.length, (i) {
        return AnimatedBuilder(
          animation: _glowCtrl,
          builder: (_, __) {
            final offset = sin((_glow.value * 2 * pi) + i * (pi / 3));
            return Transform.translate(
              offset: Offset(0, offset * 5),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Text(
                  hearts[i],
                  style: TextStyle(fontSize: 16 + (i % 3) * 3.0),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
