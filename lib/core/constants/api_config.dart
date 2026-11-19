import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class ApiConfig {
  /// Google OAuth Client IDs resmi dari Google Cloud Console
  static const String webClientId =
      '692683965471-fhlmrbkuf99b6mo2gh366vv18g50tpc2.apps.googleusercontent.com';
  static const String androidClientId =
      '326249737628-2glmsskab2ds7pe1p4f76hff1sp45vh3.apps.googleusercontent.com';

  /// IP Wi-Fi komputer host saat ini — sesuaikan dengan IP lokal laptop/PC
  /// Ganti ini dengan IP Wi-Fi laptop/PC Anda jika menggunakan HP fisik
  static const String hostLanIp = '192.168.1.31';

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
  static String get customerFcmTokenUrl => '$baseUrl/api/customers/fcm-token';
  static String get notificationsUrl => '$baseUrl/api/notifications';

  /// Daftar URL alternatif backend untuk Update FCM Token
  static List<String> get candidateFcmTokenUrls => [
    'http://localhost:5000/api/customers/fcm-token',
    'http://$hostLanIp:5000/api/customers/fcm-token',
    'http://10.0.2.2:5000/api/customers/fcm-token',
  ];

  /// Daftar URL alternatif backend untuk Notifikasi
  static List<String> get candidateNotificationUrls => [
    'http://localhost:5000/api/notifications',
    'http://$hostLanIp:5000/api/notifications',
    'http://10.0.2.2:5000/api/notifications',
  ];

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

  /// Daftar URL alternatif backend untuk Customer API (/api/customers)
  static List<String> get candidateCustomerUrls => [
    'http://localhost:5000/api/customers',
    'http://$hostLanIp:5000/api/customers',
    'http://10.0.2.2:5000/api/customers',
  ];

  /// Daftar URL alternatif backend untuk Upload File Gambar (/api/upload)
  static List<String> get candidateUploadUrls => [
    'http://localhost:5000/api/upload',
    'http://$hostLanIp:5000/api/upload',
    'http://10.0.2.2:5000/api/upload',
  ];

  /// Daftar URL alternatif backend untuk Sesi Customer (/api/auth/customer-me)
  static List<String> get candidateCustomerMeUrls => [
    'http://localhost:5000/api/auth/customer-me',
    'http://$hostLanIp:5000/api/auth/customer-me',
    'http://10.0.2.2:5000/api/auth/customer-me',
  ];

  /// Daftar URL alternatif backend untuk Packages (/api/packages)
  static List<String> get candidatePackagesUrls => [
    'http://localhost:5000/api/packages',
    'http://$hostLanIp:5000/api/packages',
    'http://10.0.2.2:5000/api/packages',
  ];

  /// Daftar URL alternatif backend untuk Subscriptions (/api/subscriptions)
  static List<String> get candidateSubscriptionsUrls => [
    'http://localhost:5000/api/subscriptions',
    'http://$hostLanIp:5000/api/subscriptions',
    'http://10.0.2.2:5000/api/subscriptions',
  ];

  /// Daftar URL alternatif backend untuk Orders (/api/orders)
  static List<String> get candidateOrdersUrls => [
    'http://localhost:5000/api/orders',
    'http://$hostLanIp:5000/api/orders',
    'http://10.0.2.2:5000/api/orders',
  ];

  /// Daftar URL alternatif backend untuk Vouchers (/api/vouchers)
  static List<String> get candidateVouchersUrls => [
    'http://localhost:5000/api/vouchers',
    'http://$hostLanIp:5000/api/vouchers',
    'http://10.0.2.2:5000/api/vouchers',
  ];

  /// Daftar URL alternatif backend untuk FAQs (/api/faqs)
  static List<String> get candidateFaqsUrls => [
    'http://localhost:5000/api/faqs',
    'http://$hostLanIp:5000/api/faqs',
    'http://10.0.2.2:5000/api/faqs',
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
    final base = activeBaseUrl ?? baseUrl;
    final cleanPath = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return '$base$cleanPath';
  }
}
