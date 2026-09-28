import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_nutrimeal/screens/login_screen.dart';
import 'package:frontend_nutrimeal/widgets/nutri_meal_logo.dart';
import 'package:frontend_nutrimeal/widgets/custom_button.dart';
import 'package:frontend_nutrimeal/widgets/google_sign_in_button.dart';
import 'package:frontend_nutrimeal/main.dart';

void main() {
  testWidgets('Renders SplashScreen with NutriMealLogo', (WidgetTester tester) async {
    await tester.pumpWidget(
      const NutriMealApp(),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NutriMealLogo), findsWidgets);
    expect(find.text('Nutri'), findsWidgets);
    expect(find.text('Meal'), findsWidgets);
  });

  testWidgets('Renders LoginScreen with all form fields and buttons', (WidgetTester tester) async {
    await tester.pumpWidget(
      const TestAppWrapper(child: LoginScreen()),
    );
    await tester.pumpAndSettle();

    // Verify Title
    expect(find.text('Kemewahan Rasa Dalam\nSetiap Asupan Nutrisi'), findsOneWidget);

    // Verify Fields
    expect(find.text('EMAIL'), findsOneWidget);
    expect(find.text('PASSWORD'), findsOneWidget);
    expect(find.text('Masukan email'), findsOneWidget);
    expect(find.text('****'), findsOneWidget);

    // Verify Links & Buttons
    expect(find.textContaining('Daftar disini'), findsOneWidget);
    expect(find.byType(CustomButton), findsOneWidget);
    expect(find.text('MASUK'), findsOneWidget);
    expect(find.text('Lupa Password?'), findsOneWidget);
    expect(find.text('Atau masuk dengan'), findsOneWidget);
    expect(find.byType(GoogleSignInButton), findsOneWidget);
  });
}

class TestAppWrapper extends StatelessWidget {
  final Widget child;

  const TestAppWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: child,
    );
  }
}
