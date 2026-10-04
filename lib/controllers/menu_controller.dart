import 'package:flutter/foundation.dart';

class NutritionInfo {
  final int calories;
  final String protein;
  final String fat;
  final String carbs;

  const NutritionInfo({
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  });
}

class MenuItem {
  final String id;
  final String name;
  final String category;
  final int calories;
  final int price;
  final String imageUrl;
  final String description;
  final List<String> tags;
  final String schedule;
  final String deliveryTime;
  final int? discountPercent;
  final NutritionInfo nutrition;

  const MenuItem({
    required this.id,
    required this.name,
    required this.category,
    required this.calories,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.tags,
    required this.schedule,
    required this.deliveryTime,
    this.discountPercent,
    required this.nutrition,
  });
}

class CateringDayItem {
  final String dayShort;
  final String subtitle;

  const CateringDayItem({
    required this.dayShort,
    required this.subtitle,
  });
}

class NutriMealMenuController extends ChangeNotifier {
  // Navigation State
  int _currentBottomNavIndex = 0;
  int get currentBottomNavIndex => _currentBottomNavIndex;

  void setBottomNavIndex(int index) {
    _currentBottomNavIndex = index;
    notifyListeners();
  }

  // Cart State (Initialized with 2 items matching badge '2' in the screenshot)
  int _cartItemCount = 2;
  int get cartItemCount => _cartItemCount;

  void incrementCart([int count = 1]) {
    _cartItemCount += count;
    notifyListeners();
  }

  // Selected Catering Day
  int _selectedCateringDayIndex = 0;
  int get selectedCateringDayIndex => _selectedCateringDayIndex;

  final List<CateringDayItem> cateringDays = const [
    CateringDayItem(dayShort: 'SEN', subtitle: 'Hari Ini'),
    CateringDayItem(dayShort: 'SEL', subtitle: 'Menu 2'),
    CateringDayItem(dayShort: 'RAB', subtitle: 'Menu 3'),
    CateringDayItem(dayShort: 'KAM', subtitle: 'Menu 4'),
    CateringDayItem(dayShort: 'JUM', subtitle: 'Menu 5'),
  ];

  void selectCateringDay(int index) {
    _selectedCateringDayIndex = index;
    notifyListeners();
  }

  // Selected Category filter
  String _selectedCategory = 'Semua';
  String get selectedCategory => _selectedCategory;

