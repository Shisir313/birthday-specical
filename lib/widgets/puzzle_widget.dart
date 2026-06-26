import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'video_player_widget.dart';

// ─────────────────────────────────────────────────
// PuzzleGatedVideo
// Shows a sliding puzzle; solving it reveals the video.
// ─────────────────────────────────────────────────
class PuzzleGatedVideo extends StatefulWidget {
  final String assetPath;
  const PuzzleGatedVideo({super.key, required this.assetPath});

  @override
  State<PuzzleGatedVideo> createState() => _PuzzleGatedVideoState();
}

class _PuzzleGatedVideoState extends State<PuzzleGatedVideo>
    with SingleTickerProviderStateMixin {
  bool _solved = false;
  bool _showPuzzle = false;

  late AnimationController _unlockCtrl;
  late Animation<double> _unlockScale;
  late Animation<double> _unlockFade;

  @override
  void initState() {
    super.initState();
    _unlockCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _unlockScale = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _unlockCtrl, curve: Curves.elasticOut));
    _unlockFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _unlockCtrl, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _unlockCtrl.dispose();
    super.dispose();
  }

  void _onPuzzleSolved() {
    setState(() => _solved = true);
    _unlockCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    if (_solved) {
      return AnimatedBuilder(
        animation: _unlockCtrl,
        builder: (_, child) => FadeTransition(
          opacity: _unlockFade,
          child: ScaleTransition(scale: _unlockScale, child: child),
        ),
        child: BishakhaVideoPlayer(assetPath: widget.assetPath),
      );
    }

    if (_showPuzzle) {
      return _SlidingPuzzle(onSolved: _onPuzzleSolved);
    }

    // ── Locked poster ──
    return _LockedPoster(onUnlock: () => setState(() => _showPuzzle = true));
  }
}

// ─────────────────────────────────────────────────
// Locked poster — shown before puzzle starts
// ─────────────────────────────────────────────────
class _LockedPoster extends StatefulWidget {
  final VoidCallback onUnlock;
  const _LockedPoster({required this.onUnlock});

  @override
  State<_LockedPoster> createState() => _LockedPosterState();
}

class _LockedPosterState extends State<_LockedPoster>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _glow;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _glow = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
    _scale = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFFF3CAC).withValues(alpha: _glow.value * 0.7),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(
                0xFFFF3CAC,
              ).withValues(alpha: _glow.value * 0.3),
              blurRadius: 30,
              spreadRadius: 4,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1A0530),
                    Color(0xFF2D0B4E),
                    Color(0xFF0D1A2A),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Lock icon with glow
                  Transform.scale(
                    scale: _scale.value,
                    child: Container(
                      width: 72,
                      height: 72,
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
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.lock_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Video is locked 🔒',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Solve the puzzle to unlock it ✨',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white38,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: widget.onUnlock,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF3CAC), Color(0xFF784BA0)],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFFF3CAC,
                            ).withValues(alpha: 0.4),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.extension_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Play Puzzle',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
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
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// 3×3 Sliding tile puzzle — uses Bishakha's photo
// ─────────────────────────────────────────────────
class _SlidingPuzzle extends StatefulWidget {
  final VoidCallback onSolved;
  const _SlidingPuzzle({required this.onSolved});

  @override
  State<_SlidingPuzzle> createState() => _SlidingPuzzleState();
}

