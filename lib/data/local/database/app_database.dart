import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

/// Tabel Menu/Meals untuk menyimpan data terstruktur dari backend.
/// Memenuhi Requirement 1.a & 1.c (Penyimpanan terstruktur & penanda cache UTC millis)
class Meals extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get category => text()();
  IntColumn get calories => integer().withDefault(const Constant(0))();
  IntColumn get price => integer().withDefault(const Constant(0))();
  IntColumn get discountPercent => integer().nullable()();
  TextColumn get imageUrl => text()();
  TextColumn get description => text()();
  TextColumn get tags => text().withDefault(const Constant(''))();
  TextColumn get schedule => text().withDefault(const Constant('Setiap Hari'))();
  TextColumn get deliveryTime => text().withDefault(const Constant('12:00 - 13:00 WIB'))();
  TextColumn get protein => text().withDefault(const Constant('30g'))();
  TextColumn get fat => text().withDefault(const Constant('10g'))();
  TextColumn get carbs => text().withDefault(const Constant('40g'))();

  /// Requirement 1.c: Atribut penanda cache dalam format UTC millis
  /// untuk melacak kapan terakhir kali data diambil dari server.
  IntColumn get lastFetched => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'nutrimeal_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

@DriftDatabase(tables: [Meals])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  // Singleton instance untuk akses global yang efisien
  static AppDatabase? _instance;
  static AppDatabase get instance => _instance ??= AppDatabase();

  @override
  int get schemaVersion => 1;

  /// Requirement 1.d: Fitur Stream reaktif (.watch()) pada lapisan data.
  /// UI akan langsung memperbarui tampilannya secara otomatis segera
  /// setelah database lokal selesai menyimpan pembaruan.
  Stream<List<Meal>> watchAllMeals() {
    return (select(meals)..orderBy([(t) => OrderingTerm(expression: t.name)])).watch();
  }

  /// Ambil seluruh data menu dari database lokal secara asynchronous.
  Future<List<Meal>> getAllMeals() {
    return (select(meals)..orderBy([(t) => OrderingTerm(expression: t.name)])).get();
  }

  /// Requirement 1.e: Terapkan Database Transaction untuk membungkus operasi
  /// penulisan multi-baris secara atomik saat menyimpan respons API list data.
  Future<void> replaceAllMealsAtomic(List<MealsCompanion> mealEntries) async {
    await transaction(() async {
      await delete(meals).go();
      await batch((b) {
        b.insertAll(meals, mealEntries, mode: InsertMode.insertOrReplace);
      });
    });
  }

  /// Menghapus semua data menu dari database lokal.
  Future<void> clearAllMeals() async {
    await delete(meals).go();
  }
}
