import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend_nutrimeal/data/local/database/app_database.dart';
import 'package:frontend_nutrimeal/data/local/preferences/preferences_service.dart';
import 'package:frontend_nutrimeal/data/local/secure/secure_storage_service.dart';
import 'package:frontend_nutrimeal/data/repositories/meal_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Tugas #9: 1. Penyimpanan Terstruktur (Drift SQLite Database)', () {
    late AppDatabase database;

    setUp(() {
      // Menggunakan in-memory Drift database untuk pengujian yang terisolasi dan cepat
      database = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await database.close();
    });

    test('1.a & 1.c: Menyimpan data menu terstruktur dengan penanda cache last_fetched (UTC millis)', () async {
      final nowUtcMillis = DateTime.now().toUtc().millisecondsSinceEpoch;

      final mealEntry = MealsCompanion.insert(
        id: 'item-test-1',
        name: 'Salmon Grill Healthy',
        category: 'Ikan',
        calories: const Value(380),
        price: const Value(45000),
        discountPercent: const Value(10),
        imageUrl: 'https://example.com/salmon.jpg',
        description: 'Salmon panggang kaya omega 3',
        tags: const Value('Salmon,Omega3,Healthy'),
        schedule: const Value('Senin - Rabu'),
        deliveryTime: const Value('12:00 - 13:00 WIB'),
        protein: const Value('32g'),
        fat: const Value('12g'),
        carbs: const Value('25g'),
        lastFetched: nowUtcMillis,
      );

      await database.replaceAllMealsAtomic([mealEntry]);

      final allMeals = await database.getAllMeals();
      expect(allMeals.length, equals(1));
      expect(allMeals.first.id, equals('item-test-1'));
      expect(allMeals.first.name, equals('Salmon Grill Healthy'));
      expect(allMeals.first.category, equals('Ikan'));
      expect(allMeals.first.calories, equals(380));
      expect(allMeals.first.lastFetched, equals(nowUtcMillis));
    });

    test('1.d: Fitur Stream reaktif (.watch()) memicu pembaruan otomatis saat data berubah', () async {
      final nowUtcMillis = DateTime.now().toUtc().millisecondsSinceEpoch;
      final futureUpdate = database.watchAllMeals().firstWhere((list) => list.isNotEmpty);

      await database.replaceAllMealsAtomic([
        MealsCompanion.insert(
          id: 'item-stream-1',
          name: 'Chicken Caesar Salad',
          category: 'Ayam',
          imageUrl: 'https://example.com/salad.jpg',
          description: 'Salad ayam segar kaya serat',
          lastFetched: nowUtcMillis,
        ),
      ]);

      final updatedList = await futureUpdate;
      expect(updatedList.length, equals(1));
      expect(updatedList.first.name, equals('Chicken Caesar Salad'));
    });

    test('1.e: Database Transaction membungkus operasi penulisan multi-baris secara atomik', () async {
      final nowUtcMillis = DateTime.now().toUtc().millisecondsSinceEpoch;

      final batchMeals = [
        MealsCompanion.insert(
          id: 'meal-1',
          name: 'Menu Batch 1',
          category: 'Ayam',
          imageUrl: 'https://example.com/m1.jpg',
          description: 'Desc 1',
          lastFetched: nowUtcMillis,
        ),
        MealsCompanion.insert(
          id: 'meal-2',
          name: 'Menu Batch 2',
          category: 'Daging',
          imageUrl: 'https://example.com/m2.jpg',
          description: 'Desc 2',
          lastFetched: nowUtcMillis,
        ),
        MealsCompanion.insert(
          id: 'meal-3',
          name: 'Menu Batch 3',
          category: 'Seafood',
          imageUrl: 'https://example.com/m3.jpg',
          description: 'Desc 3',
          lastFetched: nowUtcMillis,
        ),
      ];

      // Atomic replace
      await database.replaceAllMealsAtomic(batchMeals);

      final count = (await database.getAllMeals()).length;
      expect(count, equals(3));
    });
  });

  group('Tugas #9: 2. Implementasi Pengaturan (SharedPreferences)', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('2.a: Menyimpan data non-sensitif (kategori, filter, preferensi)', () async {
      final prefsService = PreferencesService.instance;

      await prefsService.setSelectedFilterCategory('Ayam');
      expect(await prefsService.getSelectedFilterCategory(), equals('Ayam'));

      await prefsService.setNotificationEnabled(false);
      expect(await prefsService.isNotificationEnabled(), isFalse);

      final testUtcMillis = 1776510000000;
      await prefsService.setLastCacheSyncUtcMillis(testUtcMillis);
      expect(await prefsService.getLastCacheSyncUtcMillis(), equals(testUtcMillis));
    });
  });

  group('Tugas #9: 3. Implementasi Keamanan Rahasia (FlutterSecureStorage)', () {
    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
    });

    test('3.a: Menyimpan data sensitif token & kredensial secara aman', () async {
      final secureService = SecureStorageService.instance;

      await secureService.saveUserCredentials(
        token: 'jwt-access-token-secret-12345',
        userId: 'cust-9988',
        email: 'user@nutrimeal.com',
        name: 'User NutriMeal',
        refreshToken: 'jwt-refresh-token-secret-67890',
      );

      final creds = await secureService.getUserCredentials();
      expect(creds['token'], equals('jwt-access-token-secret-12345'));
      expect(creds['refreshToken'], equals('jwt-refresh-token-secret-67890'));
      expect(creds['userId'], equals('cust-9988'));
      expect(creds['email'], equals('user@nutrimeal.com'));
      expect(creds['name'], equals('User NutriMeal'));

      // Logout / clear secrets
      await secureService.clearAllSecrets();
      final clearedCreds = await secureService.getUserCredentials();
      expect(clearedCreds['token'], isNull);
    });
  });

  group('Tugas #9: MealRepository Offline-First & Stream', () {
    late AppDatabase database;
    late MealRepository repository;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      database = AppDatabase(NativeDatabase.memory());
      repository = MealRepository(
        database: database,
        preferences: PreferencesService.instance,
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('Repository watchMeals memancarkan domain MenuItem model', () async {
      final futureUpdate = repository.watchMeals().firstWhere((list) => list.isNotEmpty);

      await database.replaceAllMealsAtomic([
        MealsCompanion.insert(
          id: 'off-1',
          name: 'Offline Meal 1',
          category: 'Ayam',
          imageUrl: 'https://example.com/off.jpg',
          description: 'Delicious offline meal',
          lastFetched: DateTime.now().toUtc().millisecondsSinceEpoch,
        ),
      ]);

      final items = await futureUpdate;
      expect(items.length, equals(1));
      expect(items.first.name, equals('Offline Meal 1'));
    });
  });
}
