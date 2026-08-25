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

class BinitaScreen extends StatefulWidget {
  const BinitaScreen({super.key});

  @override
  State<BinitaScreen> createState() => _BinitaScreenState();
}

class _BinitaScreenState extends State<BinitaScreen>
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
    "To the girl who makes every room brighter ✨\nHappy 21st Birthday, Binita! 🎂",
    "21 years of being absolutely amazing 💫\nThe world is lucky to have you 🌸",
    "Wishing you endless joy and adventures 🎈\nYour journey is just beginning! 🌟",
    "21 looks stunning on you, Binita 🌷\nHere's to love, laughter & magic! 🥂",
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
      body: Stack(
        children: [
          // New modern gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF667EEA), // Soft blue-purple
                  Color(0xFF764BA2), // Purple
                  Color(0xFFF093FB), // Light pink
                  Color(0xFF4FACFE), // Sky blue
                ],
                stops: [0.0, 0.3, 0.6, 1.0],
              ),
            ),
          ),

          // Overlay pattern
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.5,
                colors: [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.transparent,
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Top "21" badge with new style
                  _build21Badge(),

                  const SizedBox(height: 32),

                  // Photo frame with floating animation
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

                  const SizedBox(height: 24),

                  // Name with new gradient
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Color(0xFFFFFFFF),
                        Color(0xFFFFF9C4),
                        Color(0xFFFFFFFF),
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ).createShader(bounds),
                    child: Text(
                      "Binita Lungba",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dancingScript(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E7).withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFFFF8E7).withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      "✨ Forever Young & Amazing ✨",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Wish card with new design
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

                  // "21 things" section with new style
                  _build21Things(),

                  const SizedBox(height: 28),

                  // Celebrate button
                  _buildCelebrateButton(),

                  const SizedBox(height: 40),
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
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E7), // Soft creamy beige
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFFFFF8E7,
                ).withValues(alpha: _glowPulse.value * 0.8),
                blurRadius: 30,
                spreadRadius: 5,
              ),
              BoxShadow(
                color: const Color(0xFF764BA2).withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("🎉", style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ).createShader(bounds),
                child: Text(
                  "Happy 21st Birthday!",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text("🎉", style: TextStyle(fontSize: 24)),
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
        child: ScaleTransition(scale: anim, child: child),
      ),
      child: Container(
        key: ValueKey(_currentWish),
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(
            0xFFFFF8E7,
          ).withValues(alpha: 0.98), // Soft creamy color
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF764BA2).withValues(alpha: 0.3),
              blurRadius: 30,
              spreadRadius: 3,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "✨  Birthday Wish  ✨",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _wishes[_currentWish],
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(
                  0xFF4A3728,
                ), // Warm dark brown for better contrast
                height: 1.8,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            // Dot indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_wishes.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentWish == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: _currentWish == i
                        ? const LinearGradient(
                            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                          )
                        : null,
                    color: _currentWish == i
                        ? null
                        : const Color(0xFF667EEA).withValues(alpha: 0.3),
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
    return const PuzzleGatedVideo(assetPath: 'assets/videos/binita.mp4');
  }

  Widget _build21Things() {
    final items = [
      ("🌟", "Start of your best decade yet"),
      ("💃", "Dance like nobody's watching"),
      ("🌸", "Bloom beautifully in your own time"),
      ("🎯", "Chase every dream fearlessly"),
      ("☕", "Savor every little moment"),
      ("🦋", "You've transformed into something magical"),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(
          0xFFFFF8E7,
        ).withValues(alpha: 0.95), // Soft creamy beige
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF764BA2).withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            ).createShader(b),
            child: Text(
              "✨ 21 & Thriving ✨",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...items.map((item) => _buildListItem(item.$1, item.$2)),
        ],
      ),
    );
  }

  Widget _buildListItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667EEA).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: const Color(0xFF4A3728), // Warm dark brown
                fontWeight: FontWeight.w500,
                height: 1.4,
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
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: const Color(
                    0xFF667EEA,
                  ).withValues(alpha: _glowPulse.value * 0.6),
                  blurRadius: 30,
                  spreadRadius: 3,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                "🎊  Celebrate Binita!  🎊",
                style: GoogleFonts.inter(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
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
