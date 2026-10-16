import 'package:flutter/material.dart';

class NutriBotMascotIcon extends StatelessWidget {
  final double size;
  final Color color;

  const NutriBotMascotIcon({
    super.key,
    this.size = 28,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _NutriBotMascotPainter(color: color),
      ),
    );
  }
}

class _NutriBotMascotPainter extends CustomPainter {
  final Color color;

  _NutriBotMascotPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.075
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // 1. Sprout Antenna at Top
    final stemPath = Path();
    stemPath.moveTo(w * 0.5, h * 0.22);
    stemPath.lineTo(w * 0.5, h * 0.12);
    canvas.drawPath(stemPath, strokePaint);

    // Leaf sprout
    final leafPath = Path();
    leafPath.moveTo(w * 0.5, h * 0.12);
    leafPath.cubicTo(w * 0.38, h * 0.04, w * 0.44, h * 0.0, w * 0.54, h * 0.03);
    leafPath.cubicTo(w * 0.66, h * 0.02, w * 0.68, h * 0.08, w * 0.5, h * 0.12);
    canvas.drawPath(leafPath, fillPaint);

    // 2. Head (Rounded TV Monitor screen)
    final headRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.42),
        width: w * 0.70,
        height: h * 0.40,
      ),
      Radius.circular(w * 0.14),
    );
    canvas.drawRRect(headRect, strokePaint);

    // Eyes: Curved happy arcs (^  ^)
    final leftEye = Path();
    leftEye.moveTo(w * 0.38, h * 0.42);
    leftEye.quadraticBezierTo(w * 0.42, h * 0.38, w * 0.46, h * 0.42);
    canvas.drawPath(leftEye, strokePaint);

    final rightEye = Path();
    rightEye.moveTo(w * 0.54, h * 0.42);
    rightEye.quadraticBezierTo(w * 0.58, h * 0.38, w * 0.62, h * 0.42);
    canvas.drawPath(rightEye, strokePaint);

    // Smile mouth
    final mouth = Path();
    mouth.moveTo(w * 0.44, h * 0.48);
    mouth.quadraticBezierTo(w * 0.50, h * 0.53, w * 0.56, h * 0.48);
    canvas.drawPath(mouth, strokePaint);

    // 3. Body / Saucer Base
    final bodyPath = Path();
    bodyPath.moveTo(w * 0.32, h * 0.66);
    bodyPath.quadraticBezierTo(w * 0.30, h * 0.88, w * 0.50, h * 0.90);
    bodyPath.quadraticBezierTo(w * 0.70, h * 0.88, w * 0.68, h * 0.66);
    canvas.drawPath(bodyPath, strokePaint);

    // Circular dial / gauge on body
    canvas.drawCircle(Offset(w * 0.50, h * 0.77), w * 0.065, strokePaint);
    // Gauge needle
    canvas.drawLine(
      Offset(w * 0.50, h * 0.77),
      Offset(w * 0.50, h * 0.73),
      strokePaint..strokeWidth = size.width * 0.05,
    );

    // 4. Arms (Little friendly curved arms)
    final leftArm = Path();
    leftArm.moveTo(w * 0.28, h * 0.72);
    leftArm.quadraticBezierTo(w * 0.16, h * 0.68, w * 0.15, h * 0.56);
    canvas.drawPath(leftArm, strokePaint..strokeWidth = size.width * 0.065);

    final rightArm = Path();
    rightArm.moveTo(w * 0.72, h * 0.72);
    rightArm.quadraticBezierTo(w * 0.83, h * 0.74, w * 0.85, h * 0.64);
    canvas.drawPath(rightArm, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _NutriBotMascotPainter oldDelegate) =>
      oldDelegate.color != color;
}
