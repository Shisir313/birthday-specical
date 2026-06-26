import 'package:flutter/material.dart';

class FloatingBalloon extends StatefulWidget {
  final Color color;
  final double size;
  final Duration duration;
  final double startX;

  const FloatingBalloon({
    super.key,
    required this.color,
    required this.size,
    required this.duration,
    required this.startX,
  });

  @override
  State<FloatingBalloon> createState() => _FloatingBalloonState();
}

class _FloatingBalloonState extends State<FloatingBalloon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnim;
  late Animation<double> _swayAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();

    _floatAnim = Tween<double>(
      begin: 1.0,
      end: -0.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _swayAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 15.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 15.0, end: -15.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -15.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: widget.startX * screenWidth + _swayAnim.value,
          top: _floatAnim.value * screenHeight,
          child: _buildBalloon(),
        );
      },
    );
  }

  Widget _buildBalloon() {
    return Column(
      children: [
        Container(
          width: widget.size,
          height: widget.size * 1.2,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(widget.size / 2),
              topRight: Radius.circular(widget.size / 2),
              bottomLeft: Radius.circular(widget.size / 2),
              bottomRight: Radius.circular(widget.size / 2.5),
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: Align(
            alignment: const Alignment(-0.3, -0.4),
            child: Container(
              width: widget.size * 0.15,
              height: widget.size * 0.25,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(widget.size),
              ),
            ),
          ),
        ),
        Container(
          width: 2,
          height: widget.size * 0.8,
          color: widget.color.withValues(alpha: 0.7),
        ),
      ],
    );
  }
}

class BalloonsBackground extends StatelessWidget {
  const BalloonsBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final List<(MaterialColor, double, int, double)> balloonData = [
      (Colors.pink, 50.0, 4500, 0.05),
      (Colors.purple, 40.0, 5000, 0.2),
      (Colors.yellow, 55.0, 3800, 0.4),
      (Colors.cyan, 45.0, 4200, 0.6),
      (Colors.orange, 48.0, 4800, 0.75),
      (Colors.green, 38.0, 5200, 0.9),
    ];

    return Stack(
      children: balloonData.map((data) {
        final base = data.$1;
        return FloatingBalloon(
          color: base.shade300,
          size: data.$2,
          duration: Duration(milliseconds: data.$3.toInt()),
          startX: data.$4,
        );
      }).toList(),
    );
  }
}