  final List<String> categories = const [
    'Semua',
    'Ayam',
    'Ikan',
    'Daging',
    'Seafood',
    'Roti',
  ];

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Search Filter
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // All Menu Items Dataset (Matching screenshot dishes and nutrition)
  final List<MenuItem> _menuItems = [
    const MenuItem(
      id: 'item-1',
      name: 'Grilled Chicken',
      category: 'Ayam',
      calories: 450,
      price: 20000,
      discountPercent: 20,
      imageUrl:
          'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?q=80&w=800&auto=format&fit=crop',
      description:
          'Juicy Grilled Chicken, Grilled potato, Fresh Broccoli, seasoning parmesan Cheese',
      tags: [
        'Dada Ayam Panggang',
        'Brokoli Kukus',
        'Parmesan Cheese',
        'Wortel Serut',
        'Dressing Wijen',
      ],
      schedule: 'Setiap Hari Senin',
      deliveryTime: '12:00 - 13:00 WIB',
      nutrition: NutritionInfo(
        calories: 520,
        protein: '35gram',
        fat: '12gram',
        carbs: '55gram',
      ),
    ),
    const MenuItem(
      id: 'item-2',
      name: 'Pepes Tongkol',
      category: 'Ikan',
      calories: 380,
      price: 45000,
      imageUrl:
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=800&auto=format&fit=crop',
      description:
          'Pepes ikan tongkol bumbu rempah kuning kaya antioksidan dan omega-3 disajikan hangat.',
      tags: ['Ikan Tongkol Segar', 'Kemangi', 'Kunyit', 'Cabai Merah', 'Nasi Merah'],
      schedule: 'Setiap Hari Selasa',
      deliveryTime: '12:00 - 13:00 WIB',
      nutrition: NutritionInfo(
        calories: 380,
        protein: '38gram',
        fat: '10gram',
        carbs: '30gram',
      ),
    ),
    const MenuItem(
      id: 'item-3',
      name: 'Chicken Salad',
      category: 'Ayam',
      calories: 320,
      price: 30000,
      imageUrl:
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?q=80&w=800&auto=format&fit=crop',
      description:
          'Fresh green salad dengan irisan dada ayam bakar lembut, tomat ceri, dan dressing zaitun rendah kalori.',
      tags: ['Dada Ayam', 'Romaine Lettuce', 'Tomat Ceri', 'Mentimun', 'Olive Oil'],
      schedule: 'Setiap Hari Rabu',
      deliveryTime: '12:00 - 13:00 WIB',
      nutrition: NutritionInfo(
        calories: 320,
        protein: '32gram',
        fat: '8gram',
        carbs: '22gram',
      ),
    ),
    const MenuItem(
      id: 'item-4',
      name: 'Beef Veggie',
      category: 'Daging',
      calories: 520,
      price: 40000,
      imageUrl:
          'https://images.unsplash.com/photo-1544025162-d76694265947?q=80&w=800&auto=format&fit=crop',
      description:
          'Tumis daging sapi lada hitam rendah lemak dipadu paprika renyah dan brokoli segar bernutrisi tinggi.',
      tags: ['Daging Sapi Lean', 'Paprika Merah & Hijau', 'Brokoli', 'Bawang Bombay'],
      schedule: 'Setiap Hari Kamis',
      deliveryTime: '12:00 - 13:00 WIB',
      nutrition: NutritionInfo(
        calories: 520,
        protein: '42gram',
        fat: '15gram',
        carbs: '40gram',
      ),
    ),
    const MenuItem(
      id: 'item-5',
      name: 'Ayam Bowl',
      category: 'Ayam',
      calories: 520,
      price: 28000,
      imageUrl:
          'https://images.unsplash.com/photo-1543339308-43e59d6b73a6?q=80&w=800&auto=format&fit=crop',
      description:
          'Healthy poke bowl dengan suwiran ayam gurih, jagung manis, kubis ungu, dan edamame segar.',
      tags: ['Suwir Ayam', 'Jagung Manis', 'Kubis Ungu', 'Edamame', 'Nasi Coklat'],
      schedule: 'Setiap Hari Jumat',
      deliveryTime: '12:00 - 13:00 WIB',
      nutrition: NutritionInfo(
        calories: 520,
        protein: '36gram',
        fat: '14gram',
        carbs: '58gram',
      ),
    ),
    const MenuItem(
      id: 'item-6',
      name: 'Chicken Wrap',
      category: 'Roti',
      calories: 350,
      price: 28000,
      imageUrl:
          'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?q=80&w=800&auto=format&fit=crop',
      description:
          'Tortilla bayam lembut membungkus ayam panggang, selada renyah, dan saus yoghurt herbs.',
      tags: ['Tortilla Bayam', 'Ayam Panggang', 'Selada', 'Yoghurt Dressing'],
      schedule: 'Setiap Hari Sabtu',
      deliveryTime: '12:00 - 13:00 WIB',
      nutrition: NutritionInfo(
        calories: 350,
        protein: '28gram',
        fat: '11gram',
        carbs: '38gram',
      ),
    ),
  ];

  List<MenuItem> get allMenuItems => _menuItems;

  List<MenuItem> get popularMenuItems => [
        _menuItems[2], // Chicken Salad
        _menuItems[3], // Beef Veggie
        _menuItems[4], // Ayam Bowl
        _menuItems[5], // Chicken Wrap
      ];

  List<MenuItem> get filteredMenuItems {
    return _menuItems.where((item) {
      final matchesCategory = _selectedCategory == 'Semua' ||
          item.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesQuery = _searchQuery.isEmpty ||
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }

  // Selected Detail Item
  MenuItem? _selectedMenuItem;
  MenuItem get selectedMenuItem => _selectedMenuItem ?? _menuItems[0];

  void selectMenuItem(MenuItem item) {
    _selectedMenuItem = item;
    notifyListeners();
  }
}
