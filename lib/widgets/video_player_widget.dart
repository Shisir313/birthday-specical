import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────
// Cinematic video card — compact & web-friendly
// No chewie: custom controls prevent the raw <video>
// element from leaking through on web.
// ─────────────────────────────────────────────────
class BinitaVideoPlayer extends StatefulWidget {
  final String assetPath;
  const BinitaVideoPlayer({super.key, required this.assetPath});

  @override
  State<BinitaVideoPlayer> createState() => _BinitaVideoPlayerState();
}

class _BinitaVideoPlayerState extends State<BinitaVideoPlayer>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _started = false; // user tapped play at least once
  bool _loading = false;
  bool _error = false;
  bool _showControls = true;

  late AnimationController _pulseAnim;
  late Animation<double> _pulse;
  late Animation<double> _btnPulse;

  @override
  void initState() {
    super.initState();
    _pulseAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulse = Tween<double>(
      begin: 0.45,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseAnim, curve: Curves.easeInOut));
    _btnPulse = Tween<double>(
      begin: 0.93,
      end: 1.07,
    ).animate(CurvedAnimation(parent: _pulseAnim, curve: Curves.easeInOut));
  }

  Future<void> _initAndPlay() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _started = true;
    });
    try {
      final ctrl = VideoPlayerController.asset(widget.assetPath);
      await ctrl.initialize();
      ctrl.addListener(_onVideoUpdate);
      if (mounted) {
        setState(() {
          _controller = ctrl;
          _loading = false;
        });
        ctrl.play();
        _autoHideControls();
      }
    } catch (_) {
      if (mounted)
        setState(() {
          _error = true;
          _loading = false;
        });
    }
  }

  void _onVideoUpdate() {
    if (mounted) setState(() {});
  }

  void _togglePlay() {
    final ctrl = _controller;
    if (ctrl == null) return;
    setState(() {
      ctrl.value.isPlaying ? ctrl.pause() : ctrl.play();
      _showControls = true;
    });
    if (ctrl.value.isPlaying) _autoHideControls();
  }

  void _autoHideControls() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && (_controller?.value.isPlaying ?? false)) {
        setState(() => _showControls = false);
      }
    });
  }

  void _onTapVideo() {
    setState(() => _showControls = !_showControls);
    if (_showControls && (_controller?.value.isPlaying ?? false)) {
      _autoHideControls();
    }
  }

  @override
  void dispose() {
    _pulseAnim.dispose();
    _controller?.removeListener(_onVideoUpdate);
    _controller?.dispose();
    super.dispose();
  }

  // ── Duration helpers ──────────────────────────
  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, child) => _CinematicFrame(glow: _pulse.value, child: child!),
      child: AspectRatio(aspectRatio: 16 / 9, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_error) return _buildError();
    if (_loading) return _buildSpinner();
    if (!_started) return _buildPoster();
    return _buildPlayer();
  }

  // ── Poster ────────────────────────────────────
  Widget _buildPoster() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A0530), Color(0xFF2D0B4E), Color(0xFF0D1A2A)],
            ),
          ),
        ),
        // soft bokeh
        ..._bokeh(),
        // play button
        Center(
          child: AnimatedBuilder(
            animation: _btnPulse,
            builder: (_, __) => Transform.scale(
              scale: _btnPulse.value,
              child: GestureDetector(
                onTap: _initAndPlay,
                child: AnimatedBuilder(
                  animation: _pulse,
                  builder: (_, __) => Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF3CAC), Color(0xFF784BA0)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFFFF3CAC,
                          ).withValues(alpha: _pulse.value * 0.7),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 12,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              'Tap to play  💖',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white54,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Active player with custom controls ────────
  Widget _buildPlayer() {
    final ctrl = _controller!;
    final val = ctrl.value;
    final pos = val.position;
    final dur = val.duration;
    final frac = dur.inMilliseconds == 0
        ? 0.0
        : (pos.inMilliseconds / dur.inMilliseconds).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: _onTapVideo,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── actual video ──
          VideoPlayer(ctrl),

          // ── controls overlay ──
          AnimatedOpacity(
            opacity: _showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.15),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.55),
                  ],
                ),
              ),
              child: Column(
                children: [
                  const Spacer(),
                  // centre play/pause
                  Center(
                    child: GestureDetector(
                      onTap: _togglePlay,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.45),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          val.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // progress bar + time
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // scrub bar
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 12,
                            ),
                            activeTrackColor: const Color(0xFFFF3CAC),
                            inactiveTrackColor: Colors.white.withValues(
                              alpha: 0.25,
                            ),
                            thumbColor: const Color(0xFFFF6FB4),
                            overlayColor: const Color(
                              0xFFFF3CAC,
                            ).withValues(alpha: 0.25),
                          ),
                          child: Slider(
                            value: frac,
                            onChanged: (v) {
                              ctrl.seekTo(
                                Duration(
                                  milliseconds: (v * dur.inMilliseconds)
                                      .round(),
                                ),
                              );
                              setState(() => _showControls = true);
                            },
                          ),
                        ),
                        // time labels
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _fmt(pos),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              _fmt(dur),
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpinner() {
    return Container(
      color: const Color(0xFF12032A),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFFFF3CAC),
            strokeWidth: 2.5,
          ),
          const SizedBox(height: 14),
          Text(
            'Loading… 🎥',
            style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      color: const Color(0xFF12032A),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎬', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 10),
          Text(
            'Video coming soon!',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "assets/videos/binita.mp4",
            style: GoogleFonts.poppins(color: Colors.white30, fontSize: 10),
          ),
        ],
      ),
    );
  }

  List<Widget> _bokeh() {
    final data = [
      [0.08, 0.15, 55.0, 0xFFFF3CAC, 0.07],
      [0.78, 0.08, 70.0, 0xFF784BA0, 0.09],
      [0.12, 0.70, 45.0, 0xFF2B86C5, 0.06],
      [0.82, 0.75, 65.0, 0xFFFF6FB4, 0.08],
    ];
    return data.map((d) {
      return Positioned(
        left: (d[0] as double) * 320,
        top: (d[1] as double) * 180,
        child: Container(
          width: d[2] as double,
          height: d[2] as double,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(d[3] as int).withValues(alpha: d[4] as double),
          ),
        ),
      );
    }).toList();
  }
}

