import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../widgets/main_top_bar.dart';

class ScheduledMeal {
  final String slotType; // 'Makan Siang' | 'Makan Malam'
  final String title;
  final String imageUrl;
  final List<String> tags;
  final String deliveryTime;
  final int calories;

  const ScheduledMeal({
    required this.slotType,
    required this.title,
    required this.imageUrl,
    required this.tags,
    required this.deliveryTime,
    required this.calories,
  });
}

class DaySchedule {
  final String dayName;
  final int dayNumber;
  final List<ScheduledMeal> meals;

  const DaySchedule({
    required this.dayName,
    required this.dayNumber,
    required this.meals,
  });
}

class JadwalScreen extends StatefulWidget {
  final VoidCallback? onCartTap;
  final VoidCallback? onProfileTap;

  const JadwalScreen({
    super.key,
    this.onCartTap,
    this.onProfileTap,
  });

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  int _selectedDayIndex = 0;

  final List<DaySchedule> _schedules = const [
    DaySchedule(
      dayName: 'Sen',
      dayNumber: 12,
      meals: [
        ScheduledMeal(
          slotType: 'Makan Siang',
          title: 'Ayam Bakar Madu & Quinoa Hijau',
          imageUrl:
              'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=800&auto=format&fit=crop',
          tags: ['Tinggi Protein', '420 kkal'],
          deliveryTime: '12:00 - 13:00',
          calories: 420,
        ),
        ScheduledMeal(
          slotType: 'Makan Malam',
          title: 'Salmon Teriyaki & Nasi Merah',
          imageUrl:
              'https://images.unsplash.com/photo-1544025162-d76694265947?q=80&w=800&auto=format&fit=crop',
          tags: ['Tinggi Protein', 'Omega 3', '380 kkal'],
          deliveryTime: '18:30 - 19:30',
          calories: 380,
        ),
      ],
    ),
    DaySchedule(
      dayName: 'Sel',
      dayNumber: 13,
      meals: [
        ScheduledMeal(
          slotType: 'Makan Siang',
          title: 'Pepes Tongkol Rempah Kuning',
          imageUrl:
              'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?q=80&w=800&auto=format&fit=crop',
          tags: ['Tinggi Omega 3', '380 kkal'],
          deliveryTime: '12:00 - 13:00',
          calories: 380,
        ),
        ScheduledMeal(
          slotType: 'Makan Malam',
          title: 'Chicken Caesar Salad Light',
          imageUrl:
              'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?q=80&w=800&auto=format&fit=crop',
          tags: ['Low Carb', '320 kkal'],
          deliveryTime: '18:30 - 19:30',
          calories: 320,
        ),
      ],
    ),
    DaySchedule(
      dayName: 'Rab',
      dayNumber: 14,
      meals: [
        ScheduledMeal(
          slotType: 'Makan Siang',
          title: 'Beef Veggie Blackpepper Lean',
          imageUrl:
              'https://images.unsplash.com/photo-1543339308-43e59d6b73a6?q=80&w=800&auto=format&fit=crop',
          tags: ['Zat Besi Tinggi', '450 kkal'],
          deliveryTime: '12:00 - 13:00',
          calories: 450,
        ),
        ScheduledMeal(
          slotType: 'Makan Malam',
          title: 'Steamed Tofu & Mushroom Bowl',
          imageUrl:
              'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?q=80&w=800&auto=format&fit=crop',
          tags: ['Plant Based', '310 kkal'],
          deliveryTime: '18:30 - 19:30',
          calories: 310,
        ),
      ],
    ),
    DaySchedule(
      dayName: 'Kam',
      dayNumber: 15,
      meals: [
        ScheduledMeal(
          slotType: 'Makan Siang',
          title: 'Grilled Salmon Quinoa Bowl',
          imageUrl:
              'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=800&auto=format&fit=crop',
          tags: ['Superfood', '460 kkal'],
          deliveryTime: '12:00 - 13:00',
          calories: 460,
        ),
        ScheduledMeal(
          slotType: 'Makan Malam',
          title: 'Honey Mustard Chicken Deli',
          imageUrl:
              'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?q=80&w=800&auto=format&fit=crop',
          tags: ['Tinggi Protein', '390 kkal'],
          deliveryTime: '18:30 - 19:30',
          calories: 390,
        ),
      ],
    ),
    DaySchedule(
      dayName: 'Jum',
      dayNumber: 16,
      meals: [
        ScheduledMeal(
          slotType: 'Makan Siang',
          title: 'Ayam Wijen Panggang Brown Rice',
          imageUrl:
              'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?q=80&w=800&auto=format&fit=crop',
          tags: ['Nutrisi Lengkap', '440 kkal'],
          deliveryTime: '12:00 - 13:00',
          calories: 440,
        ),
        ScheduledMeal(
          slotType: 'Makan Malam',
          title: 'Salmon Poke Bowl Avocado',
          imageUrl:
              'https://images.unsplash.com/photo-1544025162-d76694265947?q=80&w=800&auto=format&fit=crop',
          tags: ['Omega 3 Tinggi', '420 kkal'],
          deliveryTime: '18:30 - 19:30',
          calories: 420,
        ),
      ],
    ),
  ];

