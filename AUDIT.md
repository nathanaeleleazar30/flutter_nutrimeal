# 🛡️ LAPORAN AUDIT KESIAPAN PRODUKSI & DEPLOYMENT — NUTRIMEAL

Dokumen ini disusun oleh Senior Flutter Engineer untuk mengaudit proyek **NutriMeal (Flutter Mobile Application)** secara menyeluruh sebelum dirilis ke lingkungan *production* (Google Play Store & deployment rilis).

---

## 📌 RANGKUMAN AUDIT

- **Nama Aplikasi**: NutriMeal (Catering Sehat & AI Meal Planner)
- **Framework & SDK**: Flutter (SDK ^3.12.1 / Dart ^3.12)
- **Target Platform**: Android (utama), iOS, Web
- **State Management**: `Provider` (`ChangeNotifierProvider` untuk `AuthController` dan `NutriMealMenuController`)
- **Penyimpanan Lokal**:
  - `Drift` (SQLite) untuk cache offline menu makanan (`MealRepository`).
  - `SharedPreferences` untuk preferensi pengguna & filter non-sensitif.
  - `FlutterSecureStorage` untuk token autentikasi & kredensial sesi.
- **Hasil Diagnostik Awal**:
  - `flutter pub get`: ✅ Sukses tanpa konflik dependensi.
  - `flutter analyze`: ✅ Bersih (0 errors, 0 warnings).
  - `flutter test (Unit Test Drift & Storage)`: ✅ 6/6 Lulus.
  - `flutter test (Widget Tests)`: ❌ 16 tes gagal karena widget test menguji ekspektasi UI lama sebelum pembaruan fitur.
  - `dart format`: 55 file membutuhkan standardisasi format Dart.

---

## 🚨 1. TEMUAN KRITIS (Bikin Crash / Gagal Deploy Play Store)

Temuan pada kelompok ini **wajib diperbaiki** sebelum melakukan `flutter build apk --release` atau *upload* ke Google Play Console:

| No | Masalah | Lokasi File | Dampak |
|:--:|:---|:---|:---|
| **K-01** | **Application ID Masih Menggunakan Prefix Default `com.example`** | `android/app/build.gradle.kts` (L20) | **DITOLAK PLAY STORE.** Google Play Console secara otomatis menolak berkas AAB/APK dengan ID yang diawali `com.example`. |
| **K-02** | **Label Aplikasi di Launcher Android Masih `frontend_nutrimeal`** | `android/app/src/main/AndroidManifest.xml` (L18) | Nama aplikasi di layar beranda HP pengguna tampil kaku sebagai `frontend_nutrimeal`, bukan nama merek `NutriMeal`. |
| **K-03** | **Signing Config Release Masih Menggunakan Debug Keystore** | `android/app/build.gradle.kts` (L33) | `signingConfig = signingConfigs.getByName("debug")`. APK release tidak terverifikasi resmi oleh sertifikat pengembang pribadi. |
| **K-04** | **Hardcoded IP LAN Wi-Fi pada Endpoint API** | `lib/core/constants/api_config.dart` (L13, L24) | `hostLanIp = '10.255.191.102'`. Aplikasi akan gagal menghubungi server jika HP berpindah Wi-Fi atau jika aplikasi di-install di luar jaringan lokal developer. |
| **K-05** | **Widget Tests Mengalami 16 Kegagalan (Failing Tests)** | `test/widget_test.dart` | Otomasi CI/CD dan proses build akan gagal jika pipeline memvalidasi `flutter test`. |
| **K-06** | **File `google-services.json` Belum Disediakan** | `android/app/google-services.json` | Fitur Push Notification latar belakang (Firebase Cloud Messaging saat app tertutup) tidak dapat berfungsi tanpa registrasi Firebase Android. |

---

## ⚠️ 2. TEMUAN PENTING (Fungsi Tidak Sempurna / Risiko UX & Keamanan)

Temuan pada kelompok ini mempengaruhi keandalan fungsional, integritas sesi, dan pengalaman pengguna:

