import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/menu_controller.dart';
import '../core/constants/app_colors.dart';
import 'beranda_screen.dart';
import 'galeri_menu_screen.dart';
import 'login_screen.dart';
import 'main_navigation_shell.dart';
import 'menu_detail_screen.dart';
import 'register_screen.dart';

enum ViewMode {
  beranda,
  galeriMenu,
  detailMenu,
  navigationShell,
  login,
  register,
  allScreens,
}

class PreviewShell extends StatefulWidget {
  const PreviewShell({super.key});

  @override
  State<PreviewShell> createState() => _PreviewShellState();
}

class _PreviewShellState extends State<PreviewShell> {
  ViewMode _currentMode = ViewMode.beranda;

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
                        title: '1. Beranda',
                        icon: Icons.home_rounded,
                        mode: ViewMode.beranda,
                      ),
                      _buildSwitchItem(
                        title: '2. Galeri Menu',
                        icon: Icons.restaurant_menu_rounded,
                        mode: ViewMode.galeriMenu,
                      ),
                      _buildSwitchItem(
                        title: '3. Detail Menu',
                        icon: Icons.dinner_dining_rounded,
                        mode: ViewMode.detailMenu,
                      ),
                      _buildSwitchItem(
                        title: 'App + BottomNav',
                        icon: Icons.smartphone_rounded,
                        mode: ViewMode.navigationShell,
                      ),
                      _buildSwitchItem(
                        title: 'Login (Dummy)',
                        icon: Icons.login_rounded,
                        mode: ViewMode.login,
                      ),
                      _buildSwitchItem(
                        title: 'Register (Dummy)',
                        icon: Icons.person_add_rounded,
                        mode: ViewMode.register,
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
    final menuController = context.watch<NutriMealMenuController>();

    switch (_currentMode) {
      case ViewMode.beranda:
        return BerandaScreen(
          onNavigateToGallery: () {
            setState(() {
              _currentMode = ViewMode.galeriMenu;
            });
          },
        );
      case ViewMode.galeriMenu:
        return const GaleriMenuScreen();
      case ViewMode.detailMenu:
        return MenuDetailScreen(item: menuController.selectedMenuItem);
      case ViewMode.navigationShell:
        return const MainNavigationShell();
      case ViewMode.login:
        return const LoginScreen();
      case ViewMode.register:
        return const RegisterScreen();
      case ViewMode.allScreens:
        return _buildAllScreensGallery();
    }
  }

  Widget _buildAllScreensGallery() {
    final menuController = context.watch<NutriMealMenuController>();

    final screens = [
      {
        'title': '1. Beranda (Home)',
        'widget': const BerandaScreen(),
      },
      {
        'title': '2. Galeri Menu',
        'widget': const GaleriMenuScreen(),
      },
      {
        'title': '3. Detail Menu (Grilled Chicken)',
        'widget': MenuDetailScreen(item: menuController.allMenuItems[0]),
      },
      {
        'title': '4. Login (Siap Masuk)',
        'widget': const LoginScreen(),
      },
      {
        'title': '5. Register (Siap Daftar)',
        'widget': const RegisterScreen(),
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
