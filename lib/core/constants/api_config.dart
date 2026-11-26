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
  static const String hostLanIp = '172.16.3.77';

  /// URL Produksi Backend (bisa disetel via build flag: --dart-define=API_URL=https://api.domain.com)
  static const String productionApiUrl = String.fromEnvironment('API_URL');

  /// Mendeteksi base URL backend secara dinamis
  static String get baseUrl {
    if (productionApiUrl.isNotEmpty) {
      return productionApiUrl.replaceAll(RegExp(r'/api/?$'), '');
    }

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
  static String get aiPlannerUrl => '$baseUrl/api/ai-planner/generate';

  static List<String> _buildCandidates(String path) {
    if (productionApiUrl.isNotEmpty) {
      final cleanBase = productionApiUrl.replaceAll(RegExp(r'/api/?$'), '');
      return [
        '$cleanBase$path',
        'http://$hostLanIp:5000$path',
        'http://localhost:5000$path',
      ];
    }
    if (kIsWeb) {
      return ['http://localhost:5000$path'];
    }
    try {
      if (Platform.isAndroid) {
        return [
          'http://$hostLanIp:5000$path',
          'http://localhost:5000$path',
          'http://10.0.2.2:5000$path',
        ];
      }
    } catch (_) {}
    return [
      'http://localhost:5000$path',
      'http://$hostLanIp:5000$path',
      'http://10.0.2.2:5000$path',
    ];
  }

  /// Daftar URL alternatif backend untuk AI Planner
  static List<String> get candidateAiPlannerUrls =>
      _buildCandidates('/api/ai-planner/generate');

  /// Daftar URL alternatif backend untuk Update FCM Token
  static List<String> get candidateFcmTokenUrls =>
      _buildCandidates('/api/customers/fcm-token');

  /// Daftar URL alternatif backend untuk Notifikasi
  static List<String> get candidateNotificationUrls =>
      _buildCandidates('/api/notifications');

  /// Daftar URL alternatif backend untuk Customer Register (mobile)
  static List<String> get candidateRegisterUrls =>
      _buildCandidates('/api/auth/customer-register');

  /// Daftar URL alternatif backend untuk Google Auth
  /// (Mengatasi perbedaan Emulator vs HP Fisik USB / Wi-Fi)
  static List<String> get candidateGoogleAuthUrls =>
      _buildCandidates('/api/auth/google');

  /// Daftar URL alternatif backend untuk Login (email+password)
  static List<String> get candidateLoginUrls =>
      _buildCandidates('/api/auth/login');

  /// Daftar URL alternatif backend untuk Meals (Menu Makanan)
  static List<String> get candidateMealsUrls => _buildCandidates('/api/meals');

  /// Daftar URL alternatif backend untuk Customer API (/api/customers)
  static List<String> get candidateCustomerUrls =>
      _buildCandidates('/api/customers');

  /// Daftar URL alternatif backend untuk Upload File Gambar (/api/upload)
  static List<String> get candidateUploadUrls =>
      _buildCandidates('/api/upload');

  /// Daftar URL alternatif backend untuk Sesi Customer (/api/auth/customer-me)
  static List<String> get candidateCustomerMeUrls =>
      _buildCandidates('/api/auth/customer-me');

  /// Daftar URL alternatif backend untuk Packages (/api/packages)
  static List<String> get candidatePackagesUrls =>
      _buildCandidates('/api/packages');

  /// Daftar URL alternatif backend untuk Subscriptions (/api/subscriptions)
  static List<String> get candidateSubscriptionsUrls =>
      _buildCandidates('/api/subscriptions');

  /// Daftar URL alternatif backend untuk Orders (/api/orders)
  static List<String> get candidateOrdersUrls =>
      _buildCandidates('/api/orders');

  /// Daftar URL alternatif backend untuk Vouchers (/api/vouchers)
  static List<String> get candidateVouchersUrls =>
      _buildCandidates('/api/vouchers');

  /// Daftar URL alternatif backend untuk FAQs (/api/faqs)
  static List<String> get candidateFaqsUrls => _buildCandidates('/api/faqs');

  /// Daftar URL alternatif backend untuk Percakapan Chat (/api/chat/conversations)
  static List<String> get candidateChatConversationsUrls =>
      _buildCandidates('/api/chat/conversations');

  /// Daftar URL alternatif backend untuk Kirim Pesan Chat (/api/chat/messages)
  static List<String> get candidateChatMessagesUrls =>
      _buildCandidates('/api/chat/messages');

  /// Endpoint pembayaran QRIS berbasis single baseUrl (tanpa fallback ke LAN/localhost lain)
  static String get paymentQuoteUrl => '$baseUrl/api/payments/quote';
  static String get paymentCreateQrisUrl => '$baseUrl/api/payments/qris';
  static String get paymentActiveUrl => '$baseUrl/api/payments/active';
  static String paymentStatusUrl(String paymentId) =>
      '$baseUrl/api/payments/${Uri.encodeComponent(paymentId)}';
  static String paymentCancelUrl(String paymentId) =>
      '$baseUrl/api/payments/${Uri.encodeComponent(paymentId)}/cancel';

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
