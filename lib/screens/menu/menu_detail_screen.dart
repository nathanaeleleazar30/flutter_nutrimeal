import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/menu_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/center_feedback_toast.dart';
import '../../widgets/nutri_meal_image.dart';
import '../chat/admin_chat_screen.dart';

class MenuDetailScreen extends StatefulWidget {
  final MenuItem item;

  const MenuDetailScreen({super.key, required this.item});

  @override
  State<MenuDetailScreen> createState() => _MenuDetailScreenState();
}

class _MenuDetailScreenState extends State<MenuDetailScreen> {
  int _quantity = 1;

  void _increment() {
    setState(() {
      _quantity++;
    });
  }

  void _decrement() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  void _handleAddToCart() {
    final menuController = context.read<NutriMealMenuController>();
    menuController.addToCart(widget.item, quantity: _quantity);

    // Feedback notifikasi ringkas berwarna putih, agak samar, dan perlahan menghilang
    CenterFeedbackToast.showSuccess(
      context,
      message: '$_quantity x ${widget.item.name} masuk keranjang',
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<NutriMealMenuController>().cartItemCount;

    return Scaffold(
      backgroundColor: const Color(0xFFD6F0D8),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Scrollable Content
            CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                // Top App Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back Button
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 16,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),

                        // Title
                        Text(
                          'Details',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),

                        // Cart Button
                        GestureDetector(
                          onTap: () => Navigator.of(context).pushNamed('/cart'),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 18,
                                  color: AppColors.textDark,
                                ),
                              ),
                              if (cartCount > 0)
                                Positioned(
                                  top: -2,
                                  right: -2,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primaryGreen,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '$cartCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        height: 1.0,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Hero Dish Graphic with 20% OFF badges
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 230,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Dish Container
                        Container(
                          width: 210,
                          height: 210,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: NutriMealImage(
                              imageUrl: widget.item.imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        // Left Badge: "20% OFF"
                        Positioned(
                          left: 20,
                          top: 80,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              '20% OFF',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                        ),

                        // Plate Tag: "20% OFF"
                        Positioned(
                          right: 48,
                          bottom: 24,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              '20% OFF',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // White Bottom Card Container
                SliverToBoxAdapter(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x10000000),
                          blurRadius: 18,
                          offset: Offset(0, -6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(22, 24, 22, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title & Price Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.item.name.toUpperCase(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textDark,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '/Porsi',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                Text(
                                  'Rp. 20.000',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Subtitle Description
                        Text(
                          widget.item.description,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF64748B),
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Nutritional Information Section
                        Text(
                          'Nutritional Information',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 4 Colorful Nutrition Cards Row
                        Row(
                          children: [
                            _buildNutritionCard(
                              title: 'Kalori',
                              value: '${widget.item.nutrition.calories}kcal',
                              bgColor: AppColors.nutCalorieBg,
                              textColor: AppColors.nutCalorieText,
                            ),
                            const SizedBox(width: 8),
                            _buildNutritionCard(
                              title: 'Protein',
                              value: widget.item.nutrition.protein,
                              bgColor: AppColors.nutProteinBg,
                              textColor: AppColors.nutProteinText,
                            ),
                            const SizedBox(width: 8),
                            _buildNutritionCard(
                              title: 'Lemak',
                              value: widget.item.nutrition.fat,
                              bgColor: AppColors.nutFatBg,
                              textColor: AppColors.nutFatText,
                            ),
                            const SizedBox(width: 8),
                            _buildNutritionCard(
                              title: 'Karbohidrat',
                              value: widget.item.nutrition.carbs,
                              bgColor: AppColors.nutCarbBg,
                              textColor: AppColors.nutCarbText,
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),

                        // Description (Tags / Ingredients)
                        Text(
                          'Description',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Tags Wrap
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.item.tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                tag,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 22),

                        // Info Row 1: Jadwal Tersedia
                        _buildInfoRow(
                          icon: Icons.calendar_today_rounded,
                          title: 'Jadwal Tersedia',
                          subtitle: widget.item.schedule,
                        ),
                        const SizedBox(height: 14),

                        // Info Row 2: Waktu Pengiriman
                        _buildInfoRow(
                          icon: Icons.local_shipping_outlined,
                          title: 'Waktu Pengiriman',
                          subtitle: widget.item.deliveryTime,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                // 1. Chat Admin NutriMeal Button (Sebelah kiri jumlah menu)
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AdminChatScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 20,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // 2. Quantity Stepper: — 1 +
                Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: _decrement,
                        icon: const Icon(Icons.remove_rounded, size: 16),
                        color: AppColors.textDark,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 30,
                          minHeight: 30,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          '$_quantity',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _increment,
                        icon: const Icon(Icons.add_rounded, size: 16),
                        color: AppColors.textDark,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 30,
                          minHeight: 30,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Masukkan Keranjang Button (Tanpa logo keranjang & teks utuh tidak terpotong)
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed: _handleAddToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Masukkan Keranjang',
                            maxLines: 1,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionCard({
    required String title,
    required String value,
    required Color bgColor,
    required Color textColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 20, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
