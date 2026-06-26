import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────
// Data model for each card
// ─────────────────────────────────────────────────────────────
class _BdayCard {
  final String emoji;
  final String label;
  final String title;
  final String message;
  final List<Color> gradient;
  final Color borderColor;

  const _BdayCard({
    required this.emoji,
    required this.label,
    required this.title,
    required this.message,
    required this.gradient,
    required this.borderColor,
  });
}

const _cards = [
  _BdayCard(
    emoji: '🌸',
    label: 'Soft & Sweet',
    title: 'You are one of a kind',
    message:
        'In a world full of ordinary,\nyou walk in like a whole season.\nNot spring, not summer —\nbut something rare and unforgettable.\nHappy 21st, Bishakha. 🌸',
    gradient: [Color(0xFFFDA085), Color(0xFFF093FB)],
    borderColor: Color(0xFFF093FB),
  ),
  _BdayCard(
    emoji: '👑',
    label: 'Queen Energy',
    title: 'The crown fits perfectly',
    message:
        'You were never chasing the spotlight —\nthe spotlight just refuses to leave you.\nEvery room you walk into gets warmer.\nOwn it, queen. This is YOUR year. 👑',
    gradient: [Color(0xFFFFD700), Color(0xFFFF6B35)],
    borderColor: Color(0xFFFFD700),
  ),
  _BdayCard(
    emoji: '🌙',
    label: 'Midnight Magic',
    title: 'You shine in the dark',
    message:
        'Some people need the sun to glow.\nBut you? You light up the whole night\nwithout even trying.\nKeep shining, even when skies get grey. 🌙✨',
    gradient: [Color(0xFF2C3E8C), Color(0xFF9B59B6)],
    borderColor: Color(0xFF9B59B6),
  ),
  _BdayCard(
    emoji: '🦋',
    label: 'Transformation',
    title: '21 — the real bloom',
    message:
        'Everything you\'ve been through,\nevery tear, every laugh, every silent night —\nit was all stitching together\nthe most beautiful version of you.\nWelcome to your bloom. 🦋',
    gradient: [Color(0xFF11998E), Color(0xFF38EF7D)],
    borderColor: Color(0xFF38EF7D),
  ),
  _BdayCard(
    emoji: '💌',
    label: 'From the Heart',
    title: 'A letter just for you',
    message:
        'Dear Bishakha,\nThe world got a little better the day\nyou decided to be you.\nDon\'t ever shrink yourself for anyone.\nYou deserve every good thing —\nall of it, fully, without apology. 💌',
    gradient: [Color(0xFFFF3CAC), Color(0xFF784BA0)],
    borderColor: Color(0xFFFF3CAC),
  ),
  _BdayCard(
    emoji: '🔥',
    label: 'Boss Mode',
    title: 'Unstoppable at 21',
    message:
        'You\'re not just turning 21.\nYou\'re loading the most powerful\nversion of yourself.\nDreams? Closer than ever.\nYou? Ready like never before. 🔥\nLet\'s gooo! 🚀',
    gradient: [Color(0xFFFC4A1A), Color(0xFFF7B733)],
    borderColor: Color(0xFFFC4A1A),
  ),
  _BdayCard(
    emoji: '🌊',
    label: 'Free Spirit',
    title: 'Flow & flourish',
    message:
        'Be like water, Bishakha —\ncalm when you need to be,\nwild when you want to be,\nand always finding your way.\nThe ocean doesn\'t apologize\nfor its waves. 🌊',
    gradient: [Color(0xFF2193B0), Color(0xFF6DD5FA)],
    borderColor: Color(0xFF6DD5FA),
  ),
  _BdayCard(
    emoji: '🎭',
    label: 'Main Character',
    title: 'It\'s giving protagonist',
    message:
        'You\'re not a side character, bestie.\nYou\'re the main character,\nthe plot twist, the glow-up arc,\nAND the happy ending all at once.\nHappy Birthday — go write your story. 🎭✨',
    gradient: [Color(0xFF667EEA), Color(0xFF764BA2)],
    borderColor: Color(0xFF667EEA),
  ),
];

// ─────────────────────────────────────────────────────────────
// The full card picker section widget
// ─────────────────────────────────────────────────────────────
class CardPickerSection extends StatefulWidget {
  const CardPickerSection({super.key});

  @override
  State<CardPickerSection> createState() => _CardPickerSectionState();
}

