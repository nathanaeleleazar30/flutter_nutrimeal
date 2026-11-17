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

const List<DaySchedule> dummySchedules = [
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
