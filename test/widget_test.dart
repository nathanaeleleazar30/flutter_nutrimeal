import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:frontend_nutrimeal/controllers/auth_controller.dart';
import 'package:frontend_nutrimeal/screens/login_screen.dart';
import 'package:frontend_nutrimeal/screens/register_screen.dart';
import 'package:frontend_nutrimeal/screens/forgot_password_screen.dart';
import 'package:frontend_nutrimeal/screens/verify_email_screen.dart';
import 'package:frontend_nutrimeal/widgets/custom_button.dart';
import 'package:frontend_nutrimeal/widgets/google_sign_in_button.dart';

void main() {
  testWidgets('Renders LoginScreen with all form fields and exact screenshot titles', (WidgetTester tester) async {
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
    expect(find.text('Masukkan Email'), findsOneWidget);

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

  testWidgets('Renders ForgotPasswordScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthController(),
        child: const MaterialApp(home: ForgotPasswordScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text('KIRIM'), findsOneWidget);
  });

  testWidgets('Renders VerifyEmailScreen with 4 OTP boxes and confirmation button', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: VerifyEmailScreen(email: 'test@student.ub.ac.id')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Periksa Email Anda'), findsOneWidget);
    expect(find.text('test@student.ub.ac.id'), findsOneWidget);
    expect(find.text('KONFIRMASI'), findsOneWidget);
  });
}
