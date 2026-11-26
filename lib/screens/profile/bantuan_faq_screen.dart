import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../services/api_service.dart';
import '../admin_chat_screen.dart';
import '../nutribot_chat_screen.dart';

class BantuanFaqScreen extends StatefulWidget {
  final bool showHeaderWithLogo;

  const BantuanFaqScreen({super.key, this.showHeaderWithLogo = true});

  @override
  State<BantuanFaqScreen> createState() => _BantuanFaqScreenState();
}

class _BantuanFaqScreenState extends State<BantuanFaqScreen> {
  int? _expandedIndex;
  int _selectedFilterIndex = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _faqs = [];

  final List<String> _filterCategories = [
    'Semua',
    'Pengantaran',
    'Menu & Diet',
    'Jadwal & Langganan',
    'Pembayaran',
  ];

  @override
  void initState() {
    super.initState();
    _loadFaqs();
  }

  Future<void> _loadFaqs() async {
    setState(() => _isLoading = true);
    try {
      final list = await ApiService.instance.fetchFaqs();
      if (mounted) {
        setState(() {
          _faqs = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Map<String, dynamic>> get _filteredFaqs {
    if (_selectedFilterIndex == 0) return _faqs;
    final cat = _filterCategories[_selectedFilterIndex].toLowerCase();
    return _faqs.where((f) {
      final itemCat = (f['category'] ?? '').toString().toLowerCase();
      final q = (f['question'] ?? '').toString().toLowerCase();
      if (itemCat.contains(cat) || q.contains(cat)) return true;
      // Samakan kategori dari Admin Web ('Pengiriman', 'Menu', 'Langganan', 'Pembayaran')
      switch (_selectedFilterIndex) {
        case 1: // Pengantaran
          return itemCat.contains('pengiriman') || itemCat.contains('antar');
        case 2: // Menu & Diet
          return itemCat.contains('menu') || itemCat.contains('diet');
        case 3: // Jadwal & Langganan
          return itemCat.contains('langganan') || itemCat.contains('jadwal');
        case 4: // Pembayaran
          return itemCat.contains('pembayaran') || itemCat.contains('bayar');
        default:
          return false;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredFaqs;

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
              child: RefreshIndicator(
                onRefresh: _loadFaqs,
                color: AppColors.primaryGreen,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Hero Card: Bantuan NutriCare 24/7
                      _buildHeroBanner(),
                      const SizedBox(height: 14),

                      // 2. Filter Chips
                      _buildFilterChips(),
                      const SizedBox(height: 18),

                      // 4. Saluran Bantuan Cepat
                      _buildQuickSupportSection(context),
                      const SizedBox(height: 20),

                      // 5. Pertanyaan Sering Diajukan
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 30),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        )
                      else if (filtered.isEmpty)
                        _buildEmptyFaqState()
                      else
                        _buildFaqAccordionSection(filtered),
                      const SizedBox(height: 20),

                      // 6. Bottom WhatsApp Card
                      _buildBottomWhatsAppCard(context),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFaqState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.help_outline_rounded,
            size: 36,
            color: Color(0xFF94A3B8),
          ),
          const SizedBox(height: 8),
          Text(
            'Belum ada pertanyaan FAQ untuk kategori ini.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
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
      decoration: const BoxDecoration(color: Color(0xFFC3E7C4)),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
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
                        decoration: const BoxDecoration(
                          color: Color(0xFF4ADE80),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Bantuan NutriCare 24/7',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
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
                child: const Icon(
                  Icons.smart_toy_rounded,
                  color: Color(0xFF0F8A50),
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_filterCategories.length, (index) {
          final c = _filterCategories[index];
          final isSelected = _selectedFilterIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilterIndex = index;
                _expandedIndex = null;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0F5132) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF0F5132)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Text(
                c,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ),
          );
        }),
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
                    MaterialPageRoute(
                      builder: (_) => const NutriBotChatScreen(),
                    ),
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
                        child: const Icon(
                          Icons.smart_toy_outlined,
                          color: Color(0xFF0F8A50),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Live NutriBot AI',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              'Chat otomatis 24 jam',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                color: const Color(0xFF64748B),
                              ),
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
                        child: const Icon(
                          Icons.support_agent_rounded,
                          color: Color(0xFF0F8A50),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Admin CS',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              'Respon rata-rata < 5 mnt',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                color: const Color(0xFF64748B),
                              ),
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

  Widget _buildFaqAccordionSection(List<Map<String, dynamic>> faqs) {
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
              '${faqs.length} Pertanyaan',
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
            child: Material(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  initiallyExpanded: isExpanded,
                  onExpansionChanged: (val) {
                    setState(() => _expandedIndex = val ? index : null);
                  },
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 2,
                  ),
                  title: Text(
                    item['question']?.toString() ?? '',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                      height: 1.3,
                    ),
                  ),
                  trailing: Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF0F8A50),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                      child: Text(
                        item['answer']?.toString() ?? '',
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
                child: const Icon(
                  Icons.chat_rounded,
                  color: Color(0xFF0F8A50),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Masih butuh bantuan lain?\nTim NutriMeal CS selalu siap membantu jam 07.00 - 22.00 WIB',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                    height: 1.3,
                  ),
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
              icon: const Icon(
                Icons.headset_mic_rounded,
                color: Colors.white,
                size: 16,
              ),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
