import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/constants/api_config.dart';
import 'notification_service.dart';

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  // Helper GET dengan fallback candidate URLs
  Future<Map<String, dynamic>?> _get(
    List<String> candidateUrls, {
    Map<String, String>? queryParams,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    for (final baseStr in candidateUrls) {
      try {
        final uri = Uri.parse(baseStr).replace(
          queryParameters: queryParams?.isNotEmpty == true ? queryParams : null,
        );
        final response = await http.get(uri).timeout(timeout);
        if (response.statusCode >= 200 && response.statusCode < 300) {
          final data = jsonDecode(response.body);
          if (data is Map<String, dynamic>) {
            return data;
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[ApiService] GET error on $baseStr: $e');
        }
      }
    }
    return null;
  }

  // Helper POST dengan fallback candidate URLs
  Future<Map<String, dynamic>?> _post(
    List<String> candidateUrls,
    Map<String, dynamic> body, {
    String subPath = '',
    Duration timeout = const Duration(seconds: 8),
  }) async {
    final bodyJson = jsonEncode(body);
    for (final baseStr in candidateUrls) {
      try {
        final url = Uri.parse('$baseStr$subPath');
        final response = await http
            .post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: bodyJson,
            )
            .timeout(timeout);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final data = jsonDecode(response.body);
          if (data is Map<String, dynamic>) {
            return data;
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[ApiService] POST error on $baseStr: $e');
        }
      }
    }
    return null;
  }

  // Helper PATCH dengan fallback candidate URLs
  Future<Map<String, dynamic>?> _patch(
    List<String> candidateUrls,
    String subPath,
    Map<String, dynamic> body, {
    Duration timeout = const Duration(seconds: 8),
  }) async {
    final bodyJson = jsonEncode(body);
    for (final baseStr in candidateUrls) {
      try {
        final url = Uri.parse('$baseStr$subPath');
        final response = await http
            .patch(
              url,
              headers: {'Content-Type': 'application/json'},
              body: bodyJson,
            )
            .timeout(timeout);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final data = jsonDecode(response.body);
          if (data is Map<String, dynamic>) {
            return data;
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[ApiService] PATCH error on $baseStr: $e');
        }
      }
    }
    return null;
  }

  // ===========================================================================
  // 1. PACKAGES (Paket Langganan)
  // ===========================================================================
  Future<List<Map<String, dynamic>>> fetchPackages() async {
    final res = await _get(ApiConfig.candidatePackagesUrls);
    if (res != null && res['data'] is List) {
      return (res['data'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }

  // ===========================================================================
  // 2. SUBSCRIPTIONS (Langganan Saya)
  // ===========================================================================
  Future<List<Map<String, dynamic>>> fetchSubscriptions(String? customerId) async {
    final query = customerId != null && customerId.isNotEmpty
        ? {'customer_id': customerId}
        : null;
    final res = await _get(ApiConfig.candidateSubscriptionsUrls, queryParams: query);
    if (res != null && res['data'] is List) {
      return (res['data'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<bool> updateSubscriptionStatus(
    String subId, {
    String? status,
    String? pauseReason,
    bool? autoRenew,
  }) async {
    final body = <String, dynamic>{};
    if (status != null) body['status'] = status;
    if (pauseReason != null) body['pause_reason'] = pauseReason;
    if (autoRenew != null) body['auto_renew'] = autoRenew ? 1 : 0;

    final res = await _patch(
      ApiConfig.candidateSubscriptionsUrls,
      '/$subId/status',
      body,
    );
    return res != null && res['success'] == true;
  }

  Future<Map<String, dynamic>?> createSubscription(Map<String, dynamic> data) async {
    return await _post(ApiConfig.candidateSubscriptionsUrls, data);
  }

  // ===========================================================================
  // 3. ORDERS (Pesanan & Checkout)
  // ===========================================================================
  Future<Map<String, dynamic>?> createOrder(Map<String, dynamic> orderData) async {
    return await _post(ApiConfig.candidateOrdersUrls, orderData);
  }

  Future<List<Map<String, dynamic>>> fetchOrders({
    String? search,
    String? status,
    String? customerId,
  }) async {
    final query = <String, String>{};
    if (search != null && search.isNotEmpty) query['search'] = search;
    if (status != null && status.isNotEmpty) query['status'] = status;
    if (customerId != null && customerId.isNotEmpty) {
      query['customer_id'] = customerId;
    }

    final res = await _get(ApiConfig.candidateOrdersUrls, queryParams: query);
    if (res != null && res['data'] is List) {
      return (res['data'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }

  // ===========================================================================
  // 4. VOUCHERS (Promo & Diskon)
  // ===========================================================================
  Future<List<Map<String, dynamic>>> fetchVouchers() async {
    final res = await _get(ApiConfig.candidateVouchersUrls);
    if (res != null && res['data'] is List) {
      return (res['data'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<Map<String, dynamic>?> getVoucherByCode(String code) async {
    for (final baseStr in ApiConfig.candidateVouchersUrls) {
      try {
        final url = Uri.parse('$baseStr/code/${Uri.encodeComponent(code.trim())}');
        final response = await http.get(url).timeout(const Duration(seconds: 4));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data is Map<String, dynamic> && data['data'] != null) {
            return data['data'] as Map<String, dynamic>;
          }
        }
      } catch (_) {}
    }
    return null;
  }

  // ===========================================================================
  // 5. FAQS (Pusat Bantuan)
  // ===========================================================================
  Future<List<Map<String, dynamic>>> fetchFaqs() async {
    final res = await _get(ApiConfig.candidateFaqsUrls);
    if (res != null && res['data'] is List) {
      return (res['data'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }

  // ===========================================================================
  // 6. NOTIFICATIONS (Pusat Notifikasi)
  // ===========================================================================
  Future<List<Map<String, dynamic>>> fetchNotifications(String customerId) async {
    final localList = NotificationService.instance.inMemoryNotifications;
    final res = await _get(
      ApiConfig.candidateNotificationUrls,
      queryParams: {'customerId': customerId},
    );
    if (res != null && res['data'] is List) {
      final serverList = (res['data'] as List).cast<Map<String, dynamic>>();
      // Gabungkan server list dengan local in-memory yang belum ada di server
      final Set<String> existingIds = serverList.map((e) => e['id'].toString()).toSet();
      final combined = <Map<String, dynamic>>[...serverList];
      for (final loc in localList) {
        if (!existingIds.contains(loc['id'].toString())) {
          combined.insert(0, loc);
        }
      }
      return combined;
    }
    return List<Map<String, dynamic>>.from(localList);
  }

  Future<bool> markNotificationAsRead(int notifId, String customerId) async {
    final res = await _patch(
      ApiConfig.candidateNotificationUrls,
      '/$notifId/read',
      {'customerId': customerId},
    );
    return res != null && res['success'] == true;
  }

  Future<bool> markAllNotificationsAsRead(String customerId) async {
    final res = await _patch(
      ApiConfig.candidateNotificationUrls,
      '/read-all',
      {'customerId': customerId},
    );
    return res != null && res['success'] == true;
  }
}
