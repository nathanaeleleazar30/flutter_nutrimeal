import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../widgets/main_top_bar.dart';
import 'admin_chat_screen.dart';
import 'nutribot_chat_screen.dart';

class PesanHubScreen extends StatefulWidget {
  final VoidCallback? onCartTap;
  final VoidCallback? onNotificationTap;

  const PesanHubScreen({
    super.key,
    this.onCartTap,
    this.onNotificationTap,
  });

  @override
  State<PesanHubScreen> createState() => _PesanHubScreenState();
}

class _PesanHubScreenState extends State<PesanHubScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openNutriBotChat() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const NutriBotChatScreen(isTab: false),
      ),
    );
  }

  void _openAdminChat() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AdminChatScreen(isTab: false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchQuery.toLowerCase();
    final showNutriBot = query.isEmpty ||
        'nutribot ai konsultasi nutrisi kalori'.contains(query);
    final showAdmin = query.isEmpty ||
        'admin nutricare tirtuy ahli gizi customer care'.contains(query);

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
            // 1. TOP MINT HEADER (MainTopBar & Search Pill)
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
                    const SizedBox(height: 6),

                    // Search Pill Input
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 14),
                            const Icon(
                              Icons.search_rounded,
                              color: Color(0xFF94A3B8),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: (val) {
                                  setState(() {
                                    _searchQuery = val.trim();
                                  });
                                },
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  color: AppColors.textDark,
                                ),
                                decoration: InputDecoration(
                                  hintText:
                                      'Cari pesan, topik nutrisi, atau admin...',
                                  hintStyle: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            if (_searchQuery.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                                child: const Padding(
                                  padding: EdgeInsets.only(right: 12),
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              )
                            else
                              const SizedBox(width: 14),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // ================================================================
            // 2. WHITE CONTENT AREA (Channel List & Konsultasi Instan Card)
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
                    // Chat Channel 1: NutriBot AI
                    if (showNutriBot) ...[
                      _buildNutriBotChannelItem(),
                      const SizedBox(height: 12),
                      const Divider(
                        height: 1,
                        thickness: 0.8,
                        color: Color(0xFFF1F5F9),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Chat Channel 2: Admin NutriCare (Tirtuy, S.Gz)
                    if (showAdmin) ...[
                      _buildAdminChannelItem(),
                    ],

                    if (!showNutriBot && !showAdmin)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: Center(
                          child: Text(
                            'Tidak ada percakapan yang cocok',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // KONSULTASI INSTAN Card
                    _buildInstantConsultationCard(),
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
  // Channel Item: NutriBot AI
  // ---------------------------------------------------------------------------
  Widget _buildNutriBotChannelItem() {
    return InkWell(
      onTap: _openNutriBotChat,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Circular Mascot Avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1B6B46).withValues(alpha: 0.20),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/images/nutribot_avatar.png',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title, Verified Checkmark, and Timestamp
                  Row(
                    children: [
                      Text(
                        'NutriBot AI',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF16A34A),
                        size: 15.5,
                      ),
                      const Spacer(),
                      Text(
                        '18:45',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),

                  // Subtitle & Unread Badge
                  Row(
                    children: [
                      Container(
                        width: 6.5,
                        height: 6.5,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Sedang menganalisis kalori menu malam...',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF16A34A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 19,
                        height: 19,
                        decoration: const BoxDecoration(
                          color: Color(0xFF16A34A),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '1',
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.eco_outlined,
                          size: 12.5,
                          color: Color(0xFF16A34A),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Konsultasi Nutrisi & Kalori',
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
                'assets/images/profile_avatar.jpg',
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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

  // ---------------------------------------------------------------------------
  // KONSULTASI INSTAN Card
  // ---------------------------------------------------------------------------
  Widget _buildInstantConsultationCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Label
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4.5),
                decoration: const BoxDecoration(
                  color: Color(0xFF22C55E),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: Colors.white,
                  size: 13,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'KONSULTASI INSTAN',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF15803D),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Title
          Text(
            'Butuh Rekomendasi Menu Hari Ini?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),

          // Subtitle Description
          Text(
            'NutriBot AI siap menghitung makronutrisi dan menyusun porsi ideal sesuai target kebugaran Anda.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              height: 1.45,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),

          // Button 1: Mulai Chat NutriBot AI (Solid Green)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _openNutriBotChat,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF166534),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/images/nutribot_avatar.png',
                      width: 22,
                      height: 22,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Mulai Chat NutriBot AI',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Button 2: Jadwal Konsultasi Dokter (White Outlined Pill)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: _openAdminChat,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.textDark,
                side: const BorderSide(
                  color: Color(0xFFE2E8F0),
                  width: 1.2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.calendar_month_outlined,
                    color: Color(0xFF15803D),
                    size: 19,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Jadwal Konsultasi Dokter',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
