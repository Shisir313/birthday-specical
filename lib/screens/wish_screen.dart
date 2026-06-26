import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../widgets/confetti_widget.dart';
import '../widgets/balloon_widget.dart';

class WishScreen extends StatefulWidget {
  final String name;
  final int age;

  const WishScreen({super.key, required this.name, required this.age});

  @override
  State<WishScreen> createState() => _WishScreenState();
}

class _WishScreenState extends State<WishScreen> with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _cardAnim;
  late AnimationController _emojiAnim;
  late Animation<double> _cardSlide;
  late Animation<double> _emojiScale;
  late final List<Map<String, dynamic>> _wishes;

  int _selectedWish = 0;

  @override
  void initState() {
    super.initState();

    _wishes = [
      {
        'emoji': '🎂',
        'title': 'Classic Bday Energy',
        'message':
            'YOOO it\'s your day bestie! 🎉\nAnother level unlocked 🔓\nYou\'re literally glowing ✨\nHappy Birthday legends only! 💥',
        'gradient': const [Color(0xFFFF6B9D), Color(0xFFFF8E53)],
      },
      {
        'emoji': '👑',
        'title': 'Royalty Mode',
        'message':
            'Today the whole vibe is you 👑\nMain character energy: activated 🎬\nBirthday privilege is REAL 💅\nLong live the birthday royalty! 🌟',
        'gradient': const [Color(0xFFFFD700), Color(0xFFFF8C00)],
      },
      {
        'emoji': '🚀',
        'title': 'Level Up',
        'message':
            'Age ${widget.age}? That\'s a whole new DLC drop 🎮\nStats buffed, vibe upgraded 📈\nYou just hit a new meta 🔥\nHappy Birthday, you\'re built different! 💯',
        'gradient': const [Color(0xFF667EEA), Color(0xFF764BA2)],
      },
      {
        'emoji': '🌸',
        'title': 'Soft Life Era',
        'message':
            'You deserve ALL the good things 🌸\nCake, peace, and zero drama ☮️\nThis is your soft life era 🧁\nHappy Birthday, beautiful soul! 💖',
        'gradient': const [Color(0xFFFDA085), Color(0xFFF093FB)],
      },
      {
        'emoji': '⚡',
        'title': 'Hype Mode',
        'message':
            'LET\'S GOOO IT\'S YOUR DAY ⚡\nBIG BIRTHDAY ENERGY 🎊\nNOBODY DOING IT LIKE YOU 🏆\nHAPPY BIRTHDAY, GO OFF! 🎉🔥💥',
        'gradient': const [Color(0xFF11998E), Color(0xFF38EF7D)],
      },
    ];

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 4),
    );
    _confettiController.play();

    _cardAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _cardSlide = Tween<double>(
      begin: 80,
      end: 0,
    ).animate(CurvedAnimation(parent: _cardAnim, curve: Curves.easeOutCubic));
    _cardAnim.forward();

    _emojiAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _emojiScale = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _emojiAnim, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _cardAnim.dispose();
    _emojiAnim.dispose();
    super.dispose();
  }

  void _selectWish(int index) {
    setState(() => _selectedWish = index);
    _cardAnim.reset();
    _cardAnim.forward();
    _confettiController.play();
  }

  @override
  Widget build(BuildContext context) {
    final wish = _wishes[_selectedWish];
    final gradientColors = wish['gradient'] as List<Color>;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  gradientColors[0].withValues(alpha: 0.15),
                  const Color(0xFF0D0D1A),
                  gradientColors[1].withValues(alpha: 0.1),
                ],
              ),
            ),
          ),

          // Balloons
          const BalloonsBackground(),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: BirthdayConfetti(controller: _confettiController),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.white70,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "Birthday Vibes 🎉",
                        style: GoogleFonts.pacifico(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),

                        // Big emoji
                        ScaleTransition(
                          scale: _emojiScale,
                          child: Text(
                            wish['emoji'] as String,
                            style: const TextStyle(fontSize: 80),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Name heading
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: gradientColors,
                          ).createShader(bounds),
                          child: Text(
                            "Happy Birthday,",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),

                        AnimatedTextKit(
                          key: ValueKey(widget.name),
                          animatedTexts: [
                            TypewriterAnimatedText(
                              widget.name,
                              textStyle: GoogleFonts.pacifico(
                                fontSize: 38,
                                color: Colors.white,
                              ),
                              speed: const Duration(milliseconds: 80),
                            ),
                          ],
                          totalRepeatCount: 1,
                        ),

                        Text(
                          "🕯️ ${widget.age} candles strong!",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white38,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Wish card
                        AnimatedBuilder(
                          animation: _cardSlide,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _cardSlide.value),
                              child: Opacity(
                                opacity: (1 - _cardSlide.value / 80).clamp(
                                  0,
                                  1,
                                ),
                                child: child,
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  gradientColors[0].withValues(alpha: 0.25),
                                  gradientColors[1].withValues(alpha: 0.15),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: gradientColors[0].withValues(alpha: 0.4),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: gradientColors[0].withValues(
                                    alpha: 0.2,
                                  ),
                                  blurRadius: 30,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                ShaderMask(
                                  shaderCallback: (b) => LinearGradient(
                                    colors: gradientColors,
                                  ).createShader(b),
                                  child: Text(
                                    wish['title'] as String,
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  wish['message'] as String,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    color: Colors.white.withValues(alpha: 0.85),
                                    height: 1.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Vibe selector label
                        Text(
                          "Pick your vibe 👇",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white38,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Vibe chips
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          alignment: WrapAlignment.center,
                          children: List.generate(_wishes.length, (i) {
                            final isSelected = _selectedWish == i;
                            final chipGradient =
                                _wishes[i]['gradient'] as List<Color>;
                            return GestureDetector(
                              onTap: () => _selectWish(i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? LinearGradient(colors: chipGradient)
                                      : null,
                                  color: isSelected
                                      ? null
                                      : Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.transparent
                                        : Colors.white.withValues(alpha: 0.15),
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: chipGradient[0].withValues(
                                              alpha: 0.4,
                                            ),
                                            blurRadius: 12,
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Text(
                                  "${_wishes[i]['emoji']}  ${_wishes[i]['title']}",
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white54,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 32),

                        // Send vibes button
                        GestureDetector(
                          onTap: () {
                            _confettiController.play();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Sending birthday vibes to ${widget.name}! 🚀",
                                  style: const TextStyle(fontSize: 15),
                                ),
                                backgroundColor: gradientColors[0],
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            height: 58,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: gradientColors),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: gradientColors[0].withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                "🎊  Send Birthday Vibes!",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 36),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
