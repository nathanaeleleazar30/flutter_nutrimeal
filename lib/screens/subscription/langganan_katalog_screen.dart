import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/menu_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../services/api_service.dart';
import '../checkout_screen.dart';

class LanggananKatalogScreen extends StatefulWidget {
  final bool showBottomNav;

  const LanggananKatalogScreen({super.key, this.showBottomNav = true});

  @override
  State<LanggananKatalogScreen> createState() => _LanggananKatalogScreenState();
}

class _LanggananKatalogScreenState extends State<LanggananKatalogScreen> {
  int _selectedTierIndex = 1; // Default to popular tier (Paket Bulanan Lengkap)
  bool _isLoading = true;
  List<Map<String, dynamic>> _packages = [];

  // Default fallback packages jika network/DB sedang offline
  final List<Map<String, dynamic>> _defaultPackages = [
    {
      'id': 'pkg-1',
      'name': 'Paket Sehat Diet Mingguan',
      'type': 'Mingguan',
      'description': '10 Box (Makan Siang & Malam)',
      'price': 350000,
      'original_price': 400000,
      'portions': '10 Porsi',
      'badge': 'Mingguan',
      'is_popular': false,
    },
    {
      'id': 'pkg-popular',
      'name': 'Paket Bulanan Lengkap',
      'type': 'Bulanan',
      'description': '30 Hari • 60x makan (Siang & Malam)',
      'price': 750000,
      'original_price': 1000000,
      'discount_percent': '25%',
      'portions': '60 Box Porsi Penuh',
      'badge': 'Hemat 25%',
      'is_popular': true,
    },
    {
      'id': 'pkg-2',
      'name': 'Paket Makan Siang Kantor',
      'type': 'Bulanan',
      'description': '20 Box (Khusus Makan Siang Hari Kerja)',
      'price': 525000,
      'original_price': 600000,
      'portions': '20 Box',
      'badge': 'Bulanan',
      'is_popular': false,
    },
    {
      'id': 'pkg-3',
      'name': 'Paket Family Sehat 5 Hari',
      'type': 'Mingguan',
      'description': '20 Porsi Keluarga (Lauk Pauk & Sayur Lengkap)',
      'price': 680000,
      'original_price': 750000,
      'portions': '20 Porsi Keluarga',
      'badge': 'Keluarga',
      'is_popular': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    setState(() => _isLoading = true);
    try {
      final list = await ApiService.instance.fetchPackages();
      if (mounted) {
        setState(() {
          if (list.isNotEmpty) {
            _packages = list;
          } else {
            _packages = _defaultPackages;
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _packages = _defaultPackages;
          _isLoading = false;
        });
      }
    }
  }

  String _formatRupiah(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return 'Rp$buffer';
  }

  List<Map<String, dynamic>> get _currentPackages =>
      _packages.isNotEmpty ? _packages : _defaultPackages;

  @override
  Widget build(BuildContext context) {
    final packagesList = _currentPackages;
    final safeSelectedIndex =
        (_selectedTierIndex >= 0 && _selectedTierIndex < packagesList.length)
        ? _selectedTierIndex
        : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Top App Bar with soft mint background
            _buildHeader(context),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
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

                    // Dynamic Packages Cards
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      )
                    else
                      ...List.generate(packagesList.length, (index) {
                        final pkg = packagesList[index];
                        final isSel = safeSelectedIndex == index;
                        final priceInt =
                            int.tryParse('${pkg['price']}') ?? 350000;
                        final originalPriceInt = int.tryParse(
                          '${pkg['original_price']}',
                        );
                        final formattedPrice = _formatRupiah(priceInt);
                        final formattedOriginalPrice = originalPriceInt != null
                            ? _formatRupiah(originalPriceInt)
                            : null;
                        final typeStr = pkg['type']?.toString() ?? 'Mingguan';
                        final portions = pkg['portions']?.toString() ?? '';
                        final desc = pkg['description']?.toString() ?? '';
                        final isPopular =
                            pkg['is_popular'] == true ||
                            pkg['id'] == 'pkg-popular' ||
                            (pkg['percentage'] != null &&
                                _parseNumber(pkg['percentage']) >= 25);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _buildTierCard(
                            index: index,
                            title: pkg['name']?.toString() ?? 'Paket Katering',
                            badge: pkg['badge']?.toString() ?? typeStr,
                            subtitle: portions.isNotEmpty
                                ? '$portions • $desc'
                                : desc,
                            price: formattedPrice,
                            originalPrice: formattedOriginalPrice,
                            discountPercent:
                                pkg['discount_percent']?.toString() ??
                                (pkg['percentage'] != null
                                    ? '${pkg['percentage']}%'
                                    : null),
                            period: '/ $typeStr',
                            perMeal: portions.isNotEmpty
                                ? portions
                                : 'Porsi Lengkap',
                            isSelected: isSel,
                            isPopular: isPopular,
                          ),
                        );
                      }),
                    const SizedBox(height: 14),

                    // 3. Section: Contoh Menu Mingguan
                    _buildWeeklyMenuSection(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom Sticky Bar (Aman dari overflow & support notch)
            _buildBottomBar(context, packagesList, safeSelectedIndex),
          ],
        ),
      ),
    );
  }

  int _parseNumber(dynamic val) {
    if (val == null) return 0;
    return int.tryParse(val.toString()) ?? 0;
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
            onTap: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/home', (route) => false);
              }
            },
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
              'Langganan Katering',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16.5,
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
                    vertical: 3.5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4ADE80),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Katering Sehat Harian',
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
                  'Lebih Praktis dengan\nLangganan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16.5,
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
          // Clean Food Thumbnail Graphic (No placeholder shapes)
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=400&auto=format&fit=crop',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFFDCFCE7),
                    child: const Icon(
                      Icons.lunch_dining_rounded,
                      color: Color(0xFF0F8A50),
                      size: 36,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 2.5),
                    color: const Color(0xFF0F5132).withValues(alpha: 0.88),
                    child: Text(
                      '100% FRESH',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFFDE68A),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
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
    required String subtitle,
    required String price,
    String? originalPrice,
    String? discountPercent,
    required String period,
    required String perMeal,
    required bool isSelected,
    bool isPopular = false,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _selectedTierIndex = index),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0F8A50)
                : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF0F8A50).withValues(alpha: 0.09)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: isSelected ? 10 : 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Star Banner if Popular
            if (isPopular)
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F5132),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFBBF24),
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'PALING POPULER',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            Padding(
              padding: EdgeInsets.fromLTRB(16, isPopular ? 4 : 14, 16, 14),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFDCFCE7)
                              : (discountPercent != null
                                    ? const Color(0xFFFFE4E6)
                                    : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          discountPercent != null
                              ? 'Hemat $discountPercent'
                              : badge,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? const Color(0xFF166534)
                                : (discountPercent != null
                                      ? const Color(0xFFE11D48)
                                      : const Color(0xFF475569)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: const Color(0xFF64748B),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Optional Benefits Box for Popular Tier
                  if (isPopular) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
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
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF0F8A50),
                                  size: 13,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    'Gratis Ongkir Sepuasnya',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
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
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF0F8A50),
                                  size: 13,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    'Bisa Jeda Kapan Saja',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
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
                  ],

                  const SizedBox(height: 12),

                  // Price & Action Button Row (Wrapped safely against overflow)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (originalPrice != null)
                              Row(
                                children: [
                                  Text(
                                    originalPrice,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10.5,
                                      color: const Color(0xFF94A3B8),
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  if (discountPercent != null) ...[
                                    const SizedBox(width: 5),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFDCFCE7),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '-$discountPercent',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF166534),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: price,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: isSelected
                                          ? const Color(0xFF0F8A50)
                                          : AppColors.textDark,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' $period',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              perMeal,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F8A50),
                              ),
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
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                label: Text(
                                  'Terpilih',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : OutlinedButton(
                                onPressed: () {
                                  setState(() => _selectedTierIndex = index);
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFF0F8A50),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                ),
                                child: Text(
                                  'Pilih Paket',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F8A50),
                                  ),
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
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            GestureDetector(
              onTap: () {
                // Pindah ke tab menu
                context.read<NutriMealMenuController>().setBottomNavIndex(1);
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/home', (r) => false);
              },
              child: Text(
                'Lihat Semua',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F8A50),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'Dirancang gizi seimbang oleh Tim Nutisionis',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.5,
            color: const Color(0xFF64748B),
          ),
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
                subtitle: 'Ayam fillet, brokoli & quinoa',
                calories: '450 kkal',
                protein: '38g Protein',
                imageUrl:
                    'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=400&auto=format&fit=crop',
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
                imageUrl:
                    'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?q=80&w=400&auto=format&fit=crop',
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
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 96,
                  color: const Color(0xFFDCFCE7),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.restaurant_rounded,
                    color: Color(0xFF0F8A50),
                    size: 28,
                  ),
                ),
              ),
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    dayBadge,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
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
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: tagColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        calories,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        protein,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5,
                          color: const Color(0xFF0F8A50),
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    List<Map<String, dynamic>> packagesList,
    int selectedIndex,
  ) {
    final selectedPkg = packagesList[selectedIndex];
    final price = int.tryParse('${selectedPkg['price']}') ?? 350000;
    final priceDisplay = _formatRupiah(price);
    final periodDisplay = '/ ${selectedPkg['type'] ?? 'paket'}';

    return Container(
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
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Column Price (Expanded to prevent any RenderFlex overflow)
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Paket',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: priceDisplay,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDark,
                            ),
                          ),
                          TextSpan(
                            text: ' $periodDisplay',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Right Button (Mulai Langganan)
              SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    context
                        .read<NutriMealMenuController>()
                        .setSelectedSubscriptionPackage(selectedPkg);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CheckoutScreen(subscriptionPackage: selectedPkg),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F8A50),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Mulai Langganan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
