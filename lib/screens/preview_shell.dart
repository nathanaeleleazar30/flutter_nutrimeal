import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../widgets/google_account_sheet.dart';
import 'forgot_password_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'verify_email_screen.dart';

enum ViewMode {
  login,
  register,
  googleModal,
  registerError,
  forgotPassword,
  verifyEmail,
  allScreens,
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
      backgroundColor: const Color(0xFF1E293B),
      body: Stack(
        children: [
          // Content based on selected mode
          Positioned.fill(
            child: _buildCurrentView(),
          ),

          // Floating Mode Switcher at bottom
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.90),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSwitchItem(
                        title: '1. Login',
                        icon: Icons.login_rounded,
                        mode: ViewMode.login,
                      ),
                      _buildSwitchItem(
                        title: '2. Register',
                        icon: Icons.person_add_rounded,
                        mode: ViewMode.register,
                      ),
                      _buildSwitchItem(
                        title: '3. Google Pop-up',
                        icon: Icons.account_circle_rounded,
                        mode: ViewMode.googleModal,
                      ),
                      _buildSwitchItem(
                        title: '4. Error Form',
                        icon: Icons.error_outline_rounded,
                        mode: ViewMode.registerError,
                      ),
                      _buildSwitchItem(
                        title: '5. Forgot Pass',
                        icon: Icons.lock_reset_rounded,
                        mode: ViewMode.forgotPassword,
                      ),
                      _buildSwitchItem(
                        title: '7. Verifikasi',
                        icon: Icons.mark_email_read_rounded,
                        mode: ViewMode.verifyEmail,
                      ),
                      _buildSwitchItem(
                        title: 'Semua Screen',
                        icon: Icons.grid_view_rounded,
                        mode: ViewMode.allScreens,
                      ),
                    ],
                  ),
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
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : Colors.white70,
            ),
            const SizedBox(width: 5),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 11.5,
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
      case ViewMode.login:
        return const LoginScreen();
      case ViewMode.register:
        return const RegisterScreen();
      case ViewMode.googleModal:
        return Stack(
          children: [
            const LoginScreen(),
            Container(
              color: Colors.black.withValues(alpha: 0.55),
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: GoogleAccountSheet(),
            ),
          ],
        );
      case ViewMode.registerError:
        return const RegisterScreen(initialShowErrors: true);
      case ViewMode.forgotPassword:
        return const ForgotPasswordScreen();
      case ViewMode.verifyEmail:
        return const VerifyEmailScreen();
      case ViewMode.allScreens:
        return _buildAllScreensGallery();
    }
  }

  Widget _buildAllScreensGallery() {
    final screens = [
      {'title': '1. Login Screen', 'widget': const LoginScreen()},
      {'title': '2. Register Screen', 'widget': const RegisterScreen()},
      {
        'title': '3. Google Account Sheet',
        'widget': Stack(
          children: [
            const LoginScreen(),
            Container(color: Colors.black.withValues(alpha: 0.55)),
            const Align(
              alignment: Alignment.bottomCenter,
              child: GoogleAccountSheet(),
            ),
          ],
        ),
      },
      {
        'title': '4. Register Validation Errors',
        'widget': const RegisterScreen(initialShowErrors: true),
      },
      {
        'title': '5. Forgot Password',
        'widget': const ForgotPasswordScreen(),
      },
      {
        'title': '7. Periksa Email (Verify OTP)',
        'widget': const VerifyEmailScreen(),
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: screens.map((item) {
          return Padding(
            padding: const EdgeInsets.only(right: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    item['title'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _buildPhoneMockup(
                  width: 360,
                  height: 740,
                  child: item['widget'] as Widget,
                ),
                const SizedBox(height: 70),
              ],
            ),
          );
        }).toList(),
      ),
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
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