// ─────────────────────────────────────────────────
// Cinematic outer frame
// ─────────────────────────────────────────────────
class _CinematicFrame extends StatelessWidget {
  final Widget child;
  final double glow;
  const _CinematicFrame({required this.child, required this.glow});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // ambient glow
        Positioned.fill(
          child: Container(
            margin: const EdgeInsets.only(top: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF3CAC).withValues(alpha: glow * 0.28),
                  blurRadius: 50,
                  spreadRadius: 6,
                ),
                BoxShadow(
                  color: const Color(0xFF784BA0).withValues(alpha: glow * 0.18),
                  blurRadius: 70,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
        ),
        // gradient border shell
        Container(
          margin: const EdgeInsets.only(top: 20),
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: SweepGradient(
              colors: [
                const Color(0xFFFF3CAC).withValues(alpha: glow),
                const Color(0xFFFFD6E7).withValues(alpha: glow * 0.5),
                const Color(0xFF784BA0).withValues(alpha: glow * 0.8),
                const Color(0xFF2B86C5).withValues(alpha: glow * 0.5),
                const Color(0xFFFF3CAC).withValues(alpha: glow),
              ],
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: const Color(0xFF0A0118),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ribbon(glow),
                  _filmStrip(),
                  child,
                  _filmStrip(),
                  _bottomBar(),
                ],
              ),
            ),
          ),
        ),
        // corner sparkles
        _star(top: 8, left: 4),
        _star(top: 8, right: 4),
        _star(bottom: 2, left: 4),
        _star(bottom: 2, right: 4),
      ],
    );
  }

  Widget _star({double? top, double? bottom, double? left, double? right}) =>
      Positioned(
        top: top,
        bottom: bottom,
        left: left,
        right: right,
        child: Opacity(
          opacity: glow,
          child: const Text('✨', style: TextStyle(fontSize: 14)),
        ),
      );

  Widget _ribbon(double g) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 14),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          const Color(0xFFFF3CAC).withValues(alpha: 0.88),
          const Color(0xFF784BA0).withValues(alpha: 0.88),
          const Color(0xFF2B86C5).withValues(alpha: 0.78),
        ],
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🎞️', style: TextStyle(fontSize: 15)),
        const SizedBox(width: 8),
        ShaderMask(
          shaderCallback: (b) => LinearGradient(
            colors: [
              Colors.white,
              Colors.white.withValues(alpha: g),
              Colors.white,
            ],
          ).createShader(b),
          child: Text(
            'A Special Memory  💖',
            style: GoogleFonts.pacifico(
              fontSize: 14,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Text('🎞️', style: TextStyle(fontSize: 15)),
      ],
    ),
  );

  Widget _filmStrip() => SizedBox(
    height: 12,
    child: CustomPaint(
      painter: _FilmPainter(),
      child: Container(color: const Color(0xFF080112)),
    ),
  );

  Widget _bottomBar() => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 7),
    color: const Color(0xFF080112),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _dot(const Color(0xFFFF3CAC)),
        const SizedBox(width: 8),
        Text(
          'just for you, Binita',
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: Colors.white30,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(width: 8),
        _dot(const Color(0xFF784BA0)),
      ],
    ),
  );

  Widget _dot(Color c) => Container(
    width: 5,
    height: 5,
    decoration: BoxDecoration(shape: BoxShape.circle, color: c),
  );
}

class _FilmPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF2A1040)
      ..style = PaintingStyle.fill;
    const w = 9.0, h = 7.0, gap = 5.0;
    final top = (size.height - h) / 2;
    double x = gap;
    while (x + w < size.width) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, top, w, h),
          const Radius.circular(2),
        ),
        p,
      );
      x += w + gap;
    }
  }

  @override
  bool shouldRepaint(_FilmPainter _) => false;
}
