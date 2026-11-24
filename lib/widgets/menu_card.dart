import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/menu_controller.dart';
import '../core/constants/app_colors.dart';
import 'nutri_meal_image.dart';

class MenuCard extends StatelessWidget {
  final MenuItem item;
  final VoidCallback? onTap;

  const MenuCard({super.key, required this.item, this.onTap});

  String _formatPrice(int price) {
    // Format number to Indonesian Rupiah representation: Rp30.000
    final buffer = StringBuffer();
    final str = price.toString();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }
    return 'Rp${buffer.toString().split('').reversed.join('')}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food Image
            AspectRatio(
              aspectRatio: 1.35,
              child: NutriMealImage(
                imageUrl: item.imageUrl,
                fit: BoxFit.cover,
                fallbackIcon: Icons.lunch_dining_rounded,
              ),
            ),

            // Card Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),

                    // Calories Row
                    Row(
                      children: [
                        const Icon(
                          Icons.energy_savings_leaf_rounded,
                          size: 13,
                          color: AppColors.primaryGreen,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${item.calories} kcal',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Price
                    Text(
                      _formatPrice(item.price),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryGreenHover,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
