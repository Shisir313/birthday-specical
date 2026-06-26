import 'package:flutter/material.dart';

class AnimatedCake extends StatefulWidget {
  final int candles;
  const AnimatedCake({super.key, required this.candles});

  @override
  State<AnimatedCake> createState() => _AnimatedCakeState();
}

class _AnimatedCakeState extends State<AnimatedCake>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _flameController;
  late Animation<double> _scaleAnim;
  late Animation<double> _flameAnim;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnim = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    _scaleController.forward();

    _flameController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _flameAnim = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _flameController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _flameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: SizedBox(
        width: 200,
        height: 220,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Cake layers
            Positioned(
              bottom: 0,
              child: Column(
                children: [
                  _buildCakeLayer(160, 50, const Color(0xFFFF9EBC)),
                  _buildCakeLayer(180, 55, const Color(0xFFFFB347)),
                  _buildCakeLayer(200, 60, const Color(0xFFFF6B9D)),
                ],
              ),
            ),
            // Candles
            Positioned(
              bottom: 165,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  widget.candles.clamp(1, 5),
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: _buildCandle(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCakeLayer(double width, double height, Color color) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CustomPaint(painter: _FrostingPainter()),
    );
  }

  Widget _buildCandle() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _flameAnim,
          builder: (context, child) {
            return Transform.scale(
              scale: _flameAnim.value,
              child: Container(
                width: 10,
                height: 16,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0xFFFFE066), Color(0xFFFF6B35)],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.6),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        Container(
          width: 10,
          height: 30,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFE066), Color(0xFFFFB347)],
            ),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ],
    );
  }
}

class _FrostingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    for (double x = 0; x <= size.width; x += 20) {
      path.quadraticBezierTo(x + 10, 12, x + 20, 0);
    }
    path.lineTo(size.width, 15);
    path.lineTo(0, 15);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
