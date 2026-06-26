import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../widgets/balloon_widget.dart';
import '../widgets/cake_widget.dart';
import '../widgets/confetti_widget.dart';
import 'wish_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  late AnimationController _buttonAnim;
  late Animation<double> _buttonScale;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _buttonAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _buttonScale = Tween<double>(
      begin: 1.0,
      end: 0.93,
    ).animate(CurvedAnimation(parent: _buttonAnim, curve: Curves.easeInOut));
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _buttonAnim.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _celebrate() {
    final name = _nameController.text.trim();
    final ageText = _ageController.text.trim();
    if (name.isEmpty) {
      _showSnack("Enter a name first! 🎂");
      return;
    }
    final age = int.tryParse(ageText) ?? 1;

    _confettiController.play();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, anim, secondaryAnim) =>
              WishScreen(name: name, age: age),
          transitionsBuilder: (context, anim, secondaryAnim, child) {
            return FadeTransition(
              opacity: anim,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.85, end: 1.0).animate(anim),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    });
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontSize: 16)),
        backgroundColor: const Color(0xFFFF6B9D),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D0D1A),
                  Color(0xFF1A0A2E),
                  Color(0xFF0D1A2A),
                ],
              ),
            ),
          ),

          // Floating balloons
          const BalloonsBackground(),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: BirthdayConfetti(controller: _confettiController),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Title
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFFF6B9D), Color(0xFFFFE66D)],
                    ).createShader(bounds),
                    child: Text(
                      "🎉 Birthday Vibes",
                      style: GoogleFonts.pacifico(
                        fontSize: 36,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        "Make someone feel special ✨",
                        textStyle: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.white54,
                        ),
                        speed: const Duration(milliseconds: 60),
                      ),
                    ],
                    totalRepeatCount: 1,
                  ),

                  const SizedBox(height: 36),

                  // Cake
                  const AnimatedCake(candles: 3),

                  const SizedBox(height: 40),

                  // Name input
                  _buildInputField(
                    controller: _nameController,
                    hint: "Enter their name 🎀",
                    icon: Icons.person_rounded,
                  ),

                  const SizedBox(height: 16),

                  // Age input
                  _buildInputField(
                    controller: _ageController,
                    hint: "How old are they? 🕯️",
                    icon: Icons.cake_rounded,
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 36),

                  // Celebrate button
                  ScaleTransition(
                    scale: _buttonScale,
                    child: GestureDetector(
                      onTapDown: (_) => _buttonAnim.forward(),
                      onTapUp: (_) {
                        _buttonAnim.reverse();
                        _celebrate();
                      },
                      onTapCancel: () => _buttonAnim.reverse(),
                      child: Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF6B9D), Color(0xFFFF8E53)],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFFFF6B9D,
                              ).withValues(alpha: 0.5),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            "🎊  Let's Celebrate!",
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: Colors.white38, fontSize: 15),
          prefixIcon: Icon(icon, color: const Color(0xFFFF6B9D)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}