| No | Masalah | Lokasi File | Dampak |
|:--:|:---|:---|:---|
| **P-01** | **Splash Screen Selalu Memaksa Navigasi ke Layar Login** | `lib/screens/auth/splash_screen.dart` (L27, L41) | Meskipun pengguna sudah login dan token tersimpan di Secure Storage, pengguna selalu dilempar ke login setiap kali membuka aplikasi. |
| **P-02** | **Ukuran File Ikon Launcher Tidak Standar (527 KB per Mipmap)** | `android/app/src/main/res/mipmap-*/ic_launcher.png` | Gambar logo mentah 527 KB disalin ke semua folder mipmap tanpa penyesuaian resolusi (48px, 72px, 96px, 144px, 192px), memperlambat waktu start OS. |
| **P-03** | **Belum Mendukung Adaptive Icon Android (Android 8.0+)** | `android/app/src/main/res/` | Tidak ada `ic_launcher_round.png` atau XML adaptive icon, sehingga logo aplikasi bisa terpotong aneh di HP Samsung, Pixel, atau Xiaomi. |
| **P-04** | **Display Name & Bundle Name di iOS Masih Default** | `ios/Runner/Info.plist` (L18, L26) | `CFBundleDisplayName` dan `CFBundleName` masih tertulis `Frontend Nutrimeal`. |
| **P-05** | **Title & Metadata Web Masih Boilerplate** | `web/index.html` (L26, L32) & `web/manifest.json` (L2, L8) | Berisi teks default Flutter `"A new Flutter project"` dan tema warna biru `#0175C2`. |
| **P-06** | **Cleartext HTTP Traffic Aktif Secara Global di Android** | `android/app/src/main/AndroidManifest.xml` (L21) | `android:usesCleartextTraffic="true"` mengizinkan transmisi data HTTP tanpa enkripsi, yang tidak disarankan untuk aplikasi produksi modern (wajib HTTPS). |
| **P-07** | **In-Memory Fallback Belum Rata di Seluruh Model Backend** | `admin-nutrimeal/backend/src/model/` (`mealModel.js`, `orderModel.js`, `customerModel.js`) | Jika koneksi MySQL terputus sementara di server, beberapa endpoint masih dapat melempar 500 error ke aplikasi mobile. |

---

## 💡 3. PENINGKATAN (Kualitas Kode, UI/UX, Performa, & Aksesibilitas)

Penyempurnaan non-blokir untuk mencapai standar aplikasi *production-grade*:

| No | Peningkatan | Lokasi File | Manfaat |
|:--:|:---|:---|:---|
| **N-01** | **Dukungan Build Flag `--dart-define=API_URL`** | `lib/core/constants/api_config.dart` | Memungkinkan pengembang melakukan build untuk staging/production (`https://api.nutrimeal.com`) tanpa mengubah kode sumber. |
| **N-02** | **Pengaturan `key.properties.example` & `.gitignore` Keystore** | `android/` | Mencegah kebocoran file sertifikat *keystore* dan *password* rahasia ke repository publik/GitHub. |
| **N-03** | **Standardisasi Format Dart (`dart format`)** | Seluruh file di `lib/` dan `test/` | Menjaga konsistensi gaya kode, spasi, dan baris sesuai standar resmi tim Flutter. |
| **N-04** | **Pembaruan Unit Test & Widget Test Mutakhir** | `test/widget_test.dart` | Memastikan seluruh alur layar utama (Beranda, Menu, Langganan, Chat Admin, Checkout) teruji secara otomatis dan lulus 100%. |
| **N-05** | **Dokumentasi Setup & Panduan Deployment** | `README.md` & `DEPLOY_CHECKLIST.md` | Memberikan panduan langkah-demi-langkah bagi pengembang/tim rilis untuk membuat keystore, build APK/AAB, dan rilis ke Play Store. |

---

## 🎯 RENCANA AKSI PERBAIKAN BERTAHAP
1. **Langkah 1**: Memperbaiki `widget_test.dart` dan memastikan seluruh pengujian otomatis lulus (`flutter test` 100% PASS).
2. **Langkah 2**: Memperbaiki konfigurasi identitas Android & iOS (Application ID, App Label, Adaptive Icons, dan konfigurasi rilis).
3. **Langkah 3**: Menyempurnakan alur sesi Splash Screen (redirect otomatis ke `/home` jika sesi aktif).
4. **Langkah 4**: Menyediakan template rilis `key.properties.example`, update `.gitignore`, dan dokumentasi deployment.
5. **Langkah 5**: Menjalankan build rilis `flutter build apk --release` dan memverifikasi keberhasilan akhir.
