import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/constants/api_config.dart';
import '../data/models/qris_payment.dart';

class PaymentApiException implements Exception {
  final int? statusCode;
  final String? errorCode;
  final String message;
  final QrisPayment? payment;

  const PaymentApiException({
    this.statusCode,
    this.errorCode,
    required this.message,
    this.payment,
  });

  bool get isUnauthorized => statusCode == 401;
  bool get isConflict => statusCode == 409;
  bool get isTimeout => statusCode == 408;
  bool get isProcessing => errorCode == 'PAYMENT_PROCESSING';
  bool get isIdempotencyMismatch => errorCode == 'IDEMPOTENCY_MISMATCH';
  bool get isClosed => errorCode == 'PAYMENT_CLOSED';

  @override
  String toString() => message;
}

class PaymentService {
  final http.Client _client;
  final Duration timeout;

  PaymentService({
    http.Client? client,
    this.timeout = const Duration(seconds: 15),
  }) : _client = client ?? http.Client();

  Map<String, String> _headers(String authToken) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $authToken',
  };

  Future<PaymentQuote> fetchQuote({
    required String authToken,
    List<Map<String, dynamic>>? items,
    String? packageId,
    String? voucherCode,
  }) async {
    final body = <String, dynamic>{
      if (items != null && items.isNotEmpty) 'items': items,
      if (packageId != null && packageId.isNotEmpty) 'package_id': packageId,
      if (voucherCode != null && voucherCode.trim().isNotEmpty)
        'voucher_code': voucherCode.trim(),
    };

    final json = await _sendJson(
      method: 'POST',
      url: ApiConfig.paymentQuoteUrl,
      authToken: authToken,
      body: body,
    );
    final data = json['data'];
    if (data is! Map) {
      throw const PaymentApiException(
        message: 'Format ringkasan harga dari server tidak valid.',
      );
    }
    return PaymentQuote.fromJson(Map<String, dynamic>.from(data));
  }

  Future<QrisPayment> createQris({
    required String authToken,
    required String idempotencyKey,
    List<Map<String, dynamic>>? items,
    String? packageId,
    String? voucherCode,
    String? customerName,
    required String customerPhone,
    required String customerAddress,
    String? addressDetail,
    String? deliverySchedule,
    String? deliveryBatch,
    String? day,
    String? courierNotes,
    String? kitchenNotes,
    String? cartSignature,
  }) async {
    final body = <String, dynamic>{
      'idempotency_key': idempotencyKey,
      if (items != null && items.isNotEmpty) 'items': items,
      if (packageId != null && packageId.isNotEmpty) 'package_id': packageId,
      if (voucherCode != null && voucherCode.trim().isNotEmpty)
        'voucher_code': voucherCode.trim(),
      if (customerName != null && customerName.trim().isNotEmpty)
        'customer_name': customerName.trim(),
      'customer_phone': customerPhone.trim(),
      'customer_address': customerAddress.trim(),
      if (addressDetail != null && addressDetail.trim().isNotEmpty)
        'address_detail': addressDetail.trim(),
      if (deliverySchedule != null && deliverySchedule.trim().isNotEmpty)
        'delivery_schedule': deliverySchedule.trim(),
      if (deliveryBatch != null && deliveryBatch.trim().isNotEmpty)
        'delivery_batch': deliveryBatch.trim(),
      if (day != null && day.trim().isNotEmpty) 'day': day.trim(),
      if (courierNotes != null && courierNotes.trim().isNotEmpty)
        'courier_notes': courierNotes.trim(),
      if (kitchenNotes != null && kitchenNotes.trim().isNotEmpty)
        'kitchen_notes': kitchenNotes.trim(),
      if (cartSignature != null && cartSignature.trim().isNotEmpty)
        'cart_signature': cartSignature.trim(),
    };

    final json = await _sendJson(
      method: 'POST',
      url: ApiConfig.paymentCreateQrisUrl,
      authToken: authToken,
      body: body,
    );
    final data = json['data'];
    if (data is! Map) {
      throw const PaymentApiException(
        message: 'Data QRIS dari server tidak lengkap.',
      );
    }
    return QrisPayment.fromJson(Map<String, dynamic>.from(data));
  }

  Future<QrisPayment?> getActivePayment({required String authToken}) async {
    final json = await _sendJson(
      method: 'GET',
      url: ApiConfig.paymentActiveUrl,
      authToken: authToken,
    );
    final data = json['data'];
    if (data == null) return null;
    if (data is! Map) return null;
    return QrisPayment.fromJson(Map<String, dynamic>.from(data));
  }

  Future<QrisPayment> getPaymentStatus({
    required String authToken,
    required String paymentId,
  }) async {
    final json = await _sendJson(
      method: 'GET',
      url: ApiConfig.paymentStatusUrl(paymentId),
      authToken: authToken,
    );
    final data = json['data'];
    if (data is! Map) {
      throw const PaymentApiException(
        message: 'Data status pembayaran tidak ditemukan.',
      );
    }
    return QrisPayment.fromJson(Map<String, dynamic>.from(data));
  }

  Future<QrisPayment> cancelPayment({
    required String authToken,
    required String paymentId,
  }) async {
    final json = await _sendJson(
      method: 'POST',
      url: ApiConfig.paymentCancelUrl(paymentId),
      authToken: authToken,
      body: const {},
    );
    final data = json['data'];
    if (data is! Map) {
      throw const PaymentApiException(
        message: 'Respons pembatalan pembayaran tidak valid.',
      );
    }
    return QrisPayment.fromJson(Map<String, dynamic>.from(data));
  }

  Future<Map<String, dynamic>> _sendJson({
    required String method,
    required String url,
    required String authToken,
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse(url);
    late http.Response response;

    try {
      if (method == 'POST') {
        response = await _client
            .post(
              uri,
              headers: _headers(authToken),
              body: jsonEncode(body ?? const {}),
            )
            .timeout(timeout);
      } else {
        response = await _client
            .get(uri, headers: _headers(authToken))
            .timeout(timeout);
      }
    } on TimeoutException {
      throw const PaymentApiException(
        statusCode: 408,
        message:
            'Waktu koneksi habis saat menghubungi server pembayaran. Coba lagi.',
      );
    } on SocketException {
      throw const PaymentApiException(
        message:
            'Tidak dapat terhubung ke server pembayaran. Periksa koneksi Anda.',
      );
    } catch (e) {
      throw PaymentApiException(
        message: 'Terjadi gangguan jaringan saat menghubungi server: $e',
      );
    }

    Map<String, dynamic> decoded = const {};
    if (response.body.isNotEmpty) {
      try {
        final raw = jsonDecode(response.body);
        if (raw is Map<String, dynamic>) {
          decoded = raw;
        }
      } catch (_) {
        throw PaymentApiException(
          statusCode: response.statusCode,
          message: 'Respons server pembayaran tidak dapat dibaca.',
        );
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    final rawData = decoded['data'];
    final parsedPayment = rawData is Map
        ? QrisPayment.fromJson(Map<String, dynamic>.from(rawData))
        : null;

    final serverErrorCode = decoded['code']?.toString();
    final serverMessage = decoded['message']?.toString();
    final fallbackMessage = response.statusCode == 401
        ? 'Sesi login berakhir atau belum terautentikasi. Silakan login kembali.'
        : 'Gagal memproses pembayaran (${response.statusCode}).';

    throw PaymentApiException(
      statusCode: response.statusCode,
      errorCode: serverErrorCode,
      message: (serverMessage != null && serverMessage.trim().isNotEmpty)
          ? serverMessage
          : fallbackMessage,
      payment: parsedPayment,
    );
  }
}
