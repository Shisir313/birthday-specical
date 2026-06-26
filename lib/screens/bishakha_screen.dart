import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import '../widgets/confetti_widget.dart';
import '../widgets/balloon_widget.dart';
import '../widgets/sparkle_widget.dart';
import '../widgets/photo_frame_widget.dart';
import '../widgets/video_player_widget.dart';
import '../widgets/card_picker_widget.dart';
import '../widgets/puzzle_widget.dart';
import '../widgets/virtual_hug_widget.dart';

class BishakhaScreen extends StatefulWidget {
  const BishakhaScreen({super.key});

  @override
  State<BishakhaScreen> createState() => _BishakhaScreenState();
}

class _BishakhaScreenState extends State<BishakhaScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late ConfettiController _confettiController2;
  late AnimationController _glowAnim;
  late AnimationController _floatAnim;
  late AnimationController _heartAnim;
  late Animation<double> _glowPulse;
  late Animation<double> _floatY;
  late Animation<double> _heartScale;

  int _currentWish = 0;
  final List<String> _wishes = [
    "To the girl who makes every room brighter ✨\nHappy 21st Birthday, Bishakha! 🎂",
    "21 years of being absolutely amazing 💫\nThe world is lucky to have you 🌸",
    "From girl to queen — officially 21 👑\nYour best chapter starts today! 📖",
    "21 looks stunning on you, Bishakha 🌷\nHere's to love, laughter & magic! 🥂",
  ];

  @override
  void initState() {
    super.initState();

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 6),
    );
    _confettiController2 = ConfettiController(
      duration: const Duration(seconds: 6),
    );

    _glowAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _floatAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _heartAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _glowPulse = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _glowAnim, curve: Curves.easeInOut));

    _floatY = Tween<double>(
      begin: -8,
      end: 8,
    ).animate(CurvedAnimation(parent: _floatAnim, curve: Curves.easeInOut));

    _heartScale = Tween<double>(
      begin: 1.0,
      end: 1.25,
    ).animate(CurvedAnimation(parent: _heartAnim, curve: Curves.easeInOut));

    // Auto-fire confetti on load
    Future.delayed(const Duration(milliseconds: 300), () {
      _confettiController.play();
      _confettiController2.play();
    });

    // Cycle through wishes
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 4));
      if (!mounted) return false;
      setState(() => _currentWish = (_currentWish + 1) % _wishes.length);
      return true;
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _confettiController2.dispose();
    _glowAnim.dispose();
    _floatAnim.dispose();
    _heartAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0517),
      body: Stack(
        children: [
          // Deep purple/rose gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1A0530),
                  Color(0xFF2D0B4E),
                  Color(0xFF1A0B2E),
                  Color(0xFF0D0517),
                ],
              ),
            ),
          ),

          // Sparkles in the background
          const SparklesBackground(),

          // Balloons
          const BalloonsBackground(),

          // Left confetti
          Align(
            alignment: Alignment.topLeft,
            child: BirthdayConfetti(controller: _confettiController),
          ),

          // Right confetti
          Align(
            alignment: Alignment.topRight,
            child: BirthdayConfetti(controller: _confettiController2),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Top "21" badge
                  _build21Badge(),

                  const SizedBox(height: 24),

                  // Photo frame
                  AnimatedBuilder(
                    animation: _floatY,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(0, _floatY.value),
                      child: child,
                    ),
                    child: AnimatedBuilder(
                      animation: _glowPulse,
                      builder: (context, child) => GlowPhotoFrame(
                        glowIntensity: _glowPulse.value,
                        child: child!,
                      ),
                      child: const PhotoPlaceholder(),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Name with shimmer
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Color(0xFFFFD6E7),
                        Color(0xFFFF6FB4),
                        Color(0xFFFFD6E7),
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ).createShader(bounds),
                    child: Text(
                      "Bishakha Timalshina",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.greatVibes(
                        fontSize: 42,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Hearts row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return AnimatedBuilder(
                        animation: _heartScale,
                        builder: (context, child) => Transform.scale(
                          scale: i == 2 ? _heartScale.value : 1.0,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 3),
                            child: Text("💗", style: TextStyle(fontSize: 18)),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 28),

                  // Wish card
                  _buildWishCard(),

                  const SizedBox(height: 28),

                  // Card picker
                  const CardPickerSection(),

                  const SizedBox(height: 28),

                  // Virtual hug quiz
                  const VirtualHugSection(),

                  const SizedBox(height: 28),

                  // Video section
                  _buildVideoSection(),

                  const SizedBox(height: 28),

                  // "21 things" section
                  _build21Things(),

                  const SizedBox(height: 28),

                  // Celebrate button
                  _buildCelebrateButton(),

                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _build21Badge() {
    return AnimatedBuilder(
      animation: _glowPulse,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6FB4), Color(0xFFFF3CAC)],
            ),
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFFFF6FB4,
                ).withValues(alpha: _glowPulse.value * 0.7),
                blurRadius: 25,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("🎂", style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Text(
                "Turning 21!",
                style: GoogleFonts.pacifico(
                  fontSize: 22,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 10),
              const Text("🎂", style: TextStyle(fontSize: 22)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWishCard() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(anim),
          child: child,
        ),
      ),
      child: Container(
        key: ValueKey(_currentWish),
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFF6FB4).withValues(alpha: 0.2),
              const Color(0xFF9B59B6).withValues(alpha: 0.15),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: const Color(0xFFFF6FB4).withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6FB4).withValues(alpha: 0.15),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              "✨  Birthday Wish  ✨",
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFFFF6FB4),
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              _wishes[_currentWish],
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.8,
              ),
            ),
            const SizedBox(height: 10),
            // Dot indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_wishes.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentWish == i ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentWish == i
                        ? const Color(0xFFFF6FB4)
                        : Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoSection() {
    return const PuzzleGatedVideo(assetPath: 'assets/videos/bishakha.mp4');
  }

  Widget _build21Things() {
    final items = [
      ("🌟", "Start of your best decade"),
      ("💃", "Dance like nobody's watching"),
      ("🌸", "Bloom in your own time"),
      ("🎯", "Chase every dream fearlessly"),
      ("☕", "Enjoy every little moment"),
      ("🦋", "You've grown into something beautiful"),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: ShaderMask(
            shaderCallback: (b) => const LinearGradient(
              colors: [Color(0xFFFF6FB4), Color(0xFFFFD6E7)],
            ).createShader(b),
            child: Text(
              "21 & Thriving 🌷",
              style: GoogleFonts.pacifico(fontSize: 24, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...items.map((item) => _buildListItem(item.$1, item.$2)),
      ],
    );
  }

  Widget _buildListItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6FB4).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFF6FB4).withValues(alpha: 0.3),
              ),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCelebrateButton() {
    return GestureDetector(
      onTap: () {
        _confettiController.play();
        _confettiController2.play();
      },
      child: AnimatedBuilder(
        animation: _glowPulse,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: 62,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFF3CAC),
                  Color(0xFF784BA0),
                  Color(0xFF2B86C5),
                ],
              ),
              borderRadius: BorderRadius.circular(31),
              boxShadow: [
                BoxShadow(
                  color: const Color(
                    0xFFFF3CAC,
                  ).withValues(alpha: _glowPulse.value * 0.6),
                  blurRadius: 25,
                  spreadRadius: 2,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(
                "🎊  Celebrate Bishakha!  🎊",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
