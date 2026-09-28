import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class FoodDoodleBackground extends StatelessWidget {
  final Widget? child;
  final bool fillFull;

  const FoodDoodleBackground({
    super.key,
    this.child,
    this.fillFull = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.mintBackground,
      child: CustomPaint(
        painter: FoodDoodlePainter(),
        child: child,
      ),
    );
  }
}

class FoodDoodlePainter extends CustomPainter {
  final Color strokeColor;
  final double strokeWidth;

  FoodDoodlePainter({
    this.strokeColor = AppColors.doodleStroke,
    this.strokeWidth = 1.9,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Paint fillPaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.fill;

    final double w = size.width;
    final double h = size.height;

    // --- TOP SECTION (0.0 to 0.35 h) ---
    // Burger (top left)
    _drawBurger(canvas, Offset(w * 0.12, h * 0.055), 26, linePaint);

    // Soft Drink (top center)
    _drawDrinkCup(canvas, Offset(w * 0.49, h * 0.06), 26, linePaint);

    // Donut (top right)
    _drawDonut(canvas, Offset(w * 0.88, h * 0.045), 22, linePaint);

    // French fries (below donut on right)
    _drawFrenchFries(canvas, Offset(w * 0.80, h * 0.105), 28, linePaint);

    // Ice cream cone (far right, below fries)
    _drawIceCream(canvas, Offset(w * 0.90, h * 0.15), 24, linePaint, angle: 0.15);

    // Coffee bean (below cup, center)
    _drawCoffeeBean(canvas, Offset(w * 0.58, h * 0.095), 11, linePaint, angle: -0.3);

    // Salad / dumplings bowl (left, below burger)
    _drawBowl(canvas, Offset(w * 0.16, h * 0.14), 28, linePaint);

    // Popcorn box (center-left)
    _drawPopcorn(canvas, Offset(w * 0.53, h * 0.15), 24, linePaint);

    // Taco (center-right, near chicken)
    _drawTaco(canvas, Offset(w * 0.69, h * 0.12), 22, linePaint, angle: 0.3);

    // Cake slice (right side)
    _drawCake(canvas, Offset(w * 0.88, h * 0.22), 27, linePaint);

    // Chicken drumstick (center-left, angled down)
    _drawChicken(canvas, Offset(w * 0.48, h * 0.21), 28, linePaint, angle: 0.9);

    // Hotdog (far left)
    _drawHotdog(canvas, Offset(w * 0.11, h * 0.23), 25, linePaint, angle: 0.2);

    // Drink cup with straw (middle-right)
    _drawDrinkCup(canvas, Offset(w * 0.67, h * 0.23), 23, linePaint);

    // Fork and spoon (far right)
    _drawCutlery(canvas, Offset(w * 0.87, h * 0.29), 24, linePaint, angle: 0.2);

    // Sushi roll (left)
    _drawSushi(canvas, Offset(w * 0.15, h * 0.30), 22, linePaint);

    // Popcorn box (left-center)
    _drawPopcorn(canvas, Offset(w * 0.34, h * 0.29), 23, linePaint);

    // --- Sparkles & Dots in upper region ---
    _drawSparkle(canvas, Offset(w * 0.72, h * 0.08), 9, linePaint);
    _drawSparkle(canvas, Offset(w * 0.27, h * 0.19), 10, linePaint);
    _drawSparkle(canvas, Offset(w * 0.88, h * 0.19), 8, linePaint);
    _drawSparkle(canvas, Offset(w * 0.67, h * 0.18), 8, linePaint);
    _drawDot(canvas, Offset(w * 0.23, h * 0.09), 3.0, linePaint, false);
    _drawDot(canvas, Offset(w * 0.38, h * 0.11), 2.5, fillPaint, true);
    _drawDot(canvas, Offset(w * 0.77, h * 0.17), 2.5, fillPaint, true);
    _drawDot(canvas, Offset(w * 0.30, h * 0.25), 3.0, linePaint, false);
    _drawDot(canvas, Offset(w * 0.59, h * 0.27), 2.5, fillPaint, true);

    // --- MID / LOWER SECTION (0.35 to 1.0 h) for Splash screen ---
    // (In login screen, this is behind the white bottom sheet)

    // Cloche / food plate (left)
    _drawPlate(canvas, Offset(w * 0.10, h * 0.40), 28, linePaint);

    // Pizza slice (middle-right)
    _drawPizza(canvas, Offset(w * 0.63, h * 0.37), 26, linePaint, angle: 0.6);

    // Egg / Avocado (center-right)
    _drawEgg(canvas, Offset(w * 0.76, h * 0.38), 22, linePaint, angle: 0.3);

    // Salad bowl (right side)
    _drawBowl(canvas, Offset(w * 0.89, h * 0.41), 26, linePaint);

    // Popcorn box (middle-left)
    _drawPopcorn(canvas, Offset(w * 0.35, h * 0.44), 25, linePaint);

    // French fries (center-left)
    _drawFrenchFries(canvas, Offset(w * 0.68, h * 0.44), 26, linePaint);

    // Burger (lower left)
    _drawBurger(canvas, Offset(w * 0.13, h * 0.50), 26, linePaint);

    // Ice cream cone (center-left)
    _drawIceCream(canvas, Offset(w * 0.60, h * 0.51), 25, linePaint, angle: -0.1);

    // Drink cup with straw (right)
    _drawDrinkCup(canvas, Offset(w * 0.87, h * 0.51), 24, linePaint);

    // Egg (left-center)
    _drawEgg(canvas, Offset(w * 0.39, h * 0.57), 24, linePaint, angle: -0.2);

    // French fries (middle)
    _drawFrenchFries(canvas, Offset(w * 0.64, h * 0.60), 28, linePaint);

    // Hotdog (right-center)
    _drawHotdog(canvas, Offset(w * 0.87, h * 0.58), 25, linePaint, angle: 0.35);

    // Pizza slice (bottom left)
    _drawPizza(canvas, Offset(w * 0.16, h * 0.63), 28, linePaint, angle: -0.4);

    // Chicken drumstick (bottom center-left)
    _drawChicken(canvas, Offset(w * 0.45, h * 0.68), 29, linePaint, angle: -0.7);

    // Taco (bottom center-right)
    _drawTaco(canvas, Offset(w * 0.71, h * 0.70), 24, linePaint, angle: 0.1);

    // Donut (bottom left)
    _drawDonut(canvas, Offset(w * 0.16, h * 0.72), 23, linePaint);

    // Cutlery (bottom right)
    _drawCutlery(canvas, Offset(w * 0.88, h * 0.69), 25, linePaint, angle: 0.1);

    // Burger (bottom-most center-left)
    _drawBurger(canvas, Offset(w * 0.14, h * 0.82), 26, linePaint);

    // Drink cup (bottom right)
    _drawDrinkCup(canvas, Offset(w * 0.86, h * 0.83), 24, linePaint);

    // Popcorn (bottom center)
    _drawPopcorn(canvas, Offset(w * 0.48, h * 0.82), 24, linePaint);

    // Bowl (bottom-most center)
    _drawBowl(canvas, Offset(w * 0.68, h * 0.88), 26, linePaint);

    // Sparkles in bottom region
    _drawSparkle(canvas, Offset(w * 0.80, h * 0.48), 9, linePaint);
    _drawSparkle(canvas, Offset(w * 0.30, h * 0.62), 10, linePaint);
    _drawSparkle(canvas, Offset(w * 0.69, h * 0.63), 8, linePaint);
    _drawSparkle(canvas, Offset(w * 0.28, h * 0.74), 9, linePaint);
    _drawSparkle(canvas, Offset(w * 0.88, h * 0.78), 8, linePaint);

    // Dots in bottom region
    _drawDot(canvas, Offset(w * 0.28, h * 0.43), 2.5, fillPaint, true);
    _drawDot(canvas, Offset(w * 0.52, h * 0.45), 3.0, linePaint, false);
    _drawDot(canvas, Offset(w * 0.79, h * 0.56), 2.5, fillPaint, true);
    _drawDot(canvas, Offset(w * 0.10, h * 0.68), 3.0, linePaint, false);
    _drawDot(canvas, Offset(w * 0.54, h * 0.73), 2.5, fillPaint, true);
    _drawDot(canvas, Offset(w * 0.38, h * 0.82), 3.0, linePaint, false);
    _drawDot(canvas, Offset(w * 0.82, h * 0.89), 2.5, fillPaint, true);
  }

  // --- DRAWING PRIMITIVES ---

  void _drawBurger(Canvas canvas, Offset center, double size, Paint paint) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    final double s = size / 24.0;

    // Top Bun
    final Path topBun = Path();
    topBun.moveTo(-11 * s, 0);
    topBun.cubicTo(-11 * s, -9 * s, 11 * s, -9 * s, 11 * s, 0);
    topBun.close();
    canvas.drawPath(topBun, paint);

    // Sesame seeds on top bun
    final Paint seedPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(-4 * s, -4 * s), 1.0 * s, seedPaint);
    canvas.drawCircle(Offset(0, -6 * s), 1.0 * s, seedPaint);
    canvas.drawCircle(Offset(4 * s, -4 * s), 1.0 * s, seedPaint);

