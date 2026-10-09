import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:frontend_nutrimeal/controllers/auth_controller.dart';
import 'package:frontend_nutrimeal/controllers/menu_controller.dart';
import 'package:frontend_nutrimeal/screens/beranda_screen.dart';
import 'package:frontend_nutrimeal/screens/galeri_menu_screen.dart';
import 'package:frontend_nutrimeal/screens/login_screen.dart';
import 'package:frontend_nutrimeal/screens/menu_detail_screen.dart';
import 'package:frontend_nutrimeal/screens/register_screen.dart';
import 'package:frontend_nutrimeal/screens/forgot_password_screen.dart';
import 'package:frontend_nutrimeal/screens/verify_email_screen.dart';
import 'package:frontend_nutrimeal/widgets/custom_button.dart';
import 'package:frontend_nutrimeal/widgets/google_sign_in_button.dart';

// Mock HttpOverrides for Image.network in widget tests
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
  StreamSubscription<List<int>> listen(void Function(List<int>)? onData,
      {void Function()? onDone, Function? onError, bool? cancelOnError}) {
    return Stream<List<int>>.fromIterable([kTransparentImage]).listen(
      onData,
      onDone: onDone,
      onError: onError,
      cancelOnError: cancelOnError,
    );
  }
}

final Uint8List kTransparentImage = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
  0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
  0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
  0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D,
  0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
  0x60, 0x82,
]);

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  testWidgets('Renders LoginScreen with dummy data and elements', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthController(),
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title from Screenshot
    expect(find.text('Nikmati Lezatnya Hidangan,\nSehatnya Nutrisi'), findsOneWidget);

    // Verify Fields
    expect(find.text('EMAIL'), findsOneWidget);
    expect(find.text('PASSWORD'), findsOneWidget);

    // Verify Links & Buttons
    expect(find.textContaining('Daftar disini'), findsOneWidget);
    expect(find.byType(CustomButton), findsOneWidget);
    expect(find.text('MASUK'), findsOneWidget);
    expect(find.text('Lupa Password?'), findsOneWidget);
    expect(find.text('Atau masuk dengan'), findsOneWidget);
    expect(find.byType(GoogleSignInButton), findsOneWidget);
  });

  testWidgets('Renders RegisterScreen with fields and logo', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthController(),
        child: const MaterialApp(home: RegisterScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mulai Perjalanan Sehatmu\nBersama NutriMeal'), findsOneWidget);
    expect(find.text('NAMA LENGKAP'), findsOneWidget);
    expect(find.text('NOMOR WHATSAPP'), findsOneWidget);
    expect(find.text('KONFIRMASI PASSWORD'), findsOneWidget);
    expect(find.text('Daftar'), findsOneWidget);
  });

  testWidgets('Renders ForgotPasswordScreen and VerifyEmailScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthController(),
        child: const MaterialApp(home: ForgotPasswordScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text('KIRIM'), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(home: VerifyEmailScreen(email: 'test@student.ub.ac.id')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Periksa Email Anda'), findsOneWidget);
    expect(find.text('test@student.ub.ac.id'), findsOneWidget);
    expect(find.text('KONFIRMASI'), findsOneWidget);
  });

  testWidgets('Renders BerandaScreen with catering and popular items', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthController()),
          ChangeNotifierProvider(create: (_) => NutriMealMenuController()),
        ],
        child: const MaterialApp(home: BerandaScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('LOKASI PENGANTARAN'), findsOneWidget);
    expect(find.text('Lowokwaru, Malang'), findsOneWidget);
    expect(find.text('NutriBot AI'), findsOneWidget);
    expect(find.text('Jadwal Katering'), findsOneWidget);
    expect(find.text('Menu Populer Hari Ini'), findsOneWidget);
    expect(find.text('Chicken Katsu Bowl'), findsOneWidget);
  });

  testWidgets('Renders GaleriMenuScreen and MenuDetailScreen', (WidgetTester tester) async {
    final menuController = NutriMealMenuController();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthController()),
          ChangeNotifierProvider.value(value: menuController),
        ],
        child: const MaterialApp(home: GaleriMenuScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Galeri Menu'), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('Ayam'), findsOneWidget);

    // Test Menu Detail Screen
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: menuController),
        ],
        child: MaterialApp(
          home: MenuDetailScreen(item: menuController.allMenuItems[0]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Details'), findsOneWidget);
    expect(find.text('GRILLED CHICKEN'), findsOneWidget);
    expect(find.text('Nutritional Information'), findsOneWidget);
    expect(find.text('Masukkan Keranjang'), findsOneWidget);
  });
}
