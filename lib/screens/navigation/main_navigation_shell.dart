import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/menu_controller.dart';
import '../beranda_screen.dart';
import '../galeri_menu_screen.dart';
import '../jadwal_screen.dart';
import '../pesan_hub_screen.dart';
import '../profile_screen.dart';

class MainNavigationShell extends StatefulWidget {
  final int initialIndex;

  const MainNavigationShell({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    context.read<NutriMealMenuController>().setBottomNavIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      BerandaScreen(
        onNavigateToGallery: () => _onTabTapped(1),
        onNavigateToSchedule: () => _onTabTapped(3),
        onNavigateToChat: () => _onTabTapped(2),
      ),
      const GaleriMenuScreen(),
      const PesanHubScreen(),
      const JadwalScreen(),
      const ProfileScreen(showBottomNav: true),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(
              color: Color(0xFFF1F5F9),
              width: 1.0,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 66,
            child: Row(
              children: [
                // 1. Beranda
                Expanded(
                  child: _buildNavItem(
                    index: 0,
                    icon: Icons.home_rounded,
                    label: 'Beranda',
                  ),
                ),

                // 2. Menu
                Expanded(
                  child: _buildNavItem(
                    index: 1,
                    icon: Icons.tune_rounded,
                    label: 'Menu',
                  ),
                ),

                // 3. Center Floating Mascot Button: Pesan
                Expanded(
                  child: _buildCenterMascotItem(),
                ),

                // 4. Jadwal (Calendar with Clock)
                Expanded(
                  child: _buildJadwalNavItem(index: 3),
                ),

                // 5. Profil
                Expanded(
                  child: _buildNavItem(
                    index: 4,
                    icon: Icons.person_outline_rounded,
                    label: 'Profil',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    final activeColor = const Color(0xFF16A34A);
    final inactiveColor = const Color(0xFF94A3B8);

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 23,
            color: isSelected ? activeColor : inactiveColor,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.5,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? activeColor : inactiveColor,
            ),
          ),
          const SizedBox(height: 2),
          // Active dot indicator
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: isSelected ? activeColor : Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJadwalNavItem({required int index}) {
    final isSelected = _currentIndex == index;
    final activeColor = const Color(0xFF16A34A);
    final inactiveColor = const Color(0xFF94A3B8);
    final itemColor = isSelected ? activeColor : inactiveColor;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: itemColor,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(0.5),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.access_time_rounded,
                      size: 10,
                      color: itemColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Jadwal',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.5,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: itemColor,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: isSelected ? activeColor : Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterMascotItem() {
    final isSelected = _currentIndex == 2;
    const mascotGreen = Color(0xFF1E6B43);

    return GestureDetector(
      onTap: () => _onTabTapped(2),
      behavior: HitTestBehavior.opaque,
      child: OverflowBox(
        maxHeight: 120,
        alignment: Alignment.center,
        child: Transform.translate(
          offset: const Offset(0, -14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Elevated Circular Button with white border & Mascot Image
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: mascotGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3.5),
                  boxShadow: [
                    BoxShadow(
                      color: mascotGreen.withValues(alpha: 0.30),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/images/nutribot_avatar.png',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Pesan',
                maxLines: 1,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                  color: isSelected ? const Color(0xFF16A34A) : mascotGreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
