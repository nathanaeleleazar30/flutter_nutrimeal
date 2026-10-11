# Panduan Testing Flutter Mobile App dengan Backend NutriMeal

## Status Koneksi Terkini

✅ **Backend Express**: Berjalan di `http://localhost:5000`
✅ **Frontend Admin**: Berjalan di `http://localhost:3000`
✅ **Database MySQL**: Schema sudah memiliki kolom `google_id` di tabel customers
✅ **Google OAuth**: Client ID sudah dikonfigurasi di backend dan Flutter

## Langkah 1: Siapkan Backend

Pastikan backend berjalan di terminal:
```bash
cd backend
npm run dev
```

Jika port 5000 sudah digunakan, matikan proses yang menggunakan port tersebut:
```bash
# Windows
taskkill /PID [PID] /F
# Ganti [PID] dengan PID dari netstat -ano | findstr :5000
```

## Langkah 2: Update IP Wi-Fi untuk Flutter

Jika menggunakan **HP Fisik (Real Device)**:

1. Cari IP Wi-Fi laptop/PC Anda:
   ```bash
   # Windows Command Prompt
   ipconfig
   # Cari IPv4 Address, contoh: 192.168.1.100
   ```

2. Edit file `lib/core/constants/api_config.dart`:
   ```dart
   static const String hostLanIp = '192.168.1.100'; // Ganti dengan IP Anda
   ```

3. Pastikan HP dan laptop terhubung ke jaringan Wi-Fi yang sama

Jika menggunakan **Emulator Android**:
- Tidak perlu mengubah konfigurasi (sudah otomatis menggunakan `10.0.2.2`)

## Langkah 3: Jalankan Flutter App

```bash
cd ../frontend-nutrimeal
flutter run
```

Pilih device yang tersedia (emulator atau HP fisik).

## Langkah 4: Testing Google Sign-In

### Test 1: Login dengan Email & Password
1. Buka aplikasi Flutter
2. Masukkan email dan password customer yang terdaftar di database
3. Klik tombol "MASUK"
4. Harus berhasil login dan diarahkan ke halaman home

### Test 2: Google Sign-In (Customer Baru)
1. Klik tombol Google Sign-In
2. Pilih akun Google yang belum terdaftar di database
3. Backend akan otomatis membuat customer baru
4. User akan diarahkan ke halaman home

### Test 3: Google Sign-In (Customer Lama)
1. Logout dari aplikasi
2. Login kembali dengan Google Sign-In menggunakan akun yang sama
3. Backend akan mengambil data customer yang sudah ada
4. User akan diarahkan ke halaman home

## Verifikasi Database

Setelah testing, cek database untuk memastikan data customer tersimpan:

```sql
-- Cek semua customers
SELECT id, name, email, google_id, avatar_url, phone FROM customers;

-- Cek customer yang login via Google
SELECT * FROM customers WHERE google_id IS NOT NULL;
```

## Troubleshooting

### Error: "Tidak dapat terhubung ke server"
- Pastikan backend berjalan di port 5000
- Jika menggunakan HP fisik, pastikan IP Wi-Fi di `api_config.dart` benar
- Coba ping IP laptop dari HP untuk memastikan koneksi jaringan
- Pastikan firewall Windows mengizinkan koneksi di port 5000

### Error: "Google idToken tidak valid"
- Pastikan Google Client ID di `api_config.dart` cocok dengan Google Cloud Console
- Pastikan SHA-1 fingerprint sudah ditambahkan di Google Cloud Console untuk Android
- Cek bahwa aplikasi Android menggunakan package name yang benar

### Error: "Popup Google diblokir"
- Pastikan popup tidak diblokir oleh browser (untuk web admin)
- Untuk mobile, pastikan Google Play Services terinstall dan terupdate

### CORS Error
- Pastikan `FRONTEND_URL` di backend `.env` sudah benar
- Untuk mobile, pastikan CORS di backend mengizinkan origin dari mobile app

## Log Debugging

Aktifkan debug logging di Flutter untuk melihat detail request:

```dart
// Di auth_controller.dart, pastikan kDebugMode aktif
if (kDebugMode) print('[NutriMeal Auth] Login ke: $url');
```

Cek console Flutter untuk melihat:
- URL yang diakses
- Response dari backend
- Error yang terjadi

## Next Steps

Setelah testing berhasil:
1. Update konfigurasi IP Wi-Fi di `api_config.dart` untuk deployment
2. Tambahkan validasi tambahan di backend jika diperlukan
3. Implementasi fitur tambahan seperti logout, update profile, dll.
