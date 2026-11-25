import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend_nutrimeal/controllers/auth_controller.dart';
import 'package:frontend_nutrimeal/controllers/menu_controller.dart';
import 'package:frontend_nutrimeal/core/constants/api_config.dart';
import 'package:frontend_nutrimeal/data/local/preferences/preferences_service.dart';
import 'package:frontend_nutrimeal/data/models/qris_payment.dart';
import 'package:frontend_nutrimeal/screens/checkout_screen.dart';
import 'package:frontend_nutrimeal/screens/payment_status_screen.dart';
import 'package:frontend_nutrimeal/services/payment_service.dart';

class _NoNetworkHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    throw const SocketException('Network blocked in widget test');
  }
}

class _StubAuthController extends AuthController {
  @override
  Future<void> restoreSession() async {}

  @override
  bool get isLoggedIn => true;

  @override
  String? get authToken => 'jwt-token-test';

  @override
  String? get customerId => 'cst-1';

  @override
  String? get currentUserName => 'Bintang Test';

  @override
  String? get customerPhone => '081234567890';

  @override
  String? get customerAddress => 'Jl. Soekarno Hatta No. 10, Malang';
}

MenuItem _sampleMeal({String id = 'meal-1', int price = 45000}) {
  return MenuItem(
    id: id,
    name: 'Grilled Chicken Rice Bowl',
    category: 'Tinggi Protein',
    calories: 520,
    price: price,
    imageUrl: '',
    description: 'Ayam panggang rendah lemak',
    tags: const ['High Protein'],
    schedule: 'Setiap Hari',
    deliveryTime: '11:30 - 13:00 WIB',
    nutrition: const NutritionInfo(
      calories: 520,
      protein: '35g',
      fat: '10g',
      carbs: '45g',
    ),
  );
}

