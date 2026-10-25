import 'dart:convert';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_config.dart';
import '../../controllers/menu_controller.dart' show MenuItem, NutritionInfo;
import '../local/database/app_database.dart';
import '../local/preferences/preferences_service.dart';

/// Repository untuk mengelola data Meals / Menu.
/// Mengimplementasikan pendekatan Offline-First dengan database Drift dan Stream reaktif.
class MealRepository {
  final AppDatabase _db;
  final PreferencesService _prefs;

  MealRepository({
    AppDatabase? database,
    PreferencesService? preferences,
  })  : _db = database ?? AppDatabase.instance,
        _prefs = preferences ?? PreferencesService.instance;

  /// Requirement 1.d: Terapkan fitur Stream reaktif (.watch() pada Drift) pada lapisan data.
  /// UI akan langsung bereaksi secara instan saat data lokal bertambah/berubah.
  Stream<List<MenuItem>> watchMeals() {
    return _db.watchAllMeals().map((meals) {
      return meals.map(_mapMealEntityToModel).toList();
    });
  }

  /// Ambil data menu lokal yang tersimpan di Drift (offline cache)
  Future<List<MenuItem>> getLocalMeals() async {
    final localList = await _db.getAllMeals();
    return localList.map(_mapMealEntityToModel).toList();
  }

  /// Requirement 1.b, 1.c, & 1.e:
  /// Fetch data dari backend, lalu simpan ke database lokal menggunakan
  /// Transaction (atomic write) dengan penanda cache last_fetched (UTC millis).
  Future<bool> fetchAndCacheMeals() async {
    final candidates = ApiConfig.candidateMealsUrls;
    Object? lastError;

    for (final url in candidates) {
      try {
        if (kDebugMode) print('[MealRepository] Fetching dari: $url');
        final response = await http
            .get(Uri.parse(url))
            .timeout(const Duration(seconds: 8));

        if (response.statusCode == 200) {
          final uri = Uri.parse(url);
          final resolvedBase = '${uri.scheme}://${uri.host}:${uri.port}';

          final decoded = jsonDecode(response.body);
          List<dynamic> rawList;
          if (decoded is List) {
            rawList = decoded;
          } else if (decoded is Map && decoded.containsKey('data')) {
            rawList = decoded['data'] as List<dynamic>;
          } else if (decoded is Map && decoded.containsKey('meals')) {
            rawList = decoded['meals'] as List<dynamic>;
          } else {
            rawList = [];
          }

          if (rawList.isNotEmpty) {
            // Requirement 1.c: Timestamp UTC millis saat data di-fetch dari server
            final currentUtcMillis = DateTime.now().toUtc().millisecondsSinceEpoch;

            final entries = rawList.map((e) {
              final json = e as Map<String, dynamic>;
              final rawImg = (json['image_url'] ?? json['imageUrl'])?.toString();
              final resolvedImg = ApiConfig.resolveImageUrl(rawImg, activeBaseUrl: resolvedBase);

              final cal = int.tryParse(json['calories']?.toString() ?? '0') ?? 0;
              final prc = int.tryParse(json['price']?.toString() ?? '0') ?? 0;
              final rawDiscount = json['discount_percent'] ?? json['discountPercent'];
              final disc = int.tryParse(rawDiscount?.toString() ?? '0');

              List<String> tagsList = [];
              if (json['tags'] is List) {
                tagsList = (json['tags'] as List).map((t) => t.toString()).toList();
              } else if (json['tags'] is String) {
                tagsList = (json['tags'] as String).split(',').map((t) => t.trim()).toList();
              }

              return MealsCompanion.insert(
                id: json['id']?.toString() ?? 'item-${DateTime.now().millisecondsSinceEpoch}',
                name: json['name']?.toString() ?? 'Menu Sehat',
                category: json['category']?.toString() ?? 'Lainnya',
                calories: Value(cal),
                price: Value(prc),
                discountPercent: Value(disc != null && disc > 0 ? disc : null),
                imageUrl: resolvedImg,
                description: json['description']?.toString() ?? 'Menu lezat bergizi seimbang dari NutriMeal.',
                tags: Value(tagsList.join(',')),
                schedule: Value(json['schedule']?.toString() ?? 'Setiap Hari'),
                deliveryTime: Value(
                  json['delivery_time']?.toString() ??
                  json['deliveryTime']?.toString() ??
                  '12:00 - 13:00 WIB',
                ),
                protein: Value(json['protein']?.toString() ?? '30g'),
                fat: Value(json['fat']?.toString() ?? '10g'),
                carbs: Value(json['carbs']?.toString() ?? '40g'),
                // Requirement 1.c: Penanda cache UTC millis
                lastFetched: currentUtcMillis,
              );
            }).toList();

            // Requirement 1.e: Terapkan Database Transaction untuk membungkus
            // operasi penulisan multi-baris secara atomik
            await _db.replaceAllMealsAtomic(entries);

            // Simpan timestamp sinkronisasi terakhir ke SharedPreferences (Requirement 2.a)
            await _prefs.setLastCacheSyncUtcMillis(currentUtcMillis);

            if (kDebugMode) {
              print('[MealRepository] ✅ Berhasil menyimpan ${entries.length} menu secara atomik ke Drift DB. lastFetched=$currentUtcMillis');
            }
            return true;
          }
        }
      } catch (e) {
        lastError = e;
        if (kDebugMode) print('[MealRepository] Gagal fetch dari $url: $e');
      }
    }

    if (kDebugMode) {
      print('[MealRepository] Offline mode: Server tidak dapat dijangkau ($lastError). Menggunakan cache lokal Drift.');
    }
    return false;
  }

  /// Helper untuk memetakan Drift Entity (Meal) ke Domain Model (MenuItem)
  MenuItem _mapMealEntityToModel(Meal meal) {
    final tags = meal.tags.isNotEmpty
        ? meal.tags.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList()
        : <String>[];

    return MenuItem(
      id: meal.id,
      name: meal.name,
      category: meal.category,
      calories: meal.calories,
      price: meal.price,
      imageUrl: meal.imageUrl,
      description: meal.description,
      tags: tags,
      schedule: meal.schedule,
      deliveryTime: meal.deliveryTime,
      discountPercent: meal.discountPercent,
      nutrition: NutritionInfo(
        calories: meal.calories,
        protein: meal.protein,
        fat: meal.fat,
        carbs: meal.carbs,
      ),
    );
  }
}