class _CardPickerSectionState extends State<CardPickerSection>
    with TickerProviderStateMixin {
  int _selected = 0;
  bool _flipped = false;

  late AnimationController _flipCtrl;
  late Animation<double> _flipAnim;
  late AnimationController _glowCtrl;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();

    _flipCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _flipAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOut));

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _glow = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  void _selectCard(int index) {
    if (index == _selected) {
      // re-tap same card: flip it
      _toggleFlip();
      return;
    }
    // switching card: reset to front
    setState(() {
      _selected = index;
      _flipped = false;
    });
    _flipCtrl.reset();
  }

  void _toggleFlip() {
    if (_flipped) {
      _flipCtrl.reverse().then((_) => setState(() => _flipped = false));
    } else {
      _flipCtrl.forward().then((_) => setState(() => _flipped = true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Section header ──
        _buildHeader(),
        const SizedBox(height: 20),

        // ── Horizontal chip row ──
        _buildChipRow(),
        const SizedBox(height: 24),

        // ── The card itself ──
        _buildCard(),
        const SizedBox(height: 12),

        // ── Hint text ──
        Text(
          _flipped ? 'Tap card to flip back 🔄' : 'Tap the card to read it 💌',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white30,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }

  // ── Section header ──────────────────────────────
  Widget _buildHeader() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (b) => const LinearGradient(
            colors: [Color(0xFFFF3CAC), Color(0xFFFFD6E7), Color(0xFFFF6FB4)],
          ).createShader(b),
          child: Text(
            '💌  Pick a Card  💌',
            style: GoogleFonts.pacifico(fontSize: 24, color: Colors.white),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'each one written just for you',
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.white30),
        ),
      ],
    );
  }

  // ── Horizontal scrollable chip row ──────────────
  Widget _buildChipRow() {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: _cards.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final card = _cards[i];
          final isSelected = _selected == i;
          return GestureDetector(
            onTap: () => _selectCard(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(colors: card.gradient)
                    : null,
                color: isSelected ? null : Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : Colors.white.withValues(alpha: 0.12),
                  width: 1.2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: card.gradient[0].withValues(alpha: 0.45),
                          blurRadius: 14,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    card.emoji,
                    style: TextStyle(fontSize: isSelected ? 16 : 14),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    card.label,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected ? Colors.white : Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Flip card ───────────────────────────────────
  Widget _buildCard() {
    return AnimatedBuilder(
      animation: _flipAnim,
      builder: (context, _) {
        final angle = _flipAnim.value * pi;
        final isFront = angle <= pi / 2;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: isFront ? _buildFront() : _buildBack(),
        );
      },
    );
  }

  Widget _buildFront() {
    final card = _cards[_selected];
    return GestureDetector(
      onTap: _toggleFlip,
      child: AnimatedBuilder(
        animation: _glow,
        builder: (_, __) => Container(
          width: double.infinity,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: [
                card.gradient[0].withValues(alpha: _glow.value),
                card.gradient[1].withValues(alpha: _glow.value * 0.7),
                card.gradient[0].withValues(alpha: _glow.value),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: card.gradient[0].withValues(alpha: _glow.value * 0.4),
                blurRadius: 30,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  card.gradient[0].withValues(alpha: 0.22),
                  card.gradient[1].withValues(alpha: 0.12),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: Column(
                children: [
                  // Big emoji
                  Text(card.emoji, style: const TextStyle(fontSize: 52)),
                  const SizedBox(height: 16),
                  // Title
                  ShaderMask(
                    shaderCallback: (b) =>
                        LinearGradient(colors: card.gradient).createShader(b),
                    child: Text(
                      card.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.pacifico(
                        fontSize: 20,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Divider line
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                card.gradient[0].withValues(alpha: 0.6),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          '✦',
                          style: TextStyle(
                            color: card.gradient[0],
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                card.gradient[1].withValues(alpha: 0.6),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Message
                  Text(
                    card.message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.white.withValues(alpha: 0.88),
                      height: 1.9,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Flip hint chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white.withValues(alpha: 0.08),
                      border: Border.all(
                        color: card.gradient[0].withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.flip_rounded,
                          size: 14,
                          color: card.gradient[0],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Flip for a secret ✨',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBack() {
    final card = _cards[_selected];
    // Mirror-correct the back face
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(pi),
      child: GestureDetector(
        onTap: _toggleFlip,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: [card.gradient[1], card.gradient[0]],
            ),
            boxShadow: [
              BoxShadow(
                color: card.gradient[1].withValues(alpha: 0.45),
                blurRadius: 30,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A0530), Color(0xFF2D0B4E)],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
              child: Column(
                children: [
                  // Star decoration
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (i) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          Icons.star_rounded,
                          size: i == 2 ? 22 : 14,
                          color: card.gradient[0].withValues(
                            alpha: i == 2 ? 1.0 : 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '"',
                    style: GoogleFonts.greatVibes(
                      fontSize: 60,
                      color: card.gradient[0].withValues(alpha: 0.4),
                      height: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Secret quote on the back
                  Text(
                    _secretQuote(_selected),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.greatVibes(
                      fontSize: 22,
                      color: Colors.white.withValues(alpha: 0.92),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '— with love 💖',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: card.gradient[0].withValues(alpha: 0.8),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          card.gradient[0].withValues(alpha: 0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Happy 21st Birthday\nBishakha Timalshina 🌸',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white38,
                      height: 1.6,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _secretQuote(int index) {
    const quotes = [
      'She bloomed not because\nsomeone told her to,\nbut because she chose to.',
      'A queen doesn\'t need\na crown to be royalty.\nShe already knows.',
      'Even the darkest night\nwill end,\nand you will shine.',
      'The most beautiful journeys\nstart from the places\nwe never expected.',
      'You are the poem\nI never knew\nhow to write.',
      'She decided to be\nunapologetically, fully,\nwonderfully herself.',
      'Like the ocean,\nyou are deep,\npowerful and free.',
      'She is the story,\nthe author,\nand the happy ending.',
    ];
    return quotes[index % quotes.length];
  }
}
