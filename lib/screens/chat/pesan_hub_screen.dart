import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/main_top_bar.dart';
import '../admin_chat_screen.dart';

class PesanHubScreen extends StatefulWidget {
  final VoidCallback? onCartTap;
  final VoidCallback? onNotificationTap;

  const PesanHubScreen({super.key, this.onCartTap, this.onNotificationTap});

  @override
  State<PesanHubScreen> createState() => _PesanHubScreenState();
}

class _PesanHubScreenState extends State<PesanHubScreen> {
  void _openAdminChat() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AdminChatScreen(isTab: false)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F7ED),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // ================================================================
            // 1. TOP MINT HEADER (MainTopBar)
            // ================================================================
            SliverToBoxAdapter(
              child: Container(
                color: const Color(0xFFE6F7ED),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand Top Bar
                    MainTopBar(
                      onCartTap: widget.onCartTap,
                      onNotificationTap: widget.onNotificationTap,
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // ================================================================
            // 2. WHITE CONTENT AREA (Channel List)
            // ================================================================
            SliverFillRemaining(
              hasScrollBody: false,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 90),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pusat Bantuan & Konsultasi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Chat Channel: Admin NutriCare (Customer Care & Ahli Gizi)
                    _buildAdminChannelItem(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Channel Item: Admin NutriCare (Tirtuy, S.Gz)
  // ---------------------------------------------------------------------------
  Widget _buildAdminChannelItem() {
    return InkWell(
      onTap: _openAdminChat,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Circular Doctor/Admin Photo Avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/images/app_logo.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFDCFCE7),
                  child: const Icon(
                    Icons.support_agent_rounded,
                    color: Color(0xFF16A34A),
                    size: 28,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Timestamp
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Admin NutriCare (Tirtuy, S.Gz)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '10:21',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),

                  // Subtitle & Unread Badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Siap Kak Andi, catatan sendok ramah lingk...',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 19,
                        height: 19,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '2',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Pill Tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_user_outlined,
                          size: 12.5,
                          color: Color(0xFF16A34A),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Ahli Gizi Resmi NutriMeal',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
