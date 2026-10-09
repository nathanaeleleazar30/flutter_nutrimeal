import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'controllers/auth_controller.dart';
import 'controllers/menu_controller.dart';
import 'core/constants/app_colors.dart';
import 'screens/address_screen.dart';
import 'screens/admin_chat_screen.dart';
import 'screens/bantuan_faq_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/jadwal_screen.dart';
import 'screens/keranjang_screen.dart';
import 'screens/langganan_katalog_screen.dart';
import 'screens/langganan_saya_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation_shell.dart';
import 'screens/notifikasi_screen.dart';
import 'screens/nutribot_chat_screen.dart';
import 'screens/preview_shell.dart';
import 'screens/profile_detail_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/verify_email_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => NutriMealMenuController()),
      ],
      child: const NutriMealApp(),
    ),
  );
}

class NutriMealApp extends StatelessWidget {
  const NutriMealApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriMeal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.mintBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryGreen,
          primary: AppColors.primaryGreen,
          surface: Colors.white,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/verify-email': (context) => const VerifyEmailScreen(),
        '/home': (context) => const MainNavigationShell(),
        '/menu': (context) => const MainNavigationShell(initialIndex: 1),
        '/chat-ai': (context) => const NutriBotChatScreen(),
        '/chat-admin': (context) => const AdminChatScreen(),
        '/jadwal': (context) => const JadwalScreen(),
        '/cart': (context) => const KeranjangScreen(),
        '/checkout': (context) => const CheckoutScreen(),
        '/address': (context) => const AddressScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/profile-detail': (context) => const ProfileDetailScreen(),
        '/notifikasi': (context) => const NotifikasiScreen(),
        '/bantuan': (context) => const BantuanFaqScreen(),
        '/langganan-saya': (context) => const LanggananSayaScreen(),
        '/langganan-katalog': (context) => const LanggananKatalogScreen(),
        '/preview': (context) => const PreviewShell(),
      },
    );
  }
}
