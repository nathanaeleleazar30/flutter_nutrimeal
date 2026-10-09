import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/food_doodle_background.dart';
import '../widgets/nutri_meal_logo.dart';

class SplashScreen extends StatefulWidget {
  final bool autoNavigate;

  const SplashScreen({
    super.key,
    this.autoNavigate = true,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.autoNavigate) {
      _timer = Timer(const Duration(milliseconds: 2500), () {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _goToLogin() {
    _timer?.cancel();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _goToLogin,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // Full-screen food doodle background
            const Positioned.fill(
              child: FoodDoodleBackground(fillFull: true),
            ),

            // Centered Nutri Meal Logo
            const Center(
              child: NutriMealLogo(
                fontSize: 38,
                hasShadow: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
