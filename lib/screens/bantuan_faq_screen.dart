import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import 'admin_chat_screen.dart';
import 'nutribot_chat_screen.dart';

class BantuanFaqScreen extends StatefulWidget {
  final bool showHeaderWithLogo;

  const BantuanFaqScreen({
    super.key,
    this.showHeaderWithLogo = true,
  });

  @override
  State<BantuanFaqScreen> createState() => _BantuanFaqScreenState();
}

class _BantuanFaqScreenState extends State<BantuanFaqScreen> {
  final TextEditingController _searchController = TextEditingController();
  int? _expandedIndex;

  final List<Map<String, String>> _faqs = [
    {
      'question': 'Bagaimana cara mengubah alamat pengantaran katering aktif?',
      'answer':
          'Anda dapat mengubah alamat pengantaran melalui menu Alamat Pengiriman atau tab Jadwal. Pastikan konfirmasi perubahan dilakukan maksimal pukul 20.00 WIB sebelum hari pengiriman berikutnya agar kurir katering dapat mengantarkan ke alamat baru dengan tepat.',
    },
    {
      'question': 'Apakah menu katering diet NutriMeal disesuaikan alergi pelanggan?',
      'answer':
          'Tentu! Di menu Informasi Pribadi, Anda dapat mencantumkan catatan alergi atau preferensi diet (seperti gluten-free, no seafood, rendah natrium). Tim nutisionis kami akan menyesuaikan sajian Anda secara aman.',
    },
    {
      'question': 'Kapan batas waktu konfirmasi cuti / reschedule jadwal katering?',
      'answer':
          'Pengajuan cuti atau reschedule jadwal katering dapat dilakukan melalui tab Jadwal paling lambat H-1 pukul 20.00 WIB. Porsi makan Anda akan otomatis tersimpan dan diperpanjang di akhir periode langganan.',
    },
    {
      'question': 'Metode pembayaran apa saja yang aktif di NutriMeal?',
      'answer':
          'NutriMeal mendukung QRIS Instant Pay (semua e-wallet dan mobile banking seperti GoPay, DANA, ShopeePay, BCA Mobile, Livin\' by Mandiri) serta COD (Bayar di Tempat) untuk area tertentu.',
    },
    {
      'question': 'Bagaimana cara refund jika ada kendala pesanan katering?',
      'answer':
          'Jika terjadi kendala kualitas makanan atau keterlambatan kurir lebih dari 30 menit, silakan hubungi Admin NutriCare via WhatsApp atau live chat dengan melampirkan foto makanan. Kami memberikan garansi penggantian porsi atau refund 100%.',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = _faqs.where((faq) {
      return query.isEmpty ||
          faq['question']!.toLowerCase().contains(query) ||
          faq['answer']!.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Top App Bar with pale mint background
            _buildHeader(context),

            // Content Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Hero Card: Bantuan NutriCare 24/7
                    _buildHeroBanner(),
                    const SizedBox(height: 14),

                    // 2. Search Bar
                    _buildSearchBar(),
                    const SizedBox(height: 10),

                    // 3. Filter Chips
                    _buildFilterChips(),
                    const SizedBox(height: 18),

                    // 4. Saluran Bantuan Cepat
                    _buildQuickSupportSection(context),
                    const SizedBox(height: 20),

                    // 5. Pertanyaan Sering Diajukan
                    _buildFaqAccordionSection(filtered),
                    const SizedBox(height: 20),

                    // 6. Bottom WhatsApp Card
                    _buildBottomWhatsAppCard(context),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
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
              'Bantuan',
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
                        'Bantuan NutriCare 24/7',
                        style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ada yang bisa kami bantu seputar menu, sehat & pesananmu?',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tim ahli gizi & CS berdedikasi melayani solusi katering sehatmu.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // NutriBot mascot avatar
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/nutribot_avatar.png',
              width: 60,
              height: 60,
              errorBuilder: (_, _, _) => Container(
                width: 60,
                height: 60,
                color: const Color(0xFFDCFCE7),
                child: const Icon(Icons.smart_toy_rounded, color: Color(0xFF0F8A50), size: 32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textDark),
              decoration: InputDecoration(
                hintText: 'Cari bantuan, pesanan, akun, diet...',
                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF94A3B8)),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final chips = ['Jadwal', 'Penggantian Menu', 'Pengiriman Katering'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: chips.map((c) {
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              c,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuickSupportSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Saluran Bantuan Cepat',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // Card 1: Live NutriBot AI
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NutriBotChatScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
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
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFFDCFCE7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.smart_toy_outlined, color: Color(0xFF0F8A50), size: 20),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Live NutriBot AI',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textDark),
                            ),
                            Text(
                              'Chat otomatis 24 jam',
                              style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Card 2: Admin CS
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminChatScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
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
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFFDCFCE7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.support_agent_rounded, color: Color(0xFF0F8A50), size: 20),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Admin CS',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textDark),
                            ),
                            Text(
                              'Respon rata-rata < 5 mnt',
                              style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFaqAccordionSection(List<Map<String, String>> faqs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pertanyaan Sering Diajukan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            Text(
              'Lihat Semua',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F8A50),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Accordion List
        ...List.generate(faqs.length, (index) {
          final item = faqs[index];
          final isExpanded = _expandedIndex == index;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: isExpanded,
                onExpansionChanged: (val) {
                  setState(() => _expandedIndex = val ? index : null);
                },
                tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                title: Text(
                  item['question']!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                    height: 1.3,
                  ),
                ),
                trailing: Icon(
                  isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: const Color(0xFF0F8A50),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                    child: Text(
                      item['answer']!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: const Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBottomWhatsAppCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.chat_rounded, color: Color(0xFF0F8A50), size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Masih butuh bantuan lain?\nTim NutriMeal CS selalu siap membantu jam 07.00 - 22.00 WIB',
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF64748B), height: 1.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminChatScreen()),
                );
              },
              icon: const Icon(Icons.headset_mic_rounded, color: Colors.white, size: 16),
              label: Text(
                'Hubungi CS via WhatsApp',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F8A50),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