  void _showChangeMenuDialog(ScheduledMeal meal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ubah Menu ${meal.slotType}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Menu saat ini: ${meal.title}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'PILIHAN MENU PENGGANTI',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              _buildAlternativeOption(ctx, 'Grilled Chicken Deli (450 kkal)'),
              _buildAlternativeOption(ctx, 'Salmon Poke Bowl (420 kkal)'),
              _buildAlternativeOption(ctx, 'Beef Veggie Bowl (460 kkal)'),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAlternativeOption(BuildContext ctx, String name) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Color(0xFFDCFCE7),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.restaurant_menu_rounded, color: AppColors.primaryGreen, size: 18),
      ),
      title: Text(
        name,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
      ),
      trailing: ElevatedButton(
        onPressed: () {
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Menu berhasil diganti ke $name'),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        ),
        child: const Text('Pilih', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentSchedule = _schedules[_selectedDayIndex];

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
                itemCount: _schedules.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final schedule = _schedules[index];
                  final isSelected = _selectedDayIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedDayIndex = index);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 62,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF0F5132) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF0F5132).withValues(alpha: 0.3),
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
                              color: isSelected ? Colors.white70 : const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${schedule.dayNumber}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? Colors.white : AppColors.textDark,
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
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                children: [
                  ...currentSchedule.meals.map((meal) => _buildMealCard(meal)),
                  const SizedBox(height: 10),

                  // Nutrisi Mingguan Card
                  _buildWeeklyNutritionCard(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCard(ScheduledMeal meal) {
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
                    child: const Icon(Icons.restaurant_rounded, size: 48, color: AppColors.primaryGreen),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isLunch ? const Color(0xFF059669) : const Color(0xFF4F46E5),
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
                        isLunch ? Icons.wb_sunny_rounded : Icons.nightlight_round,
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

                // Tags Row
                Row(
                  children: meal.tags.map((tag) {
                    final isCalorie = tag.contains('kkal');
                    return Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCalorie ? const Color(0xFFF1F5F9) : const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tag,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isCalorie ? const Color(0xFF475569) : const Color(0xFF16A34A),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                // Time Row & Ubah Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 15, color: Color(0xFF64748B)),
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
                    ElevatedButton(
                      onPressed: () => _showChangeMenuDialog(meal),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDCFCE7),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      ),
                      child: Text(
                        'Ubah',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryGreen,
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
    );
  }

  Widget _buildWeeklyNutritionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.primaryGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bolt_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nutrisi Mingguan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF065F46),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Anda mencapai 80% target protein minggu ini. Teruskan!',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF047857),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                    value: 0.8,
                    backgroundColor: Color(0xFFA7F3D0),
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
