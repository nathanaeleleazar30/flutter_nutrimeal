# NutriMeal - Aplikasi Katering Sehat & Nutrisi Terpersonalisasi
> **Dokumentasi Teknis Tugas #9 Mobile Developer: Local Storage & Data Persistence (Offline-First)**

---

## 📌 Informasi Pengumpulan Tugas 9

| Komponen | Keterangan / Tautan |
|---|---|
| **Mata Kuliah / Divisi** | Mobile Developer - Software Engineering Division |
| **Topik Tugas** | Tugas #9: Local Storage & Data Persistence (Offline-First Architecture) |
| **Nama Proyek PBL** | NutriMeal (Project-Based Learning PBL UAS) |
| **Tautan Repository GitHub** | [https://github.com/nathanaeleleazar30/flutter_nutrimeal.git](https://github.com/nathanaeleleazar30/flutter_nutrimeal.git) |
| **Tautan Desain Figma PBL UAS** | [Tautan Figma Desain NutriMeal PBL UAS](https://www.figma.com/design/NutriMeal-PBL-UAS) *(Dapat disesuaikan dengan tautan Figma tim PBL masing-masing)* |

---

## 🎯 Ringkasan Implementasi Sesuai Scope of Work

Tugas ini mengimplementasikan modul **Local Storage & Data Persistence** dengan pendekatan **Offline-First**, memisahkan jenis penyimpanan sesuai dengan tipe dan sensitivitas datanya:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       NUTRIMEAL STORAGE ARCHITECTURE                        │
├───────────────────────┬─────────────────────────────┬───────────────────────┤
│    DATA TERSTRUKTUR   │     PENGATURAN & PREFERENSI │    SECRETS & TOKENS   │
│     (Offline-First)   │        (Non-Sensitif)       │       (Sensitif)      │
├───────────────────────┼─────────────────────────────┼───────────────────────┤
│     Drift (SQLite)    │      shared_preferences     │ flutter_secure_storage│
├───────────────────────┼─────────────────────────────┼───────────────────────┤
│ • Cache Menu / Meals  │ • Filter kategori terakhir  │ • Access Token (JWT)  │
│ • last_fetched (UTC)  │ • Status notifikasi aplikasi│ • Refresh Token       │
│ • Stream .watch()     │ • Timestamp sinkronisasi    │ • Kredensial User     │
│ • Atomic Transaction  │ • Mode tema / onboarding    │ • Auto-wipe on Logout │
└───────────────────────┴─────────────────────────────┴───────────────────────┘
```

---

## 🏗️ Rincian Pemenuhan Kriteria & Requirement

### 1. Implementasi Penyimpanan Terstruktur (Database Lokal - Drift)
* **Package**: `drift: ^2.35.2`, `sqlite3_flutter_libs: ^0.6.0+eol`, `path_provider`, `path`.
* **Lokasi Kode**: 
  * [`lib/data/local/database/app_database.dart`](file:///lib/data/local/database/app_database.dart)
  * [`lib/data/repositories/meal_repository.dart`](file:///lib/data/repositories/meal_repository.dart)
* **Kriteria Terpenuhi**:
  * **a. Type-Safe & Reaktif**: Menggunakan Drift SQLite untuk menyimpan data menu makanan (*meals*) dari backend.
  * **b. Offline Caching**: Data menu yang berhasil diambil dari backend otomatis disimpan di database lokal, sehingga aplikasi dapat dibuka dan digunakan dengan lancar saat tidak ada koneksi internet.
  * **c. Penanda Cache (`last_fetched`)**: Kolom `last_fetched` (format integer UTC milliseconds via `DateTime.now().toUtc().millisecondsSinceEpoch`) mencatat kapan data terakhir kali diperbarui dari server.
  * **d. Stream Reaktif (`.watch()`)**: Menggunakan `database.watchAllMeals()` pada lapisan data. Begitu ada pembaruan di database lokal, UI langsung ter-update otomatis secara *real-time*.
  * **e. Database Transaction (Atomic Write)**: Menggunakan `database.transaction(() async { ... })` dan Drift `batch` saat menyimpan banyak data menu sekaligus, mencegah rusaknya integritas data jika proses penulisan terinterupsi.

### 2. Implementasi Pengaturan (Settings - SharedPreferences)
* **Package**: `shared_preferences: ^2.5.6`.
* **Lokasi Kode**: [`lib/data/local/preferences/preferences_service.dart`](file:///lib/data/local/preferences/preferences_service.dart).
* **Kriteria Terpenuhi**:
  * **a. Non-Sensitive Data Only**: Hanya digunakan untuk menyimpan preferensi aplikasi berukuran kecil:
    * Kategori filter menu yang terakhir dipilih pengguna.
    * Status toggle *switch* notifikasi di menu Profil.
    * Timestamp terakhir sinkronisasi cache data.
    * Status onboarding/pengenalan aplikasi pertama kali.
  * Sama sekali tidak menyimpan data kredensial atau token di `shared_preferences`.

### 3. Implementasi Keamanan Rahasia (Secrets - FlutterSecureStorage)
* **Package**: `flutter_secure_storage: ^11.2.0`.
* **Lokasi Kode**: 
  * [`lib/data/local/secure/secure_storage_service.dart`](file:///lib/data/local/secure/secure_storage_service.dart)
  * [`lib/controllers/auth_controller.dart`](file:///lib/controllers/auth_controller.dart)
* **Kriteria Terpenuhi**:
  * **a. Keamanan Kredensial**: Menggunakan `FlutterSecureStorage` dengan enkripsi hardware Keystore (Android) / Keychain (iOS) untuk menyimpan `access_token`, `refresh_token`, dan `user_id`.
  * **b. Sesi Otomatis & Logout Bersih**:
    * Sesi dipulihkan secara otomatis via `restoreSession()` saat aplikasi dibuka.
    * Saat logout via dialog profil, seluruh kredensial dihapus permanen melalui `clearAllSecrets()`.
    * Mematuhi larangan keras menyimpan token pada `shared_preferences`.

### 4. Penerapan Clean Architecture & Global State Management
* **Separation of Concerns**:
  * `lib/data/local/database/`: Definisi tabel Drift, database singleton, dan kode generator `.g.dart`.
  * `lib/data/local/preferences/`: Layanan typed untuk Shared Preferences.
  * `lib/data/local/secure/`: Layanan terenkripsi untuk Flutter Secure Storage.
  * `lib/data/repositories/`: Repository pola offline-first yang menjembatani backend API, database lokal, dan stream reaktif.
  * `lib/controllers/`: Global State Management menggunakan `Provider` (`NutriMealMenuController`, `AuthController`).
  * `lib/screens/` & `lib/widgets/`: Antarmuka pengguna (UI) yang reaktif, modern, dan presisi sesuai Figma UAS.
* **Fitur Interaktif Global State**:
  * Keranjang belanja (*Cart*), badge counter pada bottom navigation bar, filter kategori, dan status autentikasi pengguna secara instan terefleksikan di berbagai layar.

---

## 🧪 Pengujian Otomatis (Unit & Integration Tests)

Seluruh requirement Tugas #9 telah diverifikasi dengan unit test otomatis pada [`test/local_storage_tugas9_test.dart`](file:///test/local_storage_tugas9_test.dart):

```bash
flutter test test/local_storage_tugas9_test.dart
```

**Hasil Pengujian:**
* ✅ `1.a & 1.c`: Menyimpan data menu terstruktur dengan penanda cache `last_fetched` (UTC millis).
* ✅ `1.d`: Fitur Stream reaktif (`.watch()`) memicu pembaruan otomatis saat data berubah.
* ✅ `1.e`: Database Transaction membungkus operasi penulisan multi-baris secara atomik.
* ✅ `2.a`: Menyimpan data non-sensitif (kategori, preferensi) pada `SharedPreferences`.
* ✅ `3.a`: Menyimpan data sensitif token & kredensial secara aman pada `FlutterSecureStorage`.
* ✅ `MealRepository`: Pengujian offline-first caching dan streaming model `MenuItem`.

---

## 🚀 Cara Menjalankan Proyek

1. **Unduh Dependensi**:
   ```bash
   flutter pub get
   ```

2. **Generate Kode Drift (jika diperlukan)**:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

3. **Jalankan Aplikasi**:
   ```bash
   flutter run
   ```

4. **Jalankan Analisis Kode**:
   ```bash
   flutter analyze
   ```
