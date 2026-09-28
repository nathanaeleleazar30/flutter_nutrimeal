import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import 'login_screen.dart';
import 'splash_screen.dart';

enum ViewMode {
  splash,
  login,
  sideBySide,
}

class PreviewShell extends StatefulWidget {
  const PreviewShell({super.key});

  @override
  State<PreviewShell> createState() => _PreviewShellState();
}

class _PreviewShellState extends State<PreviewShell> {
  ViewMode _currentMode = ViewMode.login;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC8CBD0),
      body: Stack(
        children: [
          // Content based on selected mode
          Positioned.fill(
            child: _buildCurrentView(),
          ),

          // Top / Bottom Floating Mode Switcher
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSwitchItem(
                      title: 'Splash',
                      icon: Icons.flash_on_rounded,
                      mode: ViewMode.splash,
                    ),
                    _buildSwitchItem(
                      title: 'Login',
                      icon: Icons.login_rounded,
                      mode: ViewMode.login,
                    ),
                    _buildSwitchItem(
                      title: 'Side-by-Side',
                      icon: Icons.view_column_rounded,
                      mode: ViewMode.sideBySide,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchItem({
    required String title,
    required IconData icon,
    required ViewMode mode,
  }) {
    final bool isSelected = _currentMode == mode;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentMode = mode;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.white70,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_currentMode) {
      case ViewMode.splash:
        return const SplashScreen(autoNavigate: false);
      case ViewMode.login:
        return const LoginScreen();
      case ViewMode.sideBySide:
        return _buildSideBySideView();
    }
  }

  Widget _buildSideBySideView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenWidth = constraints.maxWidth;
        final double screenHeight = constraints.maxHeight;

        // Calculate card dimensions to fit nicely side by side
        double phoneWidth = 360;
        double phoneHeight = 780;

        // If screen is smaller or larger, scale proportionally
        if (screenWidth < 780) {
          // Horizontal scrollable
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPhoneMockup(
                  width: phoneWidth,
                  height: phoneHeight,
                  child: const SplashScreen(autoNavigate: false),
                ),
                const SizedBox(width: 32),
                _buildPhoneMockup(
                  width: phoneWidth,
                  height: phoneHeight,
                  child: const LoginScreen(),
                ),
              ],
            ),
          );
        }

        final double availableHeight = screenHeight - 120;
        if (availableHeight < phoneHeight) {
          phoneHeight = availableHeight.clamp(500, 780);
          phoneWidth = phoneHeight * (9.0 / 19.5);
        }

        return Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildPhoneMockup(
                    width: phoneWidth,
                    height: phoneHeight,
                    child: const SplashScreen(autoNavigate: false),
                  ),
                  const SizedBox(width: 40),
                  _buildPhoneMockup(
                    width: phoneWidth,
                    height: phoneHeight,
                    child: const LoginScreen(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhoneMockup({
    required double width,
    required double height,
    required Widget child,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
