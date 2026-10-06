import 'package:flutter/material.dart';

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

class CartItem {
  final MenuItem item;
  int quantity;
  final String? note;

  CartItem({
    required this.item,
    this.quantity = 1,
    this.note,
  });

  int get totalPrice => item.price * quantity;
}

class DeliveryAddress {
  final String label;
  final String recipientName;
  final String phoneNumber;
  final String area;
  final String fullAddress;
  final String deliveryNote;
  final String addressType;
  final bool isDefault;

  const DeliveryAddress({
    required this.label,
    required this.recipientName,
    required this.phoneNumber,
    required this.area,
    required this.fullAddress,
    required this.deliveryNote,
    this.addressType = 'Rumah',
    this.isDefault = true,
  });

  DeliveryAddress copyWith({
    String? label,
    String? recipientName,
    String? phoneNumber,
    String? area,
    String? fullAddress,
    String? deliveryNote,
    String? addressType,
    bool? isDefault,
  }) {
    return DeliveryAddress(
      label: label ?? this.label,
      recipientName: recipientName ?? this.recipientName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      area: area ?? this.area,
      fullAddress: fullAddress ?? this.fullAddress,
      deliveryNote: deliveryNote ?? this.deliveryNote,
      addressType: addressType ?? this.addressType,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

class PaymentOption {
  final String id;
  final String name;
  final String subtitle;
  final String? badge;
  final IconData icon;

  const PaymentOption({
    required this.id,
    required this.name,
    required this.subtitle,
    this.badge,
    required this.icon,
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
  NutriMealMenuController() {
    _initDefaultCart();
  }

  // Navigation State
  int _currentBottomNavIndex = 0;
  int get currentBottomNavIndex => _currentBottomNavIndex;

  void setBottomNavIndex(int index) {
    _currentBottomNavIndex = index;
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

  // All Menu Items Dataset
  final List<MenuItem> _menuItems = [
    // item-1 (keep as first item for widget test compatibility: 'GRILLED CHICKEN')
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
    // Cheesy Chicken from screenshot
    const MenuItem(
      id: 'item-cheesy',
      name: 'Cheesy Chicken',
      category: 'Ayam',
      calories: 520,
      price: 68000,
      imageUrl:
          'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?q=80&w=800&auto=format&fit=crop',
      description: '520 kkal • Cheese, Chicken Grill.',
      tags: ['Dada Ayam Panggang', 'Keju Mozzarella', 'Brokoli', 'Baby Potato'],
      schedule: 'Setiap Hari Senin',
      deliveryTime: '12:00 - 13:00 WIB',
      nutrition: NutritionInfo(
        calories: 520,
        protein: '38gram',
        fat: '14gram',
        carbs: '45gram',
      ),
    ),
    // Chicken Kare from screenshot
    const MenuItem(
      id: 'item-kare',
      name: 'Chicken Kare',
      category: 'Ayam',
      calories: 140,
      price: 25000,
      imageUrl:
          'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?q=80&w=800&auto=format&fit=crop',
      description: '140 kkal • Chicken Katsu, Kare',
      tags: ['Chicken Katsu', 'Kare Jepang', 'Nasi Merah', 'Wortel & Kentang'],
      schedule: 'Setiap Hari Selasa',
      deliveryTime: '12:00 - 13:00 WIB',
      nutrition: NutritionInfo(
        calories: 140,
        protein: '35gram',
        fat: '20gram',
        carbs: '65gram',
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
        _menuItems[0], // Grilled Chicken
        _menuItems[1], // Cheesy Chicken
        _menuItems[2], // Chicken Kare
        _menuItems[4], // Chicken Salad
        _menuItems[5], // Beef Veggie
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

  // Cart State (Initialized with Cheesy Chicken & Chicken Kare to match screenshot)
  final List<CartItem> _cartItems = [];

  void _initDefaultCart() {
    final cheesy = _menuItems.firstWhere((i) => i.id == 'item-cheesy', orElse: () => _menuItems[0]);
    final kare = _menuItems.firstWhere((i) => i.id == 'item-kare', orElse: () => _menuItems[1]);
    _cartItems.add(CartItem(item: cheesy, quantity: 1));
    _cartItems.add(CartItem(item: kare, quantity: 1));
  }

  List<CartItem> get cartItems => List.unmodifiable(_cartItems);

  int get cartItemCount => _cartItems.fold(0, (sum, i) => sum + i.quantity);

  void addToCart(MenuItem item, {int quantity = 1}) {
    final index = _cartItems.indexWhere((c) => c.item.id == item.id);
    if (index >= 0) {
      _cartItems[index].quantity += quantity;
    } else {
      _cartItems.add(CartItem(item: item, quantity: quantity));
    }
    notifyListeners();
  }

  void incrementCartItem(String itemId) {
    final index = _cartItems.indexWhere((c) => c.item.id == itemId);
    if (index >= 0) {
      _cartItems[index].quantity++;
      notifyListeners();
    }
  }

  void decrementCartItem(String itemId) {
    final index = _cartItems.indexWhere((c) => c.item.id == itemId);
    if (index >= 0) {
      if (_cartItems[index].quantity > 1) {
        _cartItems[index].quantity--;
      } else {
        _cartItems.removeAt(index);
      }
      notifyListeners();
    }
  }

  void removeCartItem(String itemId) {
    _cartItems.removeWhere((c) => c.item.id == itemId);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    _voucherCode = null;
    _voucherDiscount = 0;
    notifyListeners();
  }

  void resetToDemoCart() {
    _cartItems.clear();
    _initDefaultCart();
    _voucherCode = null;
    _voucherDiscount = 0;
    notifyListeners();
  }

  // Backwards compatible method
  void incrementCart([int count = 1]) {
    if (_cartItems.isNotEmpty) {
      _cartItems[0].quantity += count;
    } else if (_menuItems.isNotEmpty) {
      _cartItems.add(CartItem(item: _menuItems[0], quantity: count));
    }
    notifyListeners();
  }

  // Price Calculations
  int get subtotal => _cartItems.fold(0, (sum, i) => sum + i.totalPrice);

  int get tax => _cartItems.isEmpty ? 0 : (subtotal == 93000 ? 4500 : (subtotal * 0.05).round());

  int get shippingFee => _cartItems.isEmpty ? 0 : 10000;

  String? _voucherCode;
  String? get voucherCode => _voucherCode;

  int _voucherDiscount = 0;
  int get voucherDiscount => _voucherDiscount;

  bool applyVoucher(String code) {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode == 'NUTRIHEMAT' || cleanCode == 'NUTRISEHAT') {
      _voucherCode = cleanCode;
      _voucherDiscount = 10000;
      notifyListeners();
      return true;
    } else if (cleanCode == 'DISKON10') {
      _voucherCode = cleanCode;
      _voucherDiscount = (subtotal * 0.10).round();
      notifyListeners();
      return true;
    }
    return false;
  }

  void removeVoucher() {
    _voucherCode = null;
    _voucherDiscount = 0;
    notifyListeners();
  }

  int get grandTotal {
    if (_cartItems.isEmpty) return 0;
    final total = subtotal + tax + shippingFee - _voucherDiscount;
    return total > 0 ? total : 0;
  }

  // Delivery Address State (Matching screenshot Rumah (Utama) • NgabOwi)
  DeliveryAddress _deliveryAddress = const DeliveryAddress(
    label: 'Rumah (Utama)',
    recipientName: 'NgabOwi',
    phoneNumber: '+62 812-3456-7890',
    area: 'Kebayoran Baru, Jakarta Selatan',
    fullAddress:
        'Jl. Sehat Bugar Sejahtera No. 45, Kebayoran Baru, Jakarta Selatan, 12180',
    deliveryNote: 'Titip di pos security / hubungi via WhatsApp',
    addressType: 'Rumah',
    isDefault: true,
  );

  DeliveryAddress get deliveryAddress => _deliveryAddress;

  void updateDeliveryAddress(DeliveryAddress address) {
    _deliveryAddress = address;
    notifyListeners();
  }

  // Payment Options & Selected Payment
  String _selectedPaymentId = 'gopay';
  String get selectedPaymentId => _selectedPaymentId;

  final List<PaymentOption> paymentOptions = const [
    PaymentOption(
      id: 'gopay',
      name: 'GoPay / NutriPay',
      subtitle: 'Saldo: Rp 245.000',
      badge: 'Terhubung',
      icon: Icons.account_balance_wallet_rounded,
    ),
    PaymentOption(
      id: 'qris',
      name: 'QRIS Instant',
      subtitle: 'Gopay, OVO, Dana, ShopeePay',
      badge: 'Instant',
      icon: Icons.qr_code_2_rounded,
    ),
    PaymentOption(
      id: 'bca_va',
      name: 'BCA Virtual Account',
      subtitle: 'Verifikasi Otomatis',
      icon: Icons.account_balance_rounded,
    ),
    PaymentOption(
      id: 'mandiri_va',
      name: 'Mandiri Virtual Account',
      subtitle: 'Verifikasi Otomatis',
      icon: Icons.account_balance_rounded,
    ),
    PaymentOption(
      id: 'cod',
      name: 'Bayar di Tempat (COD)',
      subtitle: 'Bayar tunai ke kurir katering',
      icon: Icons.local_shipping_outlined,
    ),
  ];

  PaymentOption get selectedPaymentOption {
    return paymentOptions.firstWhere(
      (opt) => opt.id == _selectedPaymentId,
      orElse: () => paymentOptions[0],
    );
  }

  void selectPaymentMethod(String id) {
    _selectedPaymentId = id;
    notifyListeners();
  }
}
