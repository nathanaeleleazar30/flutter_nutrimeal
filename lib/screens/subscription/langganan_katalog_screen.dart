import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../checkout_screen.dart';

class LanggananKatalogScreen extends StatefulWidget {
  final bool showBottomNav;

  const LanggananKatalogScreen({
    super.key,
    this.showBottomNav = true,
  });

  @override
  State<LanggananKatalogScreen> createState() => _LanggananKatalogScreenState();
}

class _LanggananKatalogScreenState extends State<LanggananKatalogScreen> {
  int _selectedTierIndex = 1; // Default: Paket Bulanan Lengkap (Paling Populer)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Top App Bar with soft mint background matching Image 5
            _buildHeader(context),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Hero Banner
                    _buildHeroBanner(),
                    const SizedBox(height: 20),

                    // 2. Section: Pilih Paket Langganan
                    Text(
                      'Pilih Paket Langganan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pilihan hemat & fleksibel sesuai gaya hidup Anda',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Tier 1: Paket Mingguan
                    _buildTierCard(
                      index: 0,
                      title: 'Paket Mingguan',
                      badge: 'Trial',
                      badgeColor: const Color(0xFFDCFCE7),
                      badgeTextColor: const Color(0xFF166534),
                      subtitle: '7 Hari • 14x makan (Siang & Malam)',
                      price: 'Rp175.000',
                      period: '/ 7 hr',
                      perMeal: 'Rp12.500/makan',
                      isSelected: _selectedTierIndex == 0,
                    ),
                    const SizedBox(height: 14),

                    // Tier 2: Paket Bulanan Lengkap (Paling Populer)
                    _buildPopularTierCard(),
                    const SizedBox(height: 14),

                    // Tier 3: Paket Hemat Siang
                    _buildTierCard(
                      index: 2,
                      title: 'Paket Hemat Siang',
                      badge: 'Khusus Kantor',
                      badgeColor: const Color(0xFFF1F5F9),
                      badgeTextColor: const Color(0xFF475569),
                      subtitle: '30 Hari • 30x makan (1x makan siang/hari)',
                      price: 'Rp400.000',
                      period: '/ bln',
                      perMeal: 'Rp13.300/makan siang',
                      isSelected: _selectedTierIndex == 2,
                    ),
                    const SizedBox(height: 24),

                    // 3. Section: Contoh Menu Mingguan
                    _buildWeeklyMenuSection(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom Sticky Bar (Image 5 bottom)
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFC3E7C4),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 15,
                color: AppColors.textDark,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Langganan',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
          ),
          const SizedBox(width: 36),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F5132), Color(0xFF064E3B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F5132).withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(color: Color(0xFF4ADE80), shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Katering Sehat Harian',
                        style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Lebih Praktis dengan\nLangganan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Nikmati makanan sehat setiap hari tanpa perlu pesan berulang.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Bento graphic illustration container
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(width: 32, height: 32, decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(6))),
                    const SizedBox(width: 6),
                    Expanded(child: Container(height: 32, decoration: BoxDecoration(color: const Color(0xFFFED7AA), borderRadius: BorderRadius.circular(6)))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(width: 18, height: 18, decoration: const BoxDecoration(color: Color(0xFF16A34A), shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Container(width: 18, height: 18, decoration: const BoxDecoration(color: Color(0xFF34D399), shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Container(width: 18, height: 18, decoration: const BoxDecoration(color: Color(0xFF6EE7B7), shape: BoxShape.circle)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierCard({
    required int index,
    required String title,
    required String badge,
    required Color badgeColor,
    required Color badgeTextColor,
    required String subtitle,
    required String price,
    required String period,
    required String perMeal,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _selectedTierIndex = index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F8A50) : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF0F8A50).withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: isSelected ? 10 : 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    badge,
                    style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: badgeTextColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            Text(
              'TOTAL HARGA',
              style: GoogleFonts.plusJakartaSans(fontSize: 9.5, fontWeight: FontWeight.w700, color: const Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: price,
                              style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textDark),
                            ),
                            TextSpan(
                              text: ' $period',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        perMeal,
                        style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF0F8A50)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 36,
                  child: isSelected
                      ? ElevatedButton.icon(
                          onPressed: () {
                            setState(() => _selectedTierIndex = index);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F8A50),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                          label: Text(
                            'Terpilih',
                            style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                        )
                      : OutlinedButton(
                          onPressed: () {
                            setState(() => _selectedTierIndex = index);
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF0F8A50)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(
                            'Pilih Paket',
                            style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF0F8A50)),
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularTierCard() {
    final isSelected = _selectedTierIndex == 1;
    return GestureDetector(
      onTap: () => setState(() => _selectedTierIndex = 1),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F8A50) : const Color(0xFFCBD5E1),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F8A50).withValues(alpha: isSelected ? 0.10 : 0.03),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header: ★ PALING POPULER
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: const BoxDecoration(
                  color: Color(0xFF0F5132),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.white, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      'PALING POPULER',
                      style: GoogleFonts.plusJakartaSans(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Paket Bulanan Lengkap',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFFFFE4E6), borderRadius: BorderRadius.circular(6)),
                        child: Text(
                          'Hemat 25%',
                          style: GoogleFonts.plusJakartaSans(fontSize: 9.5, fontWeight: FontWeight.w800, color: const Color(0xFFE11D48)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '30 Hari • 60x makan (Siang & Malam)',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 10),

                  // Benefits box: Safe against horizontal overflow
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Color(0xFF0F8A50), size: 14),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  'Gratis Ongkir Sepuasnya',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.5,
                                    color: const Color(0xFF0F8A50),
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 12,
                          width: 1,
                          color: const Color(0xFFCBD5E1),
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Color(0xFF0F8A50), size: 14),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  'Bisa Jeda / Reschedule',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.5,
                                    color: const Color(0xFF0F8A50),
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Price Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Rp1.000.000',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF94A3B8), decoration: TextDecoration.lineThrough),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(4)),
                                  child: Text('-25%', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w800, color: const Color(0xFF166534))),
                                ),
                              ],
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Rp750.000',
                                    style: GoogleFonts.plusJakartaSans(fontSize: 16.5, fontWeight: FontWeight.w900, color: const Color(0xFF0F8A50)),
                                  ),
                                  TextSpan(
                                    text: ' / bln',
                                    style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 38,
                        child: isSelected
                            ? ElevatedButton.icon(
                                onPressed: () {
                                  setState(() => _selectedTierIndex = 1);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0F8A50),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                                label: Text(
                                  'Terpilih',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                                ),
                              )
                            : OutlinedButton(
                                onPressed: () {
                                  setState(() => _selectedTierIndex = 1);
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF0F8A50)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: Text(
                                  'Pilih Paket',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF0F8A50)),
                                ),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Contoh Menu Mingguan',
              style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/menu'),
              child: Text(
                'Lihat Semua',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF0F8A50)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'Dirancang gizi seimbang oleh Tim Nutisionis',
          style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF64748B)),
        ),
        const SizedBox(height: 12),

        // 2 Sample Menu Cards
        Row(
          children: [
            Expanded(
              child: _buildMenuThumbnailCard(
                dayBadge: 'Senin',
                tag: 'TINGGI PROTEIN',
                tagColor: const Color(0xFF0F8A50),
                title: 'Nasi Ayam Teriyaki',
                subtitle: 'Ayam fillet, wortel, brokoli &...',
                calories: '450 kkal',
                protein: '38g Protein',
                imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=400&auto=format&fit=crop',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMenuThumbnailCard(
                dayBadge: 'Selasa',
                tag: 'RENDAH KARBO',
                tagColor: const Color(0xFF2563EB),
                title: 'Chicken Katsu Salad',
                subtitle: 'Katsu panggang tanpa minyak',
                calories: '420 kkal',
                protein: '34g Protein',
                imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?q=80&w=400&auto=format&fit=crop',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuThumbnailCard({
    required String dayBadge,
    required String tag,
    required Color tagColor,
    required String title,
    required String subtitle,
    required String calories,
    required String protein,
    required String imageUrl,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.network(
                imageUrl,
                height: 96,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(height: 96, color: const Color(0xFFDCFCE7)),
              ),
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    dayBadge,
                    style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tag,
                  style: GoogleFonts.plusJakartaSans(fontSize: 8.5, fontWeight: FontWeight.w800, color: tagColor),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textDark),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF64748B)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(calories, style: GoogleFonts.plusJakartaSans(fontSize: 9.5, color: const Color(0xFF64748B), fontWeight: FontWeight.w600)),
                    Text(protein, style: GoogleFonts.plusJakartaSans(fontSize: 9.5, color: const Color(0xFF0F8A50), fontWeight: FontWeight.w800)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mulai dari',
                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF64748B)),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Rp25.000',
                      style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.textDark),
                    ),
                    TextSpan(
                      text: '/hari',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 46,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F8A50),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: Row(
                children: [
                  Text(
                    'Mulai Langganan',
                    style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
