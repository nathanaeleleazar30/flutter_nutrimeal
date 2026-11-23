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

/// Data menu default katering Senin s/d Jumat (5 hari kerja)
const List<DaySchedule> dummySchedules = [
  DaySchedule(
    dayName: 'Sen',
    dayNumber: 1,
    meals: [
      ScheduledMeal(
        slotType: 'Makan Siang',
        title: 'Ayam Bakar Madu & Quinoa Hijau',
        imageUrl:
            'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=800&auto=format&fit=crop',
        tags: ['Tinggi Protein', '420 kkal'],
        deliveryTime: '12:00 - 13:00 WIB',
        calories: 420,
      ),
      ScheduledMeal(
        slotType: 'Makan Malam',
        title: 'Salmon Teriyaki & Nasi Merah',
        imageUrl:
            'https://images.unsplash.com/photo-1544025162-d76694265947?q=80&w=800&auto=format&fit=crop',
        tags: ['Tinggi Protein', 'Omega 3', '380 kkal'],
        deliveryTime: '18:30 - 19:30 WIB',
        calories: 380,
      ),
    ],
  ),
  DaySchedule(
    dayName: 'Sel',
    dayNumber: 2,
    meals: [
      ScheduledMeal(
        slotType: 'Makan Siang',
        title: 'Pepes Tongkol Rempah Kuning',
        imageUrl:
            'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?q=80&w=800&auto=format&fit=crop',
        tags: ['Tinggi Omega 3', '380 kkal'],
        deliveryTime: '12:00 - 13:00 WIB',
        calories: 380,
      ),
      ScheduledMeal(
        slotType: 'Makan Malam',
        title: 'Chicken Caesar Salad Light',
        imageUrl:
            'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?q=80&w=800&auto=format&fit=crop',
        tags: ['Low Carb', '320 kkal'],
        deliveryTime: '18:30 - 19:30 WIB',
        calories: 320,
      ),
    ],
  ),
  DaySchedule(
    dayName: 'Rab',
    dayNumber: 3,
    meals: [
      ScheduledMeal(
        slotType: 'Makan Siang',
        title: 'Beef Veggie Blackpepper Lean',
        imageUrl:
            'https://images.unsplash.com/photo-1543339308-43e59d6b73a6?q=80&w=800&auto=format&fit=crop',
        tags: ['Zat Besi Tinggi', '450 kkal'],
        deliveryTime: '12:00 - 13:00 WIB',
        calories: 450,
      ),
      ScheduledMeal(
        slotType: 'Makan Malam',
        title: 'Steamed Tofu & Mushroom Bowl',
        imageUrl:
            'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?q=80&w=800&auto=format&fit=crop',
        tags: ['Plant Based', '310 kkal'],
        deliveryTime: '18:30 - 19:30 WIB',
        calories: 310,
      ),
    ],
  ),
  DaySchedule(
    dayName: 'Kam',
    dayNumber: 4,
    meals: [
      ScheduledMeal(
        slotType: 'Makan Siang',
        title: 'Grilled Salmon Quinoa Bowl',
        imageUrl:
            'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=800&auto=format&fit=crop',
        tags: ['Superfood', '460 kkal'],
        deliveryTime: '12:00 - 13:00 WIB',
        calories: 460,
      ),
      ScheduledMeal(
        slotType: 'Makan Malam',
        title: 'Honey Mustard Chicken Deli',
        imageUrl:
            'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?q=80&w=800&auto=format&fit=crop',
        tags: ['Tinggi Protein', '390 kkal'],
        deliveryTime: '18:30 - 19:30 WIB',
        calories: 390,
      ),
    ],
  ),
  DaySchedule(
    dayName: 'Jum',
    dayNumber: 5,
    meals: [
      ScheduledMeal(
        slotType: 'Makan Siang',
        title: 'Ayam Wijen Panggang Brown Rice',
        imageUrl:
            'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?q=80&w=800&auto=format&fit=crop',
        tags: ['Nutrisi Lengkap', '440 kkal'],
        deliveryTime: '12:00 - 13:00 WIB',
        calories: 440,
      ),
      ScheduledMeal(
        slotType: 'Makan Malam',
        title: 'Salmon Poke Bowl Avocado',
        imageUrl:
            'https://images.unsplash.com/photo-1544025162-d76694265947?q=80&w=800&auto=format&fit=crop',
        tags: ['Omega 3 Tinggi', '420 kkal'],
        deliveryTime: '18:30 - 19:30 WIB',
        calories: 420,
      ),
    ],
  ),
];

/// Helper untuk menghasilkan jadwal katering Senin s/d Jumat secara REAL-TIME
/// dengan tanggal kalender yang otomatis mengikuti minggu berjalan.
List<DaySchedule> buildRealtimeCateringSchedules({List<dynamic>? dynamicMeals}) {
  final now = DateTime.now();
  // Jika hari Sabtu (6) atau Minggu (7), ambil Senin minggu berikutnya
  final int offsetToMonday = (now.weekday <= 5) ? (1 - now.weekday) : (8 - now.weekday);
  final mondayDate = now.add(Duration(days: offsetToMonday));

  final weekDays = [
    {'short': 'Sen', 'full': 'senin'},
    {'short': 'Sel', 'full': 'selasa'},
    {'short': 'Rab', 'full': 'rabu'},
    {'short': 'Kam', 'full': 'kamis'},
    {'short': 'Jum', 'full': 'jumat'},
  ];

  return List.generate(5, (index) {
    final dayInfo = weekDays[index];
    final dayDate = mondayDate.add(Duration(days: index));

    List<ScheduledMeal> scheduledMeals = [];

    // Jika ada menu dinamis dari repository/API, cocokkan berdasarkan schedule
    if (dynamicMeals != null && dynamicMeals.isNotEmpty) {
      final matching = dynamicMeals.where((m) {
        final sch = (m.schedule ?? '').toString().toLowerCase();
        return sch.contains(dayInfo['full']!);
      }).toList();

      for (int i = 0; i < matching.length && i < 2; i++) {
        final m = matching[i];
        final rawTags = m.tags is List
            ? (m.tags as List).map((e) => e.toString()).toList()
            : <String>[];
        scheduledMeals.add(ScheduledMeal(
          slotType: i == 0 ? 'Makan Siang' : 'Makan Malam',
          title: m.name ?? 'Menu Sehat',
          imageUrl: m.imageUrl ?? '',
          tags: rawTags.isNotEmpty ? rawTags : [m.category ?? 'Sehat', '${m.calories} kkal'],
          deliveryTime: i == 0 ? '12:00 - 13:00 WIB' : '18:30 - 19:30 WIB',
          calories: m.calories ?? 400,
        ));
      }
    }

    // Gunakan fallback dummy jika belum terisi dari dynamicMeals
    if (scheduledMeals.isEmpty) {
      scheduledMeals = List.from(dummySchedules[index].meals);
    } else if (scheduledMeals.length == 1) {
      if (dummySchedules[index].meals.length > 1) {
        scheduledMeals.add(dummySchedules[index].meals[1]);
      }
    }

    return DaySchedule(
      dayName: dayInfo['short']!,
      dayNumber: dayDate.day, // Tanggal real-time dari kalender!
      meals: scheduledMeals,
    );
  });
}