class _SlidingPuzzleState extends State<_SlidingPuzzle>
    with SingleTickerProviderStateMixin {
  static const int _size = 3;
  static const int _total = _size * _size; // 9 tiles, index 8 = blank

  late List<int> _tiles; // 0..7 = tiles, 8 = blank
  int _moves = 0;
  bool _solved = false;
  bool _showWin = false;

  late AnimationController _winCtrl;
  late Animation<double> _winScale;

  @override
  void initState() {
    super.initState();
    _winCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _winScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _winCtrl, curve: Curves.elasticOut));
    _shuffle();
  }

  @override
  void dispose() {
    _winCtrl.dispose();
    super.dispose();
  }

  void _shuffle() {
    _tiles = List.generate(_total, (i) => i);
    final rand = Random();
    int blank = 8;
    for (int i = 0; i < 200; i++) {
      final neighbors = _neighbors(blank);
      final next = neighbors[rand.nextInt(neighbors.length)];
      _tiles[blank] = _tiles[next];
      _tiles[next] = _total - 1;
      blank = next;
    }
    setState(() {
      _moves = 0;
      _solved = false;
      _showWin = false;
    });
  }

  List<int> _neighbors(int pos) {
    final row = pos ~/ _size;
    final col = pos % _size;
    final result = <int>[];
    if (row > 0) result.add(pos - _size);
    if (row < _size - 1) result.add(pos + _size);
    if (col > 0) result.add(pos - 1);
    if (col < _size - 1) result.add(pos + 1);
    return result;
  }

  bool _isSolved() {
    for (int i = 0; i < _total; i++) {
      if (_tiles[i] != i) return false;
    }
    return true;
  }

  void _onTileTap(int pos) {
    if (_solved) return;
    final blankPos = _tiles.indexOf(_total - 1);
    if (!_neighbors(blankPos).contains(pos)) return;

    setState(() {
      _tiles[blankPos] = _tiles[pos];
      _tiles[pos] = _total - 1;
      _moves++;
    });

    if (_isSolved()) {
      setState(() => _solved = true);
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() => _showWin = true);
          _winCtrl.forward();
          Future.delayed(const Duration(milliseconds: 1800), () {
            if (mounted) widget.onSolved();
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A0530), Color(0xFF2D0B4E), Color(0xFF0D1A2A)],
        ),
        border: Border.all(
          color: const Color(0xFFFF3CAC).withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF3CAC).withValues(alpha: 0.2),
            blurRadius: 30,
            spreadRadius: 4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const SizedBox(height: 14),
              _buildGrid(),
              const SizedBox(height: 14),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Text('🧩', style: TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Unlock the Video',
                style: GoogleFonts.pacifico(fontSize: 16, color: Colors.white),
              ),
              Text(
                'Arrange tiles in order to unlock 🎬',
                style: GoogleFonts.poppins(fontSize: 10, color: Colors.white38),
              ),
            ],
          ),
        ),
        // Move counter
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xFFFF3CAC).withValues(alpha: 0.15),
            border: Border.all(
              color: const Color(0xFFFF3CAC).withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.swap_horiz_rounded,
                size: 14,
                color: Color(0xFFFF6FB4),
              ),
              const SizedBox(width: 4),
              Text(
                '$_moves',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFFF6FB4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGrid() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Puzzle grid
        AspectRatio(
          aspectRatio: 1,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _size,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: _total,
            itemBuilder: (context, pos) {
              final val = _tiles[pos];
              final isBlank = val == _total - 1;
              final blankPos = _tiles.indexOf(_total - 1);
              final isNeighbor = _neighbors(blankPos).contains(pos);

              // Solved-position row/col for this tile value
              final tileRow = val ~/ _size;
              final tileCol = val % _size;
              // Map to -1..1 alignment range
              final alignX = (tileCol / (_size - 1)) * 2 - 1;
              final alignY = (tileRow / (_size - 1)) * 2 - 1;

              return GestureDetector(
                onTap: () => _onTileTap(pos),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isBlank
                          ? Colors.white.withValues(alpha: 0.06)
                          : isNeighbor && !_solved
                          ? const Color(0xFFFF6FB4)
                          : Colors.white.withValues(alpha: 0.18),
                      width: isNeighbor && !_solved ? 2.5 : 1,
                    ),
                    boxShadow: (!isBlank && isNeighbor && !_solved)
                        ? [
                            BoxShadow(
                              color: const Color(
                                0xFFFF3CAC,
                              ).withValues(alpha: 0.5),
                              blurRadius: 10,
                            ),
                          ]
                        : [],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: isBlank
                        ? Container(
                            color: Colors.white.withValues(alpha: 0.04),
                            child: Center(
                              child: Icon(
                                Icons.add_rounded,
                                color: Colors.white.withValues(alpha: 0.12),
                                size: 20,
                              ),
                            ),
                          )
                        : Stack(
                            fit: StackFit.expand,
                            children: [
                              // Photo slice — show the correct 1/3 crop
                              LayoutBuilder(
                                builder: (ctx, bc) {
                                  return OverflowBox(
                                    maxWidth: bc.maxWidth * _size,
                                    maxHeight: bc.maxHeight * _size,
                                    alignment: Alignment(alignX, alignY),
                                    child: Image.asset(
                                      'assets/images/bishakha.jpg',
                                      width: bc.maxWidth * _size,
                                      height: bc.maxHeight * _size,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: const Color(0xFF3D0B6E),
                                        child: Center(
                                          child: Text(
                                            '${val + 1}',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // Number badge
                              Positioned(
                                right: 3,
                                bottom: 3,
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black.withValues(alpha: 0.55),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.35,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${val + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Hover glow for movable tiles
                              if (isNeighbor && !_solved)
                                Container(
                                  color: Colors.white.withValues(alpha: 0.07),
                                ),
                            ],
                          ),
                  ),
                ),
              );
            },
          ),
        ),

        // Win overlay
        if (_showWin)
          AnimatedBuilder(
            animation: _winScale,
            builder: (_, child) =>
                Transform.scale(scale: _winScale.value, child: child),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF3CAC), Color(0xFF784BA0)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF3CAC).withValues(alpha: 0.6),
                    blurRadius: 30,
                    spreadRadius: 6,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 42)),
                  const SizedBox(height: 8),
                  Text(
                    'Puzzle Solved!',
                    style: GoogleFonts.pacifico(
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Unlocking video… 🎬',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        // Goal hint
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.poppins(fontSize: 10, color: Colors.white30),
              children: const [
                TextSpan(text: 'Goal: '),
                TextSpan(
                  text: '1 2 3 / 4 5 6 / 7 8 ▢',
                  style: TextStyle(
                    color: Color(0xFFFF6FB4),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Shuffle button
        GestureDetector(
          onTap: _solved ? null : _shuffle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white.withValues(alpha: 0.06),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.shuffle_rounded,
                  size: 13,
                  color: Colors.white38,
                ),
                const SizedBox(width: 5),
                Text(
                  'Shuffle',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
