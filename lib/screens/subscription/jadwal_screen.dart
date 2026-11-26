import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/menu_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../data/schedule_data.dart';
import '../../widgets/main_top_bar.dart';

export '../../data/schedule_data.dart';

class JadwalScreen extends StatefulWidget {
  final VoidCallback? onCartTap;
  final VoidCallback? onProfileTap;

  const JadwalScreen({super.key, this.onCartTap, this.onProfileTap});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  int _selectedDayIndex = 0;

  @override
  Widget build(BuildContext context) {
    final menuController = context.watch<NutriMealMenuController>();
    // Sinkron 100% dengan Beranda: 5 hari (Senin s/d Jumat) & tanggal real-time
    final schedules = menuController.cateringSchedules;
    final safeIndex =
        (schedules.isNotEmpty && _selectedDayIndex < schedules.length)
        ? _selectedDayIndex
        : 0;
    final currentSchedule = schedules.isNotEmpty ? schedules[safeIndex] : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            MainTopBar(
              onCartTap: widget.onCartTap,
              onProfileTap: widget.onProfileTap,
            ),

            // Horizontal Calendar Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              height: 74,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: schedules.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final schedule = schedules[index];
                  final isSelected = safeIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedDayIndex = index);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 62,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF0F5132)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFF0F5132,
                                  ).withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            schedule.dayName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white70
                                  : const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${schedule.dayNumber}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Meal Schedule Cards
            Expanded(
              child: currentSchedule == null || currentSchedule.meals.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Belum ada jadwal menu untuk hari ini',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      children: [
                        ...currentSchedule.meals.map(
                          (meal) =>
                              _buildMealCard(meal, menuController.allMeals),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCard(ScheduledMeal meal, List<MenuItem> allMeals) {
    final isLunch = meal.slotType == 'Makan Siang';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food Image with Slot Badge
          Stack(
            children: [
              SizedBox(
                height: 170,
                width: double.infinity,
                child: Image.network(
                  meal.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFFDCFCE7),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.restaurant_rounded,
                      size: 48,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isLunch
                        ? const Color(0xFF059669)
                        : const Color(0xFF4F46E5),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isLunch
                            ? Icons.wb_sunny_rounded
                            : Icons.nightlight_round,
                        color: Colors.white,
                        size: 13,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        meal.slotType,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Card Content
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),

                // Tags Wrap (aman dari RenderFlex overflow)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: meal.tags.map((tag) {
                    final isCalorie = tag.contains('kkal');
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isCalorie
                            ? const Color(0xFFF1F5F9)
                            : const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tag,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isCalorie
                              ? const Color(0xFF475569)
                              : const Color(0xFF16A34A),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                // Time & Action Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 15,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          meal.deliveryTime,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ],
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
}
