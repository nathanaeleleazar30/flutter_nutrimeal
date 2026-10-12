# Konfigurasi Koneksi Backend untuk Flutter Mobile App

## Langkah 1: Konfigurasi Backend (.env)

Pastikan file `backend/.env` memiliki konfigurasi berikut:

```env
PORT=5000
NODE_ENV=development

DB_HOST=localhost
DB_USER=root
DB_PASSWORD=
DB_NAME=nutrimeal_db
DB_PORT=3306

FRONTEND_URL=http://localhost:3000

GOOGLE_CLIENT_ID=326249737628-v0qtts2k6an7pgap2r6qo70bk0n3r81j.apps.googleusercontent.com
GOOGLE_ANDROID_CLIENT_ID=326249737628-2glmsskab2ds7pe1p4f76hff1sp45vh3.apps.googleusercontent.com
```

## Langkah 2: Konfigurasi Frontend Admin (.env.local)

Pastikan file `frontend/.env.local` memiliki konfigurasi berikut:

```env
NEXT_PUBLIC_API_URL=http://localhost:5000/api
API_URL=http://localhost:5000/api
NEXT_PUBLIC_GOOGLE_CLIENT_ID=326249737628-v0qtts2k6an7pgap2r6qo70bk0n3r81j.apps.googleusercontent.com
```

## Langkah 3: Konfigurasi Flutter Mobile App (api_config.dart)

Edit file `lib/core/constants/api_config.dart` sesuai dengan perangkat yang digunakan:

### Jika menggunakan Emulator Android:
```dart
static const String hostLanIp = '10.0.2.2'; // Sudah otomatis terdeteksi
```

### Jika menggunakan HP Fisik (Real Device):
1. Cari IP Wi-Fi laptop/PC Anda:
   - Windows: Buka Command Prompt dan ketik `ipconfig`
   - Mac/Linux: Buka Terminal dan ketik `ifconfig` atau `ip a`
2. Copy IPv4 Address (contoh: `192.168.1.100`)
3. Update file `lib/core/constants/api_config.dart`:
```dart
static const String hostLanIp = '192.168.1.100'; // Ganti dengan IP Wi-Fi Anda
```

## Langkah 4: Pastikan Backend Berjalan

Jalankan backend di terminal:
```bash
cd backend
npm run dev
```

Backend akan berjalan di `http://localhost:5000`

## Langkah 5: Pastikan Frontend Admin Berjalan

Jalankan frontend admin di terminal baru:
```bash
cd frontend
npm run dev
```

Frontend admin akan berjalan di `http://localhost:3000`

## Langkah 6: Jalankan Flutter Mobile App

Jalankan Flutter app:
```bash
cd ../frontend-nutrimeal
flutter run
```

## Testing Google Sign-In

### Backend & Frontend Admin:
1. Buka `http://localhost:3000/admin/login`
2. Klik "Masuk dengan Akun Google"
3. Masuk dengan akun Google yang emailnya terdaftar di database admins
4. Atau akun Google baru akan otomatis dibuat sebagai admin

### Flutter Mobile App:
1. Buka aplikasi Flutter
2. Klik tombol Google Sign-In
3. Pilih akun Google
4. Backend akan memverifikasi token dan membuat/mengambil customer data
5. User akan diarahkan ke halaman home

## Troubleshooting

### Backend tidak dapat dijangkau dari Flutter:
- Pastikan backend berjalan di port 5000
- Pastikan firewall Windows mengizinkan koneksi di port 5000
- Jika menggunakan HP fisik, pastikan HP dan laptop di jaringan Wi-Fi yang sama
- Coba ping IP laptop dari HP untuk memastikan koneksi

### Google Sign-In gagal:
- Pastikan Google Client ID di backend dan Flutter cocok
- Pastikan Google Sign-In sudah dikonfigurasi di Google Cloud Console
- Pastikan SHA-1 fingerprint sudah ditambahkan di Google Cloud Console untuk Android

### CORS Error:
- Pastikan `FRONTEND_URL` di backend `.env` sudah benar
- Pastikan CORS configuration di `backend/server.js` mengizinkan origin yang diperlukan