Widget _wrapScreen(
  Widget child, {
  required NutriMealMenuController menu,
  required AuthController auth,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthController>.value(value: auth),
      ChangeNotifierProvider<NutriMealMenuController>.value(value: menu),
    ],
    child: MaterialApp(
      home: child,
      routes: {
        '/home': (_) => const Scaffold(body: Text('Home')),
        '/login': (_) => const Scaffold(body: Text('Login')),
        '/address': (_) => const Scaffold(body: Text('Address')),
        '/payment-status': (_) => const PaymentStatusScreen(),
      },
    ),
  );
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _NoNetworkHttpOverrides();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('QrisPayment model & clock skew', () {
    test(
      'calculates remainingTime based on serverTime instead of wrong device clock',
      () {
        final serverNow = DateTime.utc(2026, 11, 25, 10, 0, 0);
        final expiresAt = DateTime.utc(2026, 11, 25, 10, 15, 0);
        final wrongDeviceFetchTime = DateTime.utc(2026, 11, 25, 9, 0, 0);

        final payment = QrisPayment.fromJson({
          'payment_id': 'PAY-1',
          'order_id': 'ORD-1',
          'provider_order_id': 'ORD-1',
          'amount': 115000,
          'status': 'pending',
          'payment_status': 'Menunggu Pembayaran',
          'server_time': serverNow.toIso8601String(),
          'expires_at': expiresAt.toIso8601String(),
          'qr_string': '00020101',
        }, now: wrongDeviceFetchTime);

        final checkTime = wrongDeviceFetchTime.add(const Duration(seconds: 30));
        expect(
          payment.remainingTime(now: checkTime),
          const Duration(minutes: 14, seconds: 30),
        );
        expect(payment.isTimedOut(now: checkTime), isFalse);

        final afterExpiry = wrongDeviceFetchTime.add(
          const Duration(minutes: 16),
        );
        expect(payment.remainingTime(now: afterExpiry), Duration.zero);
        expect(payment.isTimedOut(now: afterExpiry), isTrue);
      },
    );
  });

  group('NutriMealMenuController QRIS rules & UUID persistence', () {
    testWidgets(
      'removes 93000 tax hack, disables non-QRIS, and persists idempotency UUID v4 cleanly',
      (WidgetTester tester) async {
        final controller = NutriMealMenuController();
        controller.addToCart(_sampleMeal(id: 'meal-93', price: 93000));

        expect(controller.subtotal, 93000);
        expect(controller.tax, 4650);

        final nonQris = controller.paymentOptions
            .where((o) => o.id != 'qris')
            .toList();
        expect(nonQris, isNotEmpty);
        for (final opt in nonQris) {
          expect(opt.isEnabled, isFalse);
          expect(opt.badge, 'Segera hadir');
        }
        controller.selectPaymentMethod('bca_va');
        expect(controller.selectedPaymentId, 'qris');

        // Key UUID v4 konsisten untuk isi keranjang & alamat yang sama
        final key1 = await controller.getOrCreateIdempotencyKey(
          customerId: 'cst-1',
          phone: '0812345',
          address: 'Jl. Malang',
        );
        final uuidRegex = RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
          caseSensitive: false,
        );
        expect(uuidRegex.hasMatch(key1), isTrue);

        final keySame = await controller.getOrCreateIdempotencyKey(
          customerId: 'cst-1',
          phone: '0812345',
          address: 'Jl. Malang',
        );
        expect(keySame, key1);

        // Isi berubah -> UUID baru
        controller.addToCart(_sampleMeal(id: 'meal-2', price: 30000));
        final keyChanged = await controller.getOrCreateIdempotencyKey(
          customerId: 'cst-1',
          phone: '0812345',
          address: 'Jl. Malang',
        );
        expect(keyChanged, isNot(key1));

        await controller.clearCheckoutIdempotencyKey();
        final savedAfterClear = await PreferencesService.instance
            .getCheckoutIdempotencyState();
        expect(savedAfterClear, isNull);
      },
    );
  });

  group('PaymentService API contract', () {
    test(
      'uses single baseUrl, Bearer header, and maps 409/422 codes',
      () async {
        late Uri capturedUri;
        late Map<String, String> capturedHeaders;

        final client = MockClient((req) async {
          capturedUri = req.url;
          capturedHeaders = req.headers;
          return http.Response(
            jsonEncode({
              'success': false,
              'code': 'IDEMPOTENCY_MISMATCH',
              'message': 'Isi keranjang berubah untuk key ini',
            }),
            422,
          );
        });

        final service = PaymentService(client: client);
        try {
          await service.createQris(
            authToken: 'secret-jwt',
            idempotencyKey: '550e8400-e29b-41d4-a716-446655440000',
            customerPhone: '081234',
            customerAddress: 'Jl. Malang',
            items: [
              {'meal_id': 'meal-1', 'qty': 1},
            ],
          );
          fail('Seharusnya melempar PaymentApiException 422');
        } on PaymentApiException catch (e) {
          expect(capturedUri.toString(), ApiConfig.paymentCreateQrisUrl);
          expect(capturedHeaders['Authorization'], 'Bearer secret-jwt');
          expect(e.statusCode, 422);
          expect(e.isIdempotencyMismatch, isTrue);
        }
      },
    );
  });

  group('CheckoutScreen auto-create QRIS flow', () {
    testWidgets(
      'auto-creates QRIS -> shows Menunggu Pembayaran -> Refresh Status transitions on paid',
      (WidgetTester tester) async {
        final menu = NutriMealMenuController();
        menu.addToCart(_sampleMeal(id: 'meal-1', price: 45000));
        menu.addSavedAddress(
          const DeliveryAddress(
            id: 'addr-1',
            label: 'Rumah',
            recipientName: 'Bintang',
            phoneNumber: '081234567890',
            area: 'Malang',
            fullAddress: 'Jl. Soekarno Hatta No. 10, Malang',
            deliveryNote: 'Titip satpam',
            addressType: 'Rumah',
            isDefault: true,
          ),
        );

        final now = DateTime.now().toUtc();
        String serverPaymentStatus = 'pending';
        int qrisCreateCalls = 0;

        final mockClient = MockClient((req) async {
          if (req.url.path.endsWith('/api/payments/active')) {
            return http.Response(
              jsonEncode({'success': true, 'data': null}),
              200,
            );
          }
          if (req.url.path.endsWith('/api/payments/qris')) {
            qrisCreateCalls += 1;
            return http.Response(
              jsonEncode({
                'success': true,
                'data': {
                  'payment_id': 'PAY-FLOW-1',
                  'order_id': 'ORD-FLOW-1',
                  'provider_order_id': 'ORD-FLOW-1',
                  'amount': 57250,
                  'subtotal': 45000,
                  'tax': 2250,
                  'shipping_fee': 10000,
                  'discount': 0,
                  'is_subscription': false,
                  'package_name': '1x Grilled Chicken Rice Bowl',
                  'first_meal_name': 'Grilled Chicken Rice Bowl',
                  'customer_address': 'Jl. Soekarno Hatta No. 10, Malang',
                  'delivery_time': '11:30 - 13:00 WIB',
                  'qr_string':
                      '00020101021226580014ID.CO.GOPAY.WWW0118936009140000000000',
                  'expires_at': now
                      .add(const Duration(minutes: 15))
                      .toIso8601String(),
                  'server_time': now.toIso8601String(),
                  'status': 'pending',
                  'payment_status': 'Menunggu Pembayaran',
                },
              }),
              201,
            );
          }
          if (req.url.path.endsWith('/api/payments/PAY-FLOW-1')) {
            return http.Response(
              jsonEncode({
                'success': true,
                'data': {
                  'payment_id': 'PAY-FLOW-1',
                  'order_id': 'ORD-FLOW-1',
                  'provider_order_id': 'ORD-FLOW-1',
                  'amount': 57250,
                  'subtotal': 45000,
                  'tax': 2250,
                  'shipping_fee': 10000,
                  'discount': 0,
                  'is_subscription': false,
                  'package_name': '1x Grilled Chicken Rice Bowl',
                  'first_meal_name': 'Grilled Chicken Rice Bowl',
                  'customer_address': 'Jl. Soekarno Hatta No. 10, Malang',
                  'delivery_time': '11:30 - 13:00 WIB',
                  'qr_string':
                      '00020101021226580014ID.CO.GOPAY.WWW0118936009140000000000',
                  'expires_at': now
                      .add(const Duration(minutes: 15))
                      .toIso8601String(),
                  'server_time': now.toIso8601String(),
                  'status': serverPaymentStatus,
                  'payment_status': serverPaymentStatus == 'paid'
                      ? 'Lunas'
                      : 'Menunggu Pembayaran',
                },
              }),
              200,
            );
          }
          return http.Response('Not found', 404);
        });

        await tester.pumpWidget(
          _wrapScreen(
            CheckoutScreen(paymentService: PaymentService(client: mockClient)),
            menu: menu,
            auth: _StubAuthController(),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        await tester.pump(const Duration(milliseconds: 50));

        // QRIS langsung dibuat tanpa tombol konfirmasi perantara
        expect(qrisCreateCalls, 1);
        expect(find.text('Menunggu Pembayaran'), findsOneWidget);
        expect(find.byType(QrImageView), findsOneWidget);
        expect(find.text('Refresh Status'), findsOneWidget);
        expect(find.text('Rp57.250'), findsWidgets);

        // Refresh saat belum dibayar -> tetap Menunggu Pembayaran & keranjang belum dihapus
        await tester.ensureVisible(find.text('Refresh Status'));
        await tester.tap(find.text('Refresh Status'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        expect(find.byType(PaymentStatusScreen), findsNothing);
        expect(menu.cartItems.length, 1);

        // Simulasikan paid -> Refresh Status pindah ke PaymentStatusScreen & keranjang kosong
        serverPaymentStatus = 'paid';
        await tester.tap(find.text('Refresh Status'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(PaymentStatusScreen), findsOneWidget);
        expect(menu.cartItems, isEmpty);
      },
    );

    testWidgets(
      'cancelling QRIS returns to previous screen and keeps cart intact',
      (WidgetTester tester) async {
        final menu = NutriMealMenuController();
        menu.addToCart(_sampleMeal(id: 'meal-1', price: 45000));
        final now = DateTime.now().toUtc();
        final pending = QrisPayment(
          paymentId: 'PAY-CAN-1',
          orderId: 'ORD-CAN-1',
          providerOrderId: 'ORD-CAN-1',
          amount: 57250,
          subtotal: 45000,
          tax: 2250,
          shippingFee: 10000,
          discount: 0,
          isSubscription: false,
          packageName: '1x Grilled Chicken Rice Bowl',
          qrString: '00020101',
          expiresAt: now.add(const Duration(minutes: 15)),
          serverTime: now,
          receivedAt: now,
          status: 'pending',
          paymentStatus: 'Menunggu Pembayaran',
        );

        final client = MockClient((req) async {
          if (req.url.path.endsWith('/cancel')) {
            return http.Response(
              jsonEncode({
                'success': true,
                'data': {
                  'payment_id': 'PAY-CAN-1',
                  'order_id': 'ORD-CAN-1',
                  'provider_order_id': 'ORD-CAN-1',
                  'amount': 57250,
                  'status': 'cancelled',
                  'payment_status': 'Dibatalkan',
                  'server_time': now.toIso8601String(),
                  'expires_at': now.toIso8601String(),
                },
              }),
              200,
            );
          }
          return http.Response(
            jsonEncode({'success': true, 'data': null}),
            200,
          );
        });

        await tester.pumpWidget(
          _wrapScreen(
            Builder(
              builder: (ctx) => Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      ctx,
                      MaterialPageRoute(
                        builder: (_) => CheckoutScreen(
                          existingPayment: pending,
                          paymentService: PaymentService(client: client),
                        ),
                      ),
                    );
                  },
                  child: const Text('Buka Checkout'),
                ),
              ),
            ),
            menu: menu,
            auth: _StubAuthController(),
          ),
        );

        await tester.tap(find.text('Buka Checkout'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        await tester.pump(const Duration(milliseconds: 50));

        await tester.ensureVisible(find.text('Batalkan QRIS'));
        await tester.tap(find.text('Batalkan QRIS'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        expect(find.text('Batalkan Pembayaran QRIS?'), findsOneWidget);
        expect(find.text('Lanjutkan Pembayaran'), findsOneWidget);
        await tester.tap(find.text('Ya, batalkan'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        // Kembali ke layar sebelumnya & keranjang tetap ada
        expect(find.text('Buka Checkout'), findsOneWidget);
        expect(menu.cartItems.length, 1);
        expect(menu.activePendingPayment, isNull);
      },
    );
  });
}
