class PaymentQuoteItem {
  final String mealId;
  final String name;
  final String? imageUrl;
  final int qty;
  final int unitPrice;
  final int lineTotal;

  const PaymentQuoteItem({
    required this.mealId,
    required this.name,
    this.imageUrl,
    required this.qty,
    required this.unitPrice,
    required this.lineTotal,
  });

  factory PaymentQuoteItem.fromJson(Map<String, dynamic> json) {
    final qty = _parseInt(json['qty'], fallback: 1);
    final unitPrice = _parseInt(json['unit_price']);
    return PaymentQuoteItem(
      mealId: (json['meal_id'] ?? '').toString(),
      name: (json['name'] ?? json['meal_name'] ?? 'Menu NutriMeal').toString(),
      imageUrl: json['image_url']?.toString(),
      qty: qty,
      unitPrice: unitPrice,
      lineTotal: _parseInt(json['line_total'], fallback: unitPrice * qty),
    );
  }
}

class PaymentQuote {
  final bool isSubscription;
  final String packageName;
  final String? packageDetail;
  final int subtotal;
  final int tax;
  final int shippingFee;
  final int discount;
  final int total;
  final String? voucherCode;
  final List<PaymentQuoteItem> items;

  const PaymentQuote({
    required this.isSubscription,
    required this.packageName,
    this.packageDetail,
    required this.subtotal,
    required this.tax,
    required this.shippingFee,
    required this.discount,
    required this.total,
    this.voucherCode,
    this.items = const [],
  });

  factory PaymentQuote.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final parsedItems = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map(
                (item) =>
                    PaymentQuoteItem.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList()
        : const <PaymentQuoteItem>[];

    return PaymentQuote(
      isSubscription:
          json['is_subscription'] == true || json['is_subscription'] == 1,
      packageName: (json['package_name'] ?? 'Pesanan NutriMeal').toString(),
      packageDetail: json['package_detail']?.toString(),
      subtotal: _parseInt(json['subtotal']),
      tax: _parseInt(json['tax']),
      shippingFee: _parseInt(json['shipping_fee']),
      discount: _parseInt(json['discount']),
      total: _parseInt(json['total']),
      voucherCode: json['voucher_code']?.toString(),
      items: parsedItems,
    );
  }
}

class QrisPayment {
  final String paymentId;
  final String orderId;
  final String providerOrderId;
  final String? transactionId;
  final int amount;
  final int subtotal;
  final int tax;
  final int shippingFee;
  final int discount;
  final String? voucherCode;
  final bool isSubscription;
  final String? packageName;
  final String? packageDetail;
  final String? firstMealName;
  final String? firstMealImage;
  final String? customerAddress;
  final String? deliveryTime;
  final List<PaymentQuoteItem> items;
  final String? qrString;
  final String? qrUrl;
  final String? cartSignature;
  final DateTime expiresAt;
  final DateTime? paidAt;
  final DateTime serverTime;
  final DateTime receivedAt;
  final String status;
  final String paymentStatus;

  const QrisPayment({
    required this.paymentId,
    required this.orderId,
    required this.providerOrderId,
    this.transactionId,
    required this.amount,
    required this.subtotal,
    required this.tax,
    required this.shippingFee,
    required this.discount,
    this.voucherCode,
    required this.isSubscription,
    this.packageName,
    this.packageDetail,
    this.firstMealName,
    this.firstMealImage,
    this.customerAddress,
    this.deliveryTime,
    this.items = const [],
    this.qrString,
    this.qrUrl,
    this.cartSignature,
    required this.expiresAt,
    this.paidAt,
    required this.serverTime,
    required this.receivedAt,
    required this.status,
    required this.paymentStatus,
  });

  factory QrisPayment.fromJson(Map<String, dynamic> json, {DateTime? now}) {
    final received = (now ?? DateTime.now()).toUtc();
    final parsedServerTime = _parseDateTime(json['server_time']) ?? received;
    final parsedExpiresAt =
        _parseDateTime(json['expires_at']) ??
        parsedServerTime.add(const Duration(minutes: 15));

    final rawItems = json['items'];
    final parsedItems = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map(
                (item) =>
                    PaymentQuoteItem.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList()
        : const <PaymentQuoteItem>[];

    return QrisPayment(
      paymentId: (json['payment_id'] ?? json['id'] ?? '').toString(),
      orderId: (json['order_id'] ?? '').toString(),
      providerOrderId: (json['provider_order_id'] ?? '').toString(),
      transactionId: json['transaction_id']?.toString(),
      amount: _parseInt(json['amount']),
      subtotal: _parseInt(json['subtotal']),
      tax: _parseInt(json['tax']),
      shippingFee: _parseInt(json['shipping_fee']),
      discount: _parseInt(json['discount']),
      voucherCode: json['voucher_code']?.toString(),
      isSubscription:
          json['is_subscription'] == true || json['is_subscription'] == 1,
      packageName: json['package_name']?.toString(),
      packageDetail: json['package_detail']?.toString(),
      firstMealName: json['first_meal_name']?.toString(),
      firstMealImage: json['first_meal_image']?.toString(),
      customerAddress: json['customer_address']?.toString(),
      deliveryTime: json['delivery_time']?.toString(),
      items: parsedItems,
      qrString: json['qr_string']?.toString(),
      qrUrl: json['qr_url']?.toString(),
      cartSignature: json['cart_signature']?.toString(),
      expiresAt: parsedExpiresAt,
      paidAt: _parseDateTime(json['paid_at']),
      serverTime: parsedServerTime,
      receivedAt: received,
      status: (json['status'] ?? 'pending').toString(),
      paymentStatus: (json['payment_status'] ?? 'Menunggu Pembayaran')
          .toString(),
    );
  }

  bool get isPending => status == 'pending';
  bool get isPaid => status == 'paid' || paymentStatus == 'Lunas';
  bool get isCancelled =>
      status == 'cancelled' || paymentStatus == 'Dibatalkan';
  bool get isExpiredStatus =>
      status == 'expired' || paymentStatus == 'Kedaluwarsa';
  bool get isFailed => status == 'failed';

  /// Menghitung sisa waktu berbasis jam server agar kebal terhadap deviasi jam HP.
  Duration remainingTime({DateTime? now}) {
    if (!isPending) return Duration.zero;
    final clientNow = (now ?? DateTime.now()).toUtc();
    final elapsedSinceFetch = clientNow.difference(receivedAt);
    final initialRemaining = expiresAt.difference(serverTime);
    final remaining = initialRemaining - elapsedSinceFetch;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  bool isTimedOut({DateTime? now}) => remainingTime(now: now) <= Duration.zero;

  String get displaySummaryTitle {
    if (firstMealName != null && firstMealName!.trim().isNotEmpty) {
      if (items.length > 1) {
        return '$firstMealName (+${items.length - 1} menu)';
      }
      return firstMealName!;
    }
    if (packageName != null && packageName!.trim().isNotEmpty) {
      return packageName!;
    }
    return 'Pesanan NutriMeal';
  }
}

int _parseInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.round();
  if (value is String) {
    final parsed = double.tryParse(value.trim());
    if (parsed != null) return parsed.round();
  }
  return fallback;
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  if (text.isEmpty) return null;
  return DateTime.tryParse(text)?.toUtc();
}
