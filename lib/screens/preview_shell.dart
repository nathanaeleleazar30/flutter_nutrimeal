import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/menu_controller.dart';
import '../core/constants/app_colors.dart';
import 'address_screen.dart';
import 'admin_chat_screen.dart';
import 'bantuan_faq_screen.dart';
import 'beranda_screen.dart';
import 'checkout_screen.dart';
import 'galeri_menu_screen.dart';
import 'jadwal_screen.dart';
import 'keranjang_screen.dart';
import 'langganan_katalog_screen.dart';
import 'langganan_saya_screen.dart';
import 'login_screen.dart';
import 'main_navigation_shell.dart';
import 'menu_detail_screen.dart';
import 'notifikasi_screen.dart';
import 'nutribot_chat_screen.dart';
import 'profile_detail_screen.dart';
import 'profile_screen.dart';

enum ViewMode {
  jadwal,
  chatAi,
  chatAdmin,
  profil,
  profilDetail,
  notifikasi,
  bantuanFaq,
  langgananSaya,
  langgananKatalog,
  keranjang,
  checkout,
  alamat,
  beranda,
  galeriMenu,
  detailMenu,
  navigationShell,
  login,
  allScreens,
}

class PreviewShell extends StatefulWidget {
  const PreviewShell({super.key});

  @override
  State<PreviewShell> createState() => _PreviewShellState();
}

class _PreviewShellState extends State<PreviewShell> {
  ViewMode _currentMode = ViewMode.jadwal;

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
                        title: 'Jadwal',
                        icon: Icons.calendar_today_rounded,
                        mode: ViewMode.jadwal,
                      ),
                      _buildSwitchItem(
                        title: 'Chat AI (NutriBot)',
                        icon: Icons.smart_toy_rounded,
                        mode: ViewMode.chatAi,
                      ),
                      _buildSwitchItem(
                        title: 'Chat Admin',
                        icon: Icons.support_agent_rounded,
                        mode: ViewMode.chatAdmin,
                      ),
                      _buildSwitchItem(
                        title: 'Profil',
                        icon: Icons.person_rounded,
                        mode: ViewMode.profil,
                      ),
                      _buildSwitchItem(
                        title: 'Detail Profil',
                        icon: Icons.badge_rounded,
                        mode: ViewMode.profilDetail,
                      ),
                      _buildSwitchItem(
                        title: 'Notifikasi',
                        icon: Icons.notifications_rounded,
                        mode: ViewMode.notifikasi,
                      ),
                      _buildSwitchItem(
                        title: 'Bantuan & FAQ',
                        icon: Icons.help_outline_rounded,
                        mode: ViewMode.bantuanFaq,
                      ),
                      _buildSwitchItem(
                        title: 'Langganan Saya',
                        icon: Icons.card_membership_rounded,
                        mode: ViewMode.langgananSaya,
                      ),
                      _buildSwitchItem(
                        title: 'Katalog Langganan',
                        icon: Icons.local_offer_rounded,
                        mode: ViewMode.langgananKatalog,
                      ),
                      _buildSwitchItem(
                        title: 'Keranjang',
                        icon: Icons.shopping_bag_rounded,
                        mode: ViewMode.keranjang,
                      ),
                      _buildSwitchItem(
                        title: 'Checkout',
                        icon: Icons.payment_rounded,
                        mode: ViewMode.checkout,
                      ),
                      _buildSwitchItem(
                        title: 'Alamat',
                        icon: Icons.location_on_rounded,
                        mode: ViewMode.alamat,
                      ),
                      _buildSwitchItem(
                        title: 'Beranda',
                        icon: Icons.home_rounded,
                        mode: ViewMode.beranda,
                      ),
                      _buildSwitchItem(
                        title: 'Galeri Menu',
                        icon: Icons.restaurant_menu_rounded,
                        mode: ViewMode.galeriMenu,
                      ),
                      _buildSwitchItem(
                        title: 'App Shell',
                        icon: Icons.smartphone_rounded,
                        mode: ViewMode.navigationShell,
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
      case ViewMode.jadwal:
        return const JadwalScreen();
      case ViewMode.chatAi:
        return const NutriBotChatScreen();
      case ViewMode.chatAdmin:
        return const AdminChatScreen();
      case ViewMode.profil:
        return const ProfileScreen();
      case ViewMode.profilDetail:
        return const ProfileDetailScreen();
      case ViewMode.notifikasi:
        return const NotifikasiScreen();
      case ViewMode.bantuanFaq:
        return const BantuanFaqScreen();
      case ViewMode.langgananSaya:
        return const LanggananSayaScreen();
      case ViewMode.langgananKatalog:
        return const LanggananKatalogScreen();
      case ViewMode.keranjang:
        return const KeranjangScreen();
      case ViewMode.checkout:
        return const CheckoutScreen();
      case ViewMode.alamat:
        return const AddressScreen();
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
      case ViewMode.allScreens:
        return _buildAllScreensGallery();
    }
  }

  Widget _buildAllScreensGallery() {
    final menuController = context.watch<NutriMealMenuController>();

    final screens = [
      {
        'title': '1. Jadwal Katering (Frame 35)',
        'widget': const JadwalScreen(),
      },
      {
        'title': '2. NutriBot AI Chat (Frame 33)',
        'widget': const NutriBotChatScreen(),
      },
      {
        'title': '3. Admin NutriCare Chat (Frame Pesan)',
        'widget': const AdminChatScreen(),
      },
      {
        'title': '4. Profil Saya (Frame 36)',
        'widget': const ProfileScreen(),
      },
      {
        'title': '5. Detail Data Profil (Frame 29)',
        'widget': const ProfileDetailScreen(),
      },
      {
        'title': '6. Pusat Bantuan & FAQ (NutriBot 24/7)',
        'widget': const BantuanFaqScreen(),
      },
      {
        'title': '7. Notifikasi (Update & Promo)',
        'widget': const NotifikasiScreen(),
      },
      {
        'title': '8. Langganan Saya (Paket Aktif)',
        'widget': const LanggananSayaScreen(showBottomNav: false),
      },
      {
        'title': '9. Katalog Langganan (Pilih Paket)',
        'widget': const LanggananKatalogScreen(showBottomNav: false),
      },
      {
        'title': '10. Keranjang Saya (Cart UI)',
        'widget': const KeranjangScreen(),
      },
      {
        'title': '11. Checkout & Konfirmasi Pesanan',
        'widget': const CheckoutScreen(),
      },
      {
        'title': '12. Beranda (Home)',
        'widget': const BerandaScreen(),
      },
      {
        'title': '13. Galeri Menu',
        'widget': const GaleriMenuScreen(),
      },
      {
        'title': '14. Detail Menu (Grilled Chicken)',
        'widget': MenuDetailScreen(item: menuController.allMenuItems[0]),
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