    // Lettuce wavy line
    final Path lettuce = Path();
    lettuce.moveTo(-12 * s, 3 * s);
    lettuce.quadraticBezierTo(-8 * s, 1 * s, -4 * s, 3 * s);
    lettuce.quadraticBezierTo(0, 5 * s, 4 * s, 3 * s);
    lettuce.quadraticBezierTo(8 * s, 1 * s, 12 * s, 3 * s);
    canvas.drawPath(lettuce, paint);

    // Patty
    final RRect patty = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(0, 6.5 * s), width: 23 * s, height: 3.5 * s),
      Radius.circular(2 * s),
    );
    canvas.drawRRect(patty, paint);

    // Bottom Bun
    final Path bottomBun = Path();
    bottomBun.moveTo(-11 * s, 9.5 * s);
    bottomBun.lineTo(11 * s, 9.5 * s);
    bottomBun.quadraticBezierTo(10 * s, 13 * s, 0, 13 * s);
    bottomBun.quadraticBezierTo(-10 * s, 13 * s, -11 * s, 9.5 * s);
    bottomBun.close();
    canvas.drawPath(bottomBun, paint);

    canvas.restore();
  }

  void _drawDrinkCup(Canvas canvas, Offset center, double size, Paint paint) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    final double s = size / 24.0;

    // Slanted Cup Body
    final Path cup = Path();
    cup.moveTo(-7 * s, -4 * s);
    cup.lineTo(7 * s, -4 * s);
    cup.lineTo(5 * s, 12 * s);
    cup.lineTo(-5 * s, 12 * s);
    cup.close();
    canvas.drawPath(cup, paint);

    // Lid Rim
    final RRect lid = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(0, -4.5 * s), width: 17 * s, height: 2.5 * s),
      Radius.circular(1.2 * s),
    );
    canvas.drawRRect(lid, paint);

    // Dome Lid
    final Path dome = Path();
    dome.moveTo(-6 * s, -5.5 * s);
    dome.quadraticBezierTo(0, -9.5 * s, 6 * s, -5.5 * s);
    canvas.drawPath(dome, paint);

    // Straw with diagonal bend
    final Path straw = Path();
    straw.moveTo(1 * s, -7.5 * s);
    straw.lineTo(4 * s, -14 * s);
    straw.lineTo(8 * s, -16 * s);
    canvas.drawPath(straw, paint);

    // Bubbles inside
    canvas.drawCircle(Offset(-2 * s, 2 * s), 1.2 * s, paint);
    canvas.drawCircle(Offset(2 * s, 6 * s), 1.4 * s, paint);
    canvas.drawCircle(Offset(-1 * s, 9 * s), 1.1 * s, paint);

    canvas.restore();
  }

  void _drawFrenchFries(Canvas canvas, Offset center, double size, Paint paint) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    final double s = size / 24.0;

    // Fry Container Box
    final Path box = Path();
    box.moveTo(-9 * s, -1 * s);
    box.lineTo(-7 * s, 12 * s);
    box.lineTo(7 * s, 12 * s);
    box.lineTo(9 * s, -1 * s);
    box.quadraticBezierTo(0, 3 * s, -9 * s, -1 * s);
    canvas.drawPath(box, paint);

    // Horizontal Accent Line on Box
    final Path accent = Path();
    accent.moveTo(-8 * s, 4 * s);
    accent.quadraticBezierTo(0, 7 * s, 8 * s, 4 * s);
    canvas.drawPath(accent, paint);

    // Fry sticks poking out
    // Stick 1
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-6 * s, -12 * s, 2.5 * s, 11 * s),
        Radius.circular(1 * s),
      ),
      paint,
    );
    // Stick 2
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-2.5 * s, -15 * s, 2.5 * s, 14 * s),
        Radius.circular(1 * s),
      ),
      paint,
    );
    // Stick 3
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(1 * s, -13 * s, 2.5 * s, 12 * s),
        Radius.circular(1 * s),
      ),
      paint,
    );
    // Stick 4
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(4.5 * s, -10 * s, 2.2 * s, 9 * s),
        Radius.circular(1 * s),
      ),
      paint,
    );

    canvas.restore();
  }

  void _drawDonut(Canvas canvas, Offset center, double size, Paint paint) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    final double s = size / 24.0;

    // Outer Circle
    canvas.drawCircle(Offset.zero, 11 * s, paint);

    // Inner Hole
    canvas.drawCircle(Offset.zero, 4 * s, paint);

    // Glaze wavy line
    final Path glaze = Path();
    for (int i = 0; i < 8; i++) {
      final double angle1 = i * (math.pi / 4);
      final double r = (i % 2 == 0) ? 8.5 * s : 6.5 * s;
      final double x = r * math.cos(angle1);
      final double y = r * math.sin(angle1);
      if (i == 0) {
        glaze.moveTo(x, y);
      } else {
        glaze.lineTo(x, y);
      }
    }
    glaze.close();
    canvas.drawPath(glaze, paint);

    // Tiny sprinkles
    final Paint fill = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(-6 * s, -4 * s), 0.9 * s, fill);
    canvas.drawCircle(Offset(5 * s, -5 * s), 0.9 * s, fill);
    canvas.drawCircle(Offset(-4 * s, 6 * s), 0.9 * s, fill);
    canvas.drawCircle(Offset(6 * s, 4 * s), 0.9 * s, fill);

    canvas.restore();
  }

  void _drawBowl(Canvas canvas, Offset center, double size, Paint paint) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    final double s = size / 24.0;

    // Wide Bowl Body
    final Path bowl = Path();
    bowl.moveTo(-13 * s, 0);
    bowl.quadraticBezierTo(-13 * s, 10 * s, -6 * s, 11 * s);
    bowl.lineTo(6 * s, 11 * s);
    bowl.quadraticBezierTo(13 * s, 10 * s, 13 * s, 0);
    bowl.lineTo(-13 * s, 0);
    canvas.drawPath(bowl, paint);

    // Bowl Stand Base
    final Path base = Path();
    base.moveTo(-5 * s, 11 * s);
    base.lineTo(-6 * s, 13 * s);
    base.lineTo(6 * s, 13 * s);
    base.lineTo(5 * s, 11 * s);
    canvas.drawPath(base, paint);

    // 3 Food Scoops / Dumplings / Fruit
    canvas.drawCircle(Offset(-6 * s, -2 * s), 4 * s, paint);
    canvas.drawCircle(Offset(0, -4 * s), 4.2 * s, paint);
    canvas.drawCircle(Offset(6 * s, -2 * s), 4 * s, paint);

    // Chopsticks or Spoon Angle
    canvas.drawLine(Offset(6 * s, -3 * s), Offset(13 * s, -11 * s), paint);

    canvas.restore();
  }

  void _drawPopcorn(Canvas canvas, Offset center, double size, Paint paint) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    final double s = size / 24.0;

    // Tapered Box
    final Path box = Path();
    box.moveTo(-7 * s, -1 * s);
    box.lineTo(-5 * s, 12 * s);
    box.lineTo(5 * s, 12 * s);
    box.lineTo(7 * s, -1 * s);
    box.close();
    canvas.drawPath(box, paint);

    // Stripes
    canvas.drawLine(Offset(-2.5 * s, 0), Offset(-1.8 * s, 12 * s), paint);
    canvas.drawLine(Offset(2.5 * s, 0), Offset(1.8 * s, 12 * s), paint);

    // Popcorn Clouds on top
    canvas.drawCircle(Offset(-5 * s, -4 * s), 3.2 * s, paint);
    canvas.drawCircle(Offset(-1.5 * s, -7 * s), 3.5 * s, paint);
    canvas.drawCircle(Offset(3 * s, -6 * s), 3.4 * s, paint);
    canvas.drawCircle(Offset(5 * s, -3 * s), 3.0 * s, paint);

    canvas.restore();
  }

  void _drawIceCream(Canvas canvas, Offset center, double size, Paint paint, {double angle = 0}) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    final double s = size / 24.0;

    // Triangle Cone
    final Path cone = Path();
    cone.moveTo(-6 * s, 0);
    cone.lineTo(6 * s, 0);
    cone.lineTo(0, 14 * s);
    cone.close();
    canvas.drawPath(cone, paint);

    // Cone waffle grid lines
    canvas.drawLine(Offset(-3 * s, 4 * s), Offset(3 * s, 6 * s), paint);
    canvas.drawLine(Offset(-1 * s, 9 * s), Offset(2 * s, 10 * s), paint);

    // Soft-serve swirl
    final Path swirl = Path();
    swirl.moveTo(-6.5 * s, 0);
    swirl.quadraticBezierTo(-7 * s, -4 * s, -4 * s, -5 * s);
    swirl.quadraticBezierTo(-6 * s, -8 * s, -2 * s, -9 * s);
    swirl.quadraticBezierTo(-3 * s, -13 * s, 0, -14 * s);
    swirl.quadraticBezierTo(2 * s, -11 * s, 2 * s, -9 * s);
    swirl.quadraticBezierTo(6 * s, -8 * s, 4 * s, -5 * s);
    swirl.quadraticBezierTo(7 * s, -4 * s, 6.5 * s, 0);
    canvas.drawPath(swirl, paint);

    canvas.restore();
  }

  void _drawCake(Canvas canvas, Offset center, double size, Paint paint) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    final double s = size / 24.0;

    // Isometric Triangle Cake Slice
    final Path cake = Path();
    cake.moveTo(-10 * s, 6 * s);
    cake.lineTo(10 * s, -4 * s);
    cake.lineTo(12 * s, 4 * s);
    cake.lineTo(-8 * s, 12 * s);
    cake.close();
    canvas.drawPath(cake, paint);

    // Top Surface
    final Path top = Path();
    top.moveTo(-10 * s, 6 * s);
    top.lineTo(10 * s, -4 * s);
    top.lineTo(3 * s, -10 * s);
    top.lineTo(-11 * s, -2 * s);
    top.close();
    canvas.drawPath(top, paint);

    // Cake Layer Line
    canvas.drawLine(Offset(-9 * s, 9 * s), Offset(11 * s, 0), paint);

    // Cherry on top
    canvas.drawCircle(Offset(-2 * s, -8 * s), 2.5 * s, paint);
    final Path stem = Path();
    stem.moveTo(-2 * s, -10.5 * s);
    stem.quadraticBezierTo(0, -14 * s, 3 * s, -13 * s);
    canvas.drawPath(stem, paint);

    canvas.restore();
  }

  void _drawChicken(Canvas canvas, Offset center, double size, Paint paint, {double angle = 0}) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    final double s = size / 24.0;

    // Drumstick Meat (teardrop bulb)
    final Path meat = Path();
    meat.moveTo(0, -12 * s);
    meat.cubicTo(11 * s, -8 * s, 11 * s, 5 * s, 3 * s, 8 * s);
    meat.lineTo(-3 * s, 8 * s);
    meat.cubicTo(-11 * s, 5 * s, -11 * s, -8 * s, 0, -12 * s);
    canvas.drawPath(meat, paint);

    // Bone with two rounded knobs
    canvas.drawLine(Offset(-1.5 * s, 8 * s), Offset(-1.5 * s, 12 * s), paint);
    canvas.drawLine(Offset(1.5 * s, 8 * s), Offset(1.5 * s, 12 * s), paint);
    canvas.drawCircle(Offset(-3 * s, 13 * s), 2.2 * s, paint);
    canvas.drawCircle(Offset(3 * s, 13 * s), 2.2 * s, paint);

    canvas.restore();
  }

  void _drawTaco(Canvas canvas, Offset center, double size, Paint paint, {double angle = 0}) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    final double s = size / 24.0;

    // Taco Shell
    final Path shell = Path();
    shell.moveTo(-11 * s, 3 * s);
    shell.quadraticBezierTo(0, -11 * s, 11 * s, 3 * s);
    shell.quadraticBezierTo(0, 11 * s, -11 * s, 3 * s);
    canvas.drawPath(shell, paint);

    // Fillings peeking
    final Path filling = Path();
    filling.moveTo(-9 * s, 1 * s);
    filling.quadraticBezierTo(-5 * s, -4 * s, -1 * s, 0);
    filling.quadraticBezierTo(3 * s, -4 * s, 8 * s, 1 * s);
    canvas.drawPath(filling, paint);

    // Filling dots
    final Paint fill = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(-4 * s, 1 * s), 1.0 * s, fill);
    canvas.drawCircle(Offset(2 * s, 0), 1.0 * s, fill);

    canvas.restore();
  }

  void _drawSushi(Canvas canvas, Offset center, double size, Paint paint) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    final double s = size / 24.0;

    // Cylinder Roll
    canvas.drawOval(
      Rect.fromCenter(center: Offset(0, -4 * s), width: 18 * s, height: 10 * s),
      paint,
    );

    final Path side = Path();
    side.moveTo(-9 * s, -4 * s);
    side.lineTo(-9 * s, 5 * s);
    side.quadraticBezierTo(0, 10 * s, 9 * s, 5 * s);
    side.lineTo(9 * s, -4 * s);
    canvas.drawPath(side, paint);

    // Inner filling
    canvas.drawOval(
      Rect.fromCenter(center: Offset(0, -4 * s), width: 8 * s, height: 4.5 * s),
      paint,
    );

    canvas.restore();
  }

  void _drawPizza(Canvas canvas, Offset center, double size, Paint paint, {double angle = 0}) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    final double s = size / 24.0;

    // Wedge
    final Path slice = Path();
    slice.moveTo(0, 13 * s);
    slice.lineTo(-10 * s, -9 * s);
    slice.quadraticBezierTo(0, -13 * s, 10 * s, -9 * s);
    slice.close();
    canvas.drawPath(slice, paint);

    // Crust Arc
    final Path crust = Path();
    crust.moveTo(-9.5 * s, -7.5 * s);
    crust.quadraticBezierTo(0, -11.5 * s, 9.5 * s, -7.5 * s);
    canvas.drawPath(crust, paint);

    // Pepperonis
    canvas.drawCircle(Offset(-3 * s, -3 * s), 2.2 * s, paint);
    canvas.drawCircle(Offset(3.5 * s, -2 * s), 2.2 * s, paint);
    canvas.drawCircle(Offset(0, 4 * s), 2.2 * s, paint);

    canvas.restore();
  }

  void _drawEgg(Canvas canvas, Offset center, double size, Paint paint, {double angle = 0}) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    final double s = size / 24.0;

    // Oval egg silhouette
    final Rect eggRect = Rect.fromCenter(center: Offset.zero, width: 17 * s, height: 23 * s);
    canvas.drawOval(eggRect, paint);

    // Yolk in center
    canvas.drawCircle(Offset(0, 1 * s), 5 * s, paint);

    canvas.restore();
  }

  void _drawHotdog(Canvas canvas, Offset center, double size, Paint paint, {double angle = 0}) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    final double s = size / 24.0;

    // Bun
    final RRect bun = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: 24 * s, height: 11 * s),
      Radius.circular(5.5 * s),
    );
    canvas.drawRRect(bun, paint);

    // Sausage
    final RRect sausage = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: 28 * s, height: 7 * s),
      Radius.circular(3.5 * s),
    );
    canvas.drawRRect(sausage, paint);

    // Mustard squiggle
    final Path mustard = Path();
    mustard.moveTo(-10 * s, 0);
    mustard.quadraticBezierTo(-6 * s, -2 * s, -3 * s, 0);
    mustard.quadraticBezierTo(0, 2 * s, 3 * s, 0);
    mustard.quadraticBezierTo(6 * s, -2 * s, 10 * s, 0);
    canvas.drawPath(mustard, paint);

    canvas.restore();
  }

  void _drawPlate(Canvas canvas, Offset center, double size, Paint paint) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    final double s = size / 24.0;

    // Plate Ellipse
    canvas.drawOval(
      Rect.fromCenter(center: Offset(0, 3 * s), width: 24 * s, height: 8 * s),
      paint,
    );

    // Cloche Dome
    final Path cloche = Path();
    cloche.moveTo(-9 * s, 3 * s);
    cloche.quadraticBezierTo(0, -9 * s, 9 * s, 3 * s);
    canvas.drawPath(cloche, paint);

    // Handle
    canvas.drawCircle(Offset(0, -9 * s), 1.8 * s, paint);

    canvas.restore();
  }

  void _drawCutlery(Canvas canvas, Offset center, double size, Paint paint, {double angle = 0}) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    final double s = size / 24.0;

    // Fork (Left)
    canvas.drawLine(Offset(-4 * s, -8 * s), Offset(-4 * s, 12 * s), paint);
    canvas.drawLine(Offset(-6.5 * s, -8 * s), Offset(-6.5 * s, -4 * s), paint);
    canvas.drawLine(Offset(-1.5 * s, -8 * s), Offset(-1.5 * s, -4 * s), paint);
    canvas.drawLine(Offset(-6.5 * s, -4 * s), Offset(-1.5 * s, -4 * s), paint);

    // Spoon (Right)
    canvas.drawLine(Offset(4 * s, -3 * s), Offset(4 * s, 12 * s), paint);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(4 * s, -7 * s), width: 5.5 * s, height: 8 * s),
      paint,
    );

    canvas.restore();
  }

  void _drawCoffeeBean(Canvas canvas, Offset center, double size, Paint paint, {double angle = 0}) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    final double s = size / 12.0;

    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 9 * s, height: 12 * s),
      paint,
    );

    final Path seam = Path();
    seam.moveTo(0, -5 * s);
    seam.quadraticBezierTo(-2.5 * s, 0, 0, 5 * s);
    canvas.drawPath(seam, paint);

    canvas.restore();
  }

  void _drawSparkle(Canvas canvas, Offset center, double size, Paint paint) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    final double r = size / 2;

    final Path star = Path();
    star.moveTo(0, -r);
    star.quadraticBezierTo(0, 0, r, 0);
    star.quadraticBezierTo(0, 0, 0, r);
    star.quadraticBezierTo(0, 0, -r, 0);
    star.quadraticBezierTo(0, 0, 0, -r);
    canvas.drawPath(star, paint);

    canvas.restore();
  }

  void _drawDot(Canvas canvas, Offset center, double radius, Paint paint, bool filled) {
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
