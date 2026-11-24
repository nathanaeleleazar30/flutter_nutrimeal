# 🚀 NutriMeal - Panduan Kesiapan Deploy & Checklist Produksi

Dokumen ini merupakan laporan audit dan panduan teknis operasional akhir untuk tim pengembang dan pemilik produk **NutriMeal** sebelum merilis aplikasi ke lingkungan produksi (Google Play Store, Apple App Store, dan Web).

---

## 📊 1. Ringkasan Status Verifikasi Kualitas Proyek

Semua pengujian dan pemeriksaan statis telah berhasil dijalankan dengan hasil **100% LULUS**:

| Pemeriksaan | Perintah | Status | Keterangan |
| :--- | :--- | :---: | :--- |
| **Dart Code Formatting** | `dart format --set-exit-if-changed .` | ✅ **LULUS** | 87 file diformat rapi sesuai standar resmi Dart. |
| **Static Code Analysis** | `flutter analyze` | ✅ **LULUS** | **0 issues found** (Bebas error, bebas warning). |
| **Unit & Database Tests** | `flutter test test/local_storage_tugas9_test.dart` | ✅ **LULUS** | 6/6 test pass (Drift SQLite, SharedPreferences, FlutterSecureStorage). |
| **Widget & Screen Tests** | `flutter test test/widget_test.dart` | ✅ **LULUS** | 16/16 test pass (Semua alur layar dan integrasi Provider). |
| **Release Build Kompilasi** | `flutter build apk --release` | ✅ **LULUS** | Berhasil menghasilkan APK release (65.3 MB). |

---

## 🛠️ 2. Daftar Perbaikan & Penyempurnaan yang Telah Diterapkan

### A. Arsitektur Jaringan & Konfigurasi API Dinamis (`ApiConfig`)
- **Masalah Sebelumnya:** URL backend menggunakan IP lokal hardcoded (`10.255.191.102`), yang akan gagal total saat dijalankan di perangkat pelanggan atau jaringan berbeda.
- **Penyempurnaan:**
  - Ditambahkan dukungan environment variable `--dart-define=API_URL=https://api.nutrimeal.app`.
  - Kandidat endpoint diprioritaskan: jika `API_URL` didefinisikan saat build produksi, aplikasi langsung mengarah ke URL produksi tanpa mencoba IP lokal.
  - File: `lib/core/constants/api_config.dart`.

### B. Ketahanan Data & Offline Resilience (`ApiService` & `BantuanFaqScreen`)
- **Masalah Sebelumnya:** Jika koneksi backend MySQL terputus atau server dalam pemeliharaan, layar bantuan FAQ menampilkan layar kosong tanpa informasi.
- **Penyempurnaan:**
  - Ditambahkan `defaultFaqs` offline fallback langsung di `ApiService.fetchFaqs()`.
  - Komponen accordion FAQ diperbaiki menggunakan `Material` dengan `shape: RoundedRectangleBorder`, menghilangkan warning `ListTile background color or ink splashes may be invisible`.
  - File: `lib/services/api_service.dart`, `lib/screens/profile/bantuan_faq_screen.dart`.

### C. Responsivitas Layar & Eliminasi RenderFlex Overflow (`KeranjangScreen` & `LanggananKatalogScreen`)
- **Masalah Sebelumnya:**
  - Pada `KeranjangScreen`, kotak logo QRIS overflow sebesar 13 piksel pada layar resolusi tertentu.
  - Pada `LanggananKatalogScreen`, bottom bar overflow sebesar 34 piksel.
- **Penyempurnaan:**
  - Pada `KeranjangScreen`, logo QRIS dibungkus `FittedBox(fit: BoxFit.scaleDown)` dengan lebar proporsional 62 dp.
  - Pada `LanggananKatalogScreen`, kolom teks total harga dibungkus `Expanded`, badge hero diperbarui menjadi thumbnail 88x88 berkualitas tinggi dengan badge *"100% FRESH"* dan *"★ PALING POPULER"*.
  - File: `lib/screens/order/keranjang_screen.dart`, `lib/screens/subscription/langganan_katalog_screen.dart`.

### D. Otomatisasi Navigasi & Keamanan Sesi (`SplashScreen`)
- **Penyempurnaan:** `SplashScreen` kini secara aman membaca status login dan token JWT dari `FlutterSecureStorage`. Pengguna yang sudah terotentikasi langsung diarahkan ke `/home` tanpa harus login ulang, sedangkan pengguna baru diarahkan ke `/login`.
- File: `lib/screens/auth/splash_screen.dart`.

### E. Penyesuaian Identitas Native (Android, iOS, Web, Pubspec)
1. **Android (`android/app/build.gradle.kts` & `AndroidManifest.xml`):**
   - Application ID diubah menjadi `com.nutrimeal.app`.
   - Nama aplikasi di launcher diubah menjadi **NutriMeal**.
   - Ditambahkan konfigurasi signing release otomatis yang membaca `android/key.properties` jika tersedia, dan fallback aman ke debug keys untuk pengujian lokal.
