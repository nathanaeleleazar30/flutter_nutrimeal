import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:frontend_nutrimeal/controllers/auth_controller.dart';
import 'package:frontend_nutrimeal/controllers/menu_controller.dart';
import 'package:frontend_nutrimeal/core/widgets/center_feedback_toast.dart';
import 'package:frontend_nutrimeal/data/models/qris_payment.dart';
import 'package:frontend_nutrimeal/screens/beranda_screen.dart';
import 'package:frontend_nutrimeal/screens/galeri_menu_screen.dart';
import 'package:frontend_nutrimeal/screens/login_screen.dart';
import 'package:frontend_nutrimeal/screens/menu_detail_screen.dart';
import 'package:frontend_nutrimeal/screens/register_screen.dart';
import 'package:frontend_nutrimeal/screens/forgot_password_screen.dart';
import 'package:frontend_nutrimeal/screens/verify_email_screen.dart';
import 'package:frontend_nutrimeal/screens/keranjang_screen.dart';
import 'package:frontend_nutrimeal/screens/checkout_screen.dart';
import 'package:frontend_nutrimeal/screens/address_screen.dart';
import 'package:frontend_nutrimeal/screens/jadwal_screen.dart';
import 'package:frontend_nutrimeal/screens/admin_chat_screen.dart';
import 'package:frontend_nutrimeal/screens/profile_screen.dart';
import 'package:frontend_nutrimeal/screens/profile_detail_screen.dart';
import 'package:frontend_nutrimeal/screens/notifikasi_screen.dart';
import 'package:frontend_nutrimeal/screens/bantuan_faq_screen.dart';
import 'package:frontend_nutrimeal/screens/langganan_saya_screen.dart';
import 'package:frontend_nutrimeal/screens/langganan_katalog_screen.dart';
import 'package:frontend_nutrimeal/widgets/custom_button.dart';
import 'package:frontend_nutrimeal/widgets/google_sign_in_button.dart';

// Mock HttpOverrides untuk Image.network dalam pengujian widget
class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return MockHttpClient();
  }
}

class MockHttpClient extends Fake implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => MockHttpClientRequest();
}

class MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  HttpHeaders get headers => MockHttpHeaders();
  @override
  Future<HttpClientResponse> close() async => MockHttpClientResponse();
}

class MockHttpHeaders extends Fake implements HttpHeaders {}

class MockHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;
  @override
  int get contentLength => kTransparentImage.length;
  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;
  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    void Function()? onDone,
    Function? onError,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([kTransparentImage]).listen(
      onData,
      onDone: onDone,
      onError: onError,
      cancelOnError: cancelOnError,
    );
  }
}

final Uint8List kTransparentImage = Uint8List.fromList(<int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);

class _TestAuthController extends AuthController {
  final bool authenticated;
  _TestAuthController({required this.authenticated});

  @override
  Future<void> restoreSession() async {}

  @override
  bool get isLoggedIn => authenticated;

  @override
  String? get authToken => authenticated ? 'test-jwt-token' : null;

  @override
  String? get customerId => authenticated ? 'cst-test-01' : null;
}

