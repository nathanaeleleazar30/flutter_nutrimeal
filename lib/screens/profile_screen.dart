import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../widgets/main_top_bar.dart';
import 'address_screen.dart';
import 'bantuan_faq_screen.dart';
import 'langganan_saya_screen.dart';
import 'profile_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onCartTap;
  final bool showBottomNav;

  const ProfileScreen({
    super.key,
    this.onCartTap,
    this.showBottomNav = false,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Konfirmasi Keluar',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari akun NutriMeal?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/login', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Keluar',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar (Matching MainTopBar with brand logo & action buttons)
            MainTopBar(
              onCartTap: widget.onCartTap,
              onProfileTap: () {},
            ),

            // Profile Body Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    // 1. Avatar & Profile Header (Image 2)
                    _buildUserHeader(),
                    const SizedBox(height: 18),

                    // 2. White Card Container for Account Menus
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // SECTION: AKUN
                          _buildSectionLabel('AKUN'),
                          const SizedBox(height: 8),
                          _buildMenuItemRow(
                            icon: Icons.person_outline_rounded,
                            iconColor: const Color(0xFF64748B),
                            iconBg: const Color(0xFFF1F5F9),
                            title: 'Informasi Pribadi',
                            subtitle: 'Ubah nama, email, no. telp',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const ProfileDetailScreen()),
                              );
                            },
                          ),
                          const Divider(height: 20, color: Color(0xFFF1F5F9)),
                          _buildMenuItemRow(
                            icon: Icons.location_on_outlined,
                            iconColor: const Color(0xFF64748B),
                            iconBg: const Color(0xFFF1F5F9),
                            title: 'Alamat Pengiriman',
                            subtitle: 'Atur alamat kantor & rumah',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const AddressScreen()),
                              );
                            },
                          ),
                          const SizedBox(height: 16),

                          // SECTION: TRANSAKSI
                          _buildSectionLabel('TRANSAKSI'),
                          const SizedBox(height: 8),
                          _buildMenuItemRow(
                            icon: Icons.credit_card_outlined,
                            iconColor: const Color(0xFF64748B),
                            iconBg: const Color(0xFFF1F5F9),
                            title: 'Metode Pembayaran',
                            subtitle: 'Kartu, e-wallet terhubung',
                            onTap: () {},
                          ),
                          const SizedBox(height: 10),

                          // Highlighted Langganan Saya Card (Image 2)
                          _buildHighlightedSubscriptionCard(),
                          const SizedBox(height: 16),

                          // SECTION: LAINNYA
                          _buildSectionLabel('LAINNYA'),
                          const SizedBox(height: 8),
                          _buildNotificationSwitchRow(),
                          const Divider(height: 20, color: Color(0xFFF1F5F9)),
                          _buildMenuItemRow(
                            icon: Icons.help_outline_rounded,
                            iconColor: const Color(0xFF64748B),
                            iconBg: const Color(0xFFF1F5F9),
                            title: 'Bantuan',
                            subtitle: 'FAQ & hubungi CS',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const BantuanFaqScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 3. Logout Button (Soft Grey/Red Container with Red Icon & Text)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _handleLogout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF1F5F9),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.logout_rounded,
                                color: Color(0xFFDC2626), size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Keluar',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFDC2626),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 4. App Version Text
                    Text(
                      'Versi Aplikasi 2.1.0',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Soft mint green aura glow
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFDCFCE7).withValues(alpha: 0.6),
              ),
            ),
            // Avatar Image
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=200&auto=format&fit=crop',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFDCFCE7),
                  child: const Icon(Icons.person,
                      color: AppColors.primaryGreen, size: 40),
                ),
              ),
            ),
            // Green Edit Pencil Button
            Positioned(
              bottom: 4,
              right: 8,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.edit_rounded,
                    color: Colors.white, size: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Name with Green Verified Icon
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Nadia Salsabila',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.check_circle_rounded,
                color: Color(0xFF16A34A), size: 18),
          ],
        ),
        const SizedBox(height: 3),

        // Email Subtitle
        Text(
          'nadia.salsabila@email.com',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF94A3B8),
        letterSpacing: 0.6,
      ),
    );
  }

  Widget _buildMenuItemRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 19),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFF94A3B8), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightedSubscriptionCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LanggananSayaScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF166534),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.verified_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Langganan Saya',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF166534),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'AKTIF',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Paket Sehat 30 Hari',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF16A34A),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFF166534), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSwitchRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.notifications_none_rounded,
                color: Color(0xFF64748B), size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifikasi',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Promo & update pesanan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _notificationsEnabled,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFF16A34A),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFE2E8F0),
            onChanged: (val) {
              setState(() {
                _notificationsEnabled = val;
              });
            },
          ),
        ],
      ),
    );
  }
}