2. **iOS (`ios/Runner/Info.plist`):**
   - `CFBundleDisplayName` diubah menjadi `NutriMeal`.
   - `CFBundleName` diubah menjadi `NutriMeal`.
   - Deskripsi izin kamera, galeri foto, dan lokasi telah dilengkapi dalam Bahasa Indonesia.
3. **Web (`web/index.html` & `web/manifest.json`):**
   - Judul aplikasi diubah menjadi `NutriMeal - Katering Sehat & AI Planner`.
   - Nama dan deskripsi PWA disesuaikan dengan tema `#16A34A` dan latar `#F8FAFC`.
4. **Pubspec (`pubspec.yaml`):**
   - Versi diperbarui menjadi `1.0.0+1`.
   - Deskripsi aplikasi diperbarui.
5. **Keamanan Repository (`.gitignore` & `key.properties.example`):**
   - Ditambahkan aturan ignore ketat untuk `android/key.properties`, `*.jks`, dan `*.keystore`.
   - Dibuat file template panduan `android/key.properties.example`.

### F. Otomatisasi CI / CD (`.github/workflows/flutter_ci.yml`)
- Dibuat file workflow GitHub Actions yang memvalidasi `pub get`, `dart format`, `flutter analyze`, `flutter test`, dan `flutter build apk --release` secara otomatis di setiap Pull Request atau Push.

---

## 📋 3. Langkah Manual yang Wajib Dilakukan Pengguna Sebelum Rilis

Berikut adalah langkah-langkah yang memerlukan kredensial/akun resmi pemilik aplikasi:

### Langkah 1: Pembuatan Keystore Rilis Produksi Android
Jalankan perintah berikut di PowerShell atau Terminal:
```bash
keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
*Simpan password yang Anda masukkan baik-baik dan jangan sampai hilang!*

### Langkah 2: Mengisi `android/key.properties`
Salin template konfigurasi:
```powershell
Copy-Item android/key.properties.example android/key.properties
```
Buka file `android/key.properties` lalu isi dengan kredensial yang dibuat pada Langkah 1:
```properties
storePassword=PASSWORD_KEYSTORE_ANDA
keyPassword=PASSWORD_KEY_ANDA
keyAlias=upload
storeFile=upload-keystore.jks
```

### Langkah 3: Menghubungkan Firebase Cloud Messaging (FCM)
Aplikasi sudah memiliki dependency dan kode penanganan notifikasi Firebase (`firebase_messaging`):
1. Buka [Firebase Console](https://console.firebase.google.com/).
2. Buat proyek atau pilih proyek NutriMeal.
3. Daftarkan aplikasi Android dengan Package Name: `com.nutrimeal.app`.
4. Unduh file `google-services.json` dan letakkan di `android/app/google-services.json`.
5. *(Untuk iOS)* Daftarkan Bundle ID `com.nutrimeal.app` dan letakkan `GoogleService-Info.plist` di `ios/Runner/`.

### Langkah 4: Melakukan Build Release Final untuk Play Store
Untuk mengunggah ke Google Play Console, gunakan format **Android App Bundle (.aab)**:
```bash
flutter build appbundle --release --dart-define=API_URL=https://api.nutrimeal.app
```
File hasil build akan berada di:
`build/app/outputs/bundle/release/app-release.aab`

Untuk menguji langsung di ponsel Android fisik:
```bash
flutter build apk --release --dart-define=API_URL=https://api.nutrimeal.app
```
File APK berada di:
`build/app/outputs/flutter-apk/app-release.apk`

---

## ⚠️ 4. Risiko & Keputusan Desain yang Perlu Diputuskan

1. **URL API Produksi:**
   - **Rekomendasi:** Selalu sertakan `--dart-define=API_URL=https://domain-anda.com` saat proses build release di pipeline CI/CD atau terminal rilis.
   - **Alasan:** Ini memastikan aplikasi tidak pernah bergantung pada IP lokal laptop pengembang saat digunakan oleh pelanggan umum.

2. **Mode HTTP Cleartext pada Android:**
   - Di `android/app/src/main/AndroidManifest.xml`, atribut `android:usesCleartextTraffic="true"` masih diaktifkan agar mempermudah pengujian backend di jaringan WiFi lokal (HTTP).
   - **Saran Produksi:** Begitu backend Express/Node.js dipasang SSL/HTTPS (misalnya menggunakan Cloudflare atau Let's Encrypt), ubah `android:usesCleartextTraffic` menjadi `"false"` untuk memenuhi standar keamanan tertinggi Google Play.

3. **Ikon Peluncur Aplikasi (Launcher Icon):**
   - File icon saat ini menggunakan aset resolusi tinggi default. Jika ingin memperbarui logo app secara serentak ke semua resolusi (Android mipmap mdpi-xxxhdpi dan iOS), Anda dapat menjalankan package `flutter_launcher_icons` dengan aset logo persegi 1024x1024.

---

> Dokumen ini disusun secara otomatis oleh Senior Flutter Engineering Agent sebagai bagian dari Tahap 4 Kesiapan Deploy Produksi NutriMeal.
