import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/menu_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/main_top_bar.dart';
import '../../widgets/menu_card.dart';
import '../../widgets/nutri_meal_image.dart';
import '../menu_detail_screen.dart';

class BerandaScreen extends StatefulWidget {
  final VoidCallback? onNavigateToGallery;
  final VoidCallback? onNavigateToSchedule;
  final VoidCallback? onNavigateToChat;

  const BerandaScreen({
    super.key,
    this.onNavigateToGallery,
    this.onNavigateToSchedule,
    this.onNavigateToChat,
  });

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  Future<void> _handleRefresh() async {
    final menuController = context.read<NutriMealMenuController>();
    await menuController.fetchMenusFromApi();
  }

  @override
  Widget build(BuildContext context) {
    final menuController = context.watch<NutriMealMenuController>();
    final popularItems = menuController.popularMenuItems;

    return Scaffold(
      backgroundColor: const Color(0xFFE6F7ED),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: const Color(0xFF15803D),
          backgroundColor: Colors.white,
          displacement: 60,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // ================================================================
              // 1. TOP MINT SECTION (Brand Top Bar, Search, Categories, NutriBot)
              // ================================================================
              SliverToBoxAdapter(
                child: Container(
                  color: const Color(0xFFE6F7ED),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Brand Top Bar (NutriMeal logo, Notification bell, Cart, Avatar)
                      const MainTopBar(),
                      const SizedBox(height: 6),

                      // Search Bar (White Pill with Search)
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
                                  onChanged: (val) =>
                                      menuController.setSearchQuery(val),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    color: AppColors.textDark,
                                  ),
                                  decoration: InputDecoration(
                                    hintText:
                                        'Cari menu sehat, kalori, atau diet...',
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
                              const SizedBox(width: 14),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Food Categories Row (Ikan, Ayam, Daging, Seafood, Roti)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildCategoryItem(
                              context,
                              title: 'Ikan',
                              imageUrl:
                                  'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?q=80&w=300&auto=format&fit=crop',
                              fallbackEmoji: '🐟',
                            ),
                            _buildCategoryItem(
                              context,
                              title: 'Ayam',
                              imageUrl:
                                  'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?q=80&w=300&auto=format&fit=crop',
                              fallbackEmoji: '🍗',
                            ),
                            _buildCategoryItem(
                              context,
                              title: 'Daging',
                              imageUrl:
                                  'https://images.unsplash.com/photo-1544025162-d76694265947?q=80&w=300&auto=format&fit=crop',
                              fallbackEmoji: '🥩',
                            ),
                            _buildCategoryItem(
                              context,
                              title: 'Seafood',
                              imageUrl:
                                  'https://images.unsplash.com/photo-1565680018434-b513d5e5fd47?q=80&w=300&auto=format&fit=crop',
                              fallbackEmoji: '🦐',
                            ),
                            _buildCategoryItem(
                              context,
                              title: 'Roti',
                              imageUrl:
                                  'https://images.unsplash.com/photo-1525351484163-7529414344d8?q=80&w=300&auto=format&fit=crop',
                              fallbackEmoji: '🥖',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Subscription Banner Card (Langganan Katering Sehat)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pushNamed('/langganan-katalog'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF064E3B),
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF064E3B).withValues(alpha: 0.25),
                                  blurRadius: 12,
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
                                      // Flash / Discount Pill Tag
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3.5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF14532D),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.bolt_rounded,
                                              size: 13,
                                              color: Color(0xFFFBBF24),
                                            ),
                                            const SizedBox(width: 3),
                                            Text(
                                              'HEMAT S.D 25%',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.w800,
                                                color: const Color(0xFFFDE68A),
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),

                                      // Main Title
                                      Text(
                                        'Langganan Katering Sehat',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),

                                      // Price subtitle
                                      RichText(
                                        text: TextSpan(
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10.5,
                                            color: const Color(0xFF94A3B8),
                                          ),
                                          children: [
                                            const TextSpan(text: 'Mulai '),
                                            TextSpan(
                                              text: 'Rp28.000',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontWeight: FontWeight.w800,
                                                color: const Color(0xFFFBBF24),
                                              ),
                                            ),
                                            const TextSpan(text: ' /porsi · Bebas Pilih\nPaket'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Yellow Action Pill Button
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 9,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF59E0B),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Langganan',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF1E293B),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 14,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ),

              // ================================================================
              // 2. LOWER WHITE SECTION (Jadwal Katering & Menu Populer Hari Ini)
              // ================================================================
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Jadwal Katering Header (Title & 'Semua' CTA)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Jadwal Katering',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                          GestureDetector(
                            onTap:
                                widget.onNavigateToSchedule ??
                                () =>
                                    Navigator.of(context).pushNamed('/jadwal'),
                            child: Text(
                              'Semua',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF16A34A),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 5-Day Selector Bar (Segmented Light Capsule Container)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: List.generate(
                            menuController.cateringDays.length,
                            (index) {
                              final item = menuController.cateringDays[index];
                              final isSelected =
                                  menuController.selectedCateringDayIndex ==
                                  index;

                              return Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      menuController.selectCateringDay(index),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFF16A34A)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: const Color(
                                                  0xFF16A34A,
                                                ).withValues(alpha: 0.25),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          item.dayShort,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            color: isSelected
                                                ? Colors.white
                                                : const Color(0xFF64748B),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          index == 0
                                              ? 'Hari ini'
                                              : item.subtitle,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 9.5,
                                            fontWeight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? Colors.white
                                                : const Color(0xFF94A3B8),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Container(
                                          width: 4,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? Colors.white
                                                : const Color(0xFFCBD5E1),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Active Catering Delivery Card (Chicken Katsu Bowl 12:00 WIB)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.025),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Food Image Thumbnail
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: const SizedBox(
                                width: 58,
                                height: 58,
                                child: NutriMealImage(
                                  imageUrl:
                                      'https://images.unsplash.com/photo-1543339308-43e59d6b73a6?q=80&w=300&auto=format&fit=crop',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Title & Time (Chicken Katsu Bowl, 12:00 WIB)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Chicken Katsu Bowl',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textDark,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '12:00 WIB',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Popular Items Grid (2 Columns, 4 Items Matching Screenshot)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 0.76,
                            ),
                        itemCount: popularItems.length,
                        itemBuilder: (context, index) {
                          final item = popularItems[index];
                          return MenuCard(
                            item: item,
                            onTap: () {
                              menuController.selectMenuItem(item);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MenuDetailScreen(item: item),
                                ),
                              );
                            },
                          );
                        },
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

  Widget _buildCategoryItem(
    BuildContext context, {
    required String title,
    required String imageUrl,
    required String fallbackEmoji,
  }) {
    return GestureDetector(
      onTap: () {
        context.read<NutriMealMenuController>().selectCategory(title);
        if (widget.onNavigateToGallery != null) {
          widget.onNavigateToGallery!();
        }
      },
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: NutriMealImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              fallbackIcon: Icons.restaurant_rounded,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
