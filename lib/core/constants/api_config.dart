import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class ApiConfig {
  /// Google OAuth Client IDs resmi dari Google Cloud Console
  static const String webClientId =
      '326249737628-v0qtts2k6an7pgap2r6qo70bk0n3r81j.apps.googleusercontent.com';
  static const String androidClientId =
      '326249737628-2glmsskab2ds7pe1p4f76hff1sp45vh3.apps.googleusercontent.com';

  /// IP Wi-Fi komputer host saat ini — sesuaikan dengan IP lokal laptop/PC
  /// Ganti ini dengan IP Wi-Fi laptop/PC Anda jika menggunakan HP fisik
  static const String hostLanIp = '10.200.117.9';

  /// Mendeteksi base URL backend secara dinamis
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000';
    }

    try {
      if (Platform.isAndroid) {
        // Untuk perangkat mobile (HP fisik via Wi-Fi), gunakan IP LAN host
        return 'http://$hostLanIp:5000';
      }
    } catch (_) {}

    return 'http://localhost:5000';
  }

  static String get googleAuthUrl => '$baseUrl/api/auth/google';
  static String get loginUrl => '$baseUrl/api/auth/login';
  static String get customerRegisterUrl =>
      '$baseUrl/api/auth/customer-register';
  static String get customerMeUrl => '$baseUrl/api/auth/customer-me';

  /// Daftar URL alternatif backend untuk Customer Register (mobile)
  static List<String> get candidateRegisterUrls => [
    'http://localhost:5000/api/auth/customer-register',
    'http://$hostLanIp:5000/api/auth/customer-register',
    'http://10.0.2.2:5000/api/auth/customer-register',
  ];

  /// Daftar URL alternatif backend untuk Google Auth
  /// (Mengatasi perbedaan Emulator vs HP Fisik USB / Wi-Fi)
  static List<String> get candidateGoogleAuthUrls => [
    'http://localhost:5000/api/auth/google',
    'http://$hostLanIp:5000/api/auth/google',
    'http://10.0.2.2:5000/api/auth/google',
  ];

  /// Daftar URL alternatif backend untuk Login (email+password)
  static List<String> get candidateLoginUrls => [
    'http://localhost:5000/api/auth/login',
    'http://$hostLanIp:5000/api/auth/login',
    'http://10.0.2.2:5000/api/auth/login',
  ];

  /// Daftar URL alternatif backend untuk Meals (Menu Makanan)
  static List<String> get candidateMealsUrls => [
    'http://localhost:5000/api/meals',
    'http://$hostLanIp:5000/api/meals',
    'http://10.0.2.2:5000/api/meals',
  ];

  /// Mengubah path gambar relatif (seperti /uploads/...) menjadi URL HTTP lengkap
  static String resolveImageUrl(String? rawUrl, {String? activeBaseUrl}) {
    if (rawUrl == null || rawUrl.trim().isEmpty) {
      return 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=800&auto=format&fit=crop';
    }
    final trimmed = rawUrl.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    final base =
        activeBaseUrl ??
        (kIsWeb ? 'http://localhost:5000' : 'http://$hostLanIp:5000');
    final cleanPath = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return '$base$cleanPath';
  }
}