Widget createTestApp(
  Widget child, {
  NutriMealMenuController? menuController,
  AuthController? authController,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthController>.value(
        value: authController ?? AuthController(),
      ),
      ChangeNotifierProvider<NutriMealMenuController>.value(
        value: menuController ?? NutriMealMenuController(),
      ),
    ],
    child: MaterialApp(
      home: child,
      routes: {
        '/home': (_) => const Scaffold(body: Text('Home Screen')),
        '/login': (_) => const Scaffold(body: Text('Login Screen')),
      },
    ),
  );
}

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  testWidgets('1. Renders LoginScreen with fields, logo, and actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestApp(const LoginScreen()));
    await tester.pumpAndSettle();

    expect(
      find.text('Nikmati Lezatnya Hidangan,\nSehatnya Nutrisi'),
      findsOneWidget,
    );
    expect(find.text('EMAIL'), findsOneWidget);
    expect(find.text('PASSWORD'), findsOneWidget);
    expect(find.byType(CustomButton), findsOneWidget);
    expect(find.text('MASUK'), findsOneWidget);
    expect(find.text('Lupa Password?'), findsOneWidget);
    expect(find.byType(GoogleSignInButton), findsOneWidget);
  });

  testWidgets('2. Renders RegisterScreen with complete form fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestApp(const RegisterScreen()));
    await tester.pumpAndSettle();

    expect(
      find.text('Mulai Perjalanan Sehatmu\nBersama NutriMeal'),
      findsOneWidget,
    );
    expect(find.text('NAMA LENGKAP'), findsOneWidget);
    expect(find.text('NOMOR WHATSAPP'), findsOneWidget);
    expect(find.text('KONFIRMASI PASSWORD'), findsOneWidget);
    expect(find.text('Daftar'), findsOneWidget);
  });

  testWidgets('3. Renders ForgotPasswordScreen and VerifyEmailScreen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestApp(const ForgotPasswordScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text('KIRIM'), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: VerifyEmailScreen(email: 'test@student.ub.ac.id'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Periksa Email Anda'), findsOneWidget);
    expect(find.text('test@student.ub.ac.id'), findsOneWidget);
    expect(find.text('KONFIRMASI'), findsOneWidget);
  });

  testWidgets('4. Renders BerandaScreen with catering banner and categories', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestApp(const BerandaScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Langganan Katering Sehat'), findsOneWidget);
    expect(find.text('HEMAT S.D 25%'), findsOneWidget);
    expect(find.text('Ikan'), findsOneWidget);
    expect(find.text('Daging'), findsOneWidget);
    expect(find.text('Seafood'), findsOneWidget);
    expect(find.text('Jadwal Katering'), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);
  });

  testWidgets('5. Renders GaleriMenuScreen and MenuDetailScreen', (
    WidgetTester tester,
  ) async {
    final menuController = NutriMealMenuController();

    await tester.pumpWidget(
      createTestApp(const GaleriMenuScreen(), menuController: menuController),
    );
    await tester.pumpAndSettle();

    expect(find.text('Galeri Menu'), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('Ayam'), findsOneWidget);

    // Test Menu Detail Screen
    await tester.pumpWidget(
      createTestApp(
        MenuDetailScreen(item: menuController.allMenuItems[0]),
        menuController: menuController,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Details'), findsOneWidget);
    expect(find.text('GRILLED CHICKEN'), findsOneWidget);
    expect(find.text('Nutritional Information'), findsOneWidget);
    expect(find.text('Masukkan Keranjang'), findsOneWidget);
  });

  testWidgets('6. Renders KeranjangScreen with order summary and actions', (
    WidgetTester tester,
  ) async {
    final menuController = NutriMealMenuController();
    menuController.addToCart(menuController.allMenuItems[0]);

    await tester.pumpWidget(
      createTestApp(const KeranjangScreen(), menuController: menuController),
    );
    await tester.pumpAndSettle();

    expect(find.text('Keranjang Saya'), findsOneWidget);
    expect(find.text('Lanjut ke Pembayaran'), findsOneWidget);

    // Verify Empty Cart state
    menuController.clearCart();
    await tester.pumpWidget(
      createTestApp(const KeranjangScreen(), menuController: menuController),
    );
    await tester.pumpAndSettle();

    expect(find.text('Keranjang Belanja Masih Kosong'), findsOneWidget);
    expect(find.text('Eksplor Menu Sehat'), findsOneWidget);
  });

  testWidgets('7. Renders CheckoutScreen with QRIS & Payment Instructions', (
    WidgetTester tester,
  ) async {
    final menuController = NutriMealMenuController();
    final now = DateTime.now().toUtc();
    final pendingPayment = QrisPayment(
      paymentId: 'PAY-TEST-1',
      orderId: 'ORD-TEST-1',
      providerOrderId: 'NUTRI-ORD-TEST-1-001',
      amount: 115000,
      subtotal: 100000,
      tax: 5000,
      shippingFee: 10000,
      discount: 0,
      isSubscription: false,
      packageName: 'Grilled Chicken Rice Bowl',
      qrString: '00020101021226580014ID.CO.GOPAY.WWW0118936009140000000000',
      expiresAt: now.add(const Duration(minutes: 15)),
      serverTime: now,
      receivedAt: now,
      status: 'pending',
      paymentStatus: 'Menunggu Pembayaran',
    );

    await tester.pumpWidget(
      createTestApp(
        CheckoutScreen(existingPayment: pendingPayment),
        menuController: menuController,
        authController: _TestAuthController(authenticated: true),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Pembayaran QRIS'), findsOneWidget);
    expect(find.text('Menunggu Pembayaran'), findsOneWidget);
    expect(find.text('Petunjuk Pembayaran QRIS'), findsOneWidget);
    expect(find.text('Refresh Status'), findsOneWidget);
    expect(find.text('Bayar nanti'), findsOneWidget);
    expect(find.text('Batalkan QRIS'), findsOneWidget);
  });

  testWidgets('7b. Unauthenticated CheckoutScreen prompts Login Diperlukan', (
    WidgetTester tester,
  ) async {
    final menuController = NutriMealMenuController();
    await tester.pumpWidget(
      createTestApp(
        const CheckoutScreen(),
        menuController: menuController,
        authController: _TestAuthController(authenticated: false),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Login Diperlukan'), findsOneWidget);
    expect(find.text('Login Sekarang'), findsOneWidget);
  });

  testWidgets('8. Renders AddressScreen with address list', (
    WidgetTester tester,
  ) async {
    final menuController = NutriMealMenuController();

    await tester.pumpWidget(
      createTestApp(const AddressScreen(), menuController: menuController),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pilih Alamat Pengiriman'), findsOneWidget);
    expect(find.text('Tambah Alamat Baru'), findsOneWidget);
    expect(find.text('Gunakan Alamat Ini'), findsOneWidget);
  });

  testWidgets('9. Renders JadwalScreen with calendar days and meals', (
    WidgetTester tester,
  ) async {
    final menuController = NutriMealMenuController();

    await tester.pumpWidget(
      createTestApp(const JadwalScreen(), menuController: menuController),
    );
    await tester.pumpAndSettle();

    expect(find.text('Makan Siang'), findsWidgets);
    expect(find.text('Grilled Chicken'), findsWidgets);
  });

  testWidgets('10. Renders AdminChatScreen with search and customer care', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestApp(const AdminChatScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Admin NutriCare'), findsOneWidget);
    expect(find.text('Customer Care & Ahli Gizi • '), findsOneWidget);
    expect(find.text('Tulis pesan ke NutriCare...'), findsOneWidget);
  });

  testWidgets(
    '11. Renders ProfileScreen with member info and navigation list',
    (WidgetTester tester) async {
      final menuController = NutriMealMenuController();

      await tester.pumpWidget(
        createTestApp(const ProfileScreen(), menuController: menuController),
      );
      await tester.pumpAndSettle();

      expect(find.text('Informasi Pribadi'), findsOneWidget);
      expect(find.text('Alamat Pengiriman'), findsOneWidget);
      expect(find.text('Langganan Saya'), findsOneWidget);
      expect(find.text('Notifikasi'), findsOneWidget);
      expect(find.text('Bantuan'), findsOneWidget);
      expect(find.text('Keluar'), findsOneWidget);
      expect(find.text('Versi Aplikasi 2.1.0'), findsOneWidget);
    },
  );

  testWidgets('12. Renders ProfileDetailScreen with nutrition & metrics', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestApp(const ProfileDetailScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Informasi Pribadi'), findsOneWidget);
    expect(find.text('Kelengkapan Data Nutrisi'), findsNothing);
    expect(find.text('Kontak & Akun'), findsOneWidget);
    expect(find.text('Simpan Perubahan'), findsOneWidget);
  });

  testWidgets('13. Renders NotifikasiScreen with tabs and actions', (
    WidgetTester tester,
  ) async {
    final menuController = NutriMealMenuController();

    await tester.pumpWidget(
      createTestApp(const NotifikasiScreen(), menuController: menuController),
    );
    await tester.pumpAndSettle();

    expect(find.text('Notifikasi'), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('Pesanan'), findsOneWidget);
    expect(find.text('Promo & Diskon'), findsOneWidget);
    expect(find.text('Belum Ada Notifikasi'), findsOneWidget);
  });

  testWidgets(
    '14. Renders BantuanFaqScreen with help channels and FAQ questions',
    (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const BantuanFaqScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Saluran Bantuan Cepat'), findsOneWidget);
      expect(find.text('Pertanyaan Sering Diajukan'), findsOneWidget);
    },
  );

  testWidgets('15. Renders LanggananSayaScreen with subscription state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      createTestApp(const LanggananSayaScreen(showBottomNav: false)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Langganan Saya'), findsOneWidget);
  });

  testWidgets(
    '16. Renders LanggananKatalogScreen with packages and bottom CTA',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const LanggananKatalogScreen(showBottomNav: false)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Langganan Katering'), findsOneWidget);
      expect(find.text('Pilih Paket Langganan'), findsOneWidget);
      expect(find.text('Mulai Langganan'), findsOneWidget);
    },
  );

  testWidgets(
    '17. CenterFeedbackToast renders simple white pill, replaces active toast, and auto-dismisses',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => CenterFeedbackToast.showSuccess(
                  context,
                  message: '1 x Grilled Chicken masuk keranjang',
                ),
                child: const Text('Trigger Toast'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Trigger Toast'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('1 x Grilled Chicken masuk keranjang'), findsOneWidget);
      expect(find.text('Berhasil!'), findsNothing);

      final container = tester.widget<Container>(
        find
            .ancestor(
              of: find.text('1 x Grilled Chicken masuk keranjang'),
              matching: find.byType(Container),
            )
            .first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(
        decoration.color?.toARGB32(),
        Colors.white.withValues(alpha: 0.92).toARGB32(),
      );

      // Trigger again to verify single-toast replacement without stacking
      await tester.tap(find.text('Trigger Toast'), warnIfMissed: false);
      await tester.pump();
      expect(find.text('1 x Grilled Chicken masuk keranjang'), findsOneWidget);

      // Advance past display + fadeOut duration to verify clean dismissal
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pumpAndSettle();

      expect(find.text('1 x Grilled Chicken masuk keranjang'), findsNothing);
    },
  );
}
