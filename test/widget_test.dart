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
import 'package:frontend_nutrimeal/screens/keranjang_screen.dart';
import 'package:frontend_nutrimeal/screens/checkout_screen.dart';
import 'package:frontend_nutrimeal/screens/address_screen.dart';
import 'package:frontend_nutrimeal/screens/jadwal_screen.dart';
import 'package:frontend_nutrimeal/screens/nutribot_chat_screen.dart';
import 'package:frontend_nutrimeal/screens/admin_chat_screen.dart';
import 'package:frontend_nutrimeal/screens/profile_screen.dart';
import 'package:frontend_nutrimeal/screens/profile_detail_screen.dart';
import 'package:frontend_nutrimeal/screens/notifikasi_screen.dart';
import 'package:frontend_nutrimeal/screens/bantuan_faq_screen.dart';
import 'package:frontend_nutrimeal/screens/langganan_saya_screen.dart';
import 'package:frontend_nutrimeal/screens/langganan_katalog_screen.dart';
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

    expect(find.text('NutriBot AI'), findsOneWidget);
    expect(find.text('Tanya rekomendasi menu & hitung kalori'), findsOneWidget);
    expect(find.text('Ikan'), findsOneWidget);
    expect(find.text('Daging'), findsOneWidget);
    expect(find.text('Seafood'), findsOneWidget);
    expect(find.text('Roti'), findsOneWidget);
    expect(find.text('Jadwal Katering'), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('Chicken Katsu Bowl'), findsOneWidget);
    expect(find.text('480 kkal'), findsOneWidget);
    expect(find.text('Menu Populer Hari Ini'), findsOneWidget);
    expect(find.text('Lihat Semua'), findsOneWidget);
    expect(find.text('Chicken Salad'), findsOneWidget);
    expect(find.text('Beef Veggie'), findsOneWidget);
    expect(find.text('Ayam Bowl'), findsOneWidget);
    expect(find.text('Chicken Wrap'), findsOneWidget);
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

  testWidgets('Renders KeranjangScreen with address, items, and checkout summary', (WidgetTester tester) async {
    final menuController = NutriMealMenuController();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: menuController,
        child: const MaterialApp(home: KeranjangScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title & Header
    expect(find.text('Keranjang Saya'), findsOneWidget);

    // Verify Address section
    expect(find.text('ALAMAT PENGANTARAN'), findsOneWidget);
    expect(find.textContaining('Andi Pratama'), findsOneWidget);
    expect(find.textContaining('812-3456-7890'), findsOneWidget);
    expect(find.text('Ubah'), findsOneWidget);

    // Verify Items from Screenshot
    expect(find.text('Cheesy Chicken'), findsOneWidget);
    expect(find.text('Chicken Kare'), findsOneWidget);
    expect(find.text('Rp 68.000'), findsOneWidget);
    expect(find.text('Rp 25.000'), findsOneWidget);

    // Verify Voucher Banner
    expect(find.text('Ada kode voucher atau promo?'), findsOneWidget);
    expect(find.text('Gunakan'), findsOneWidget);

    // Verify Payment Method
    expect(find.text('METODE PEMBAYARAN'), findsOneWidget);
    expect(find.text('GoPay / NutriPay'), findsOneWidget);
    expect(find.text('Saldo: Rp 245.000'), findsOneWidget);

    // Verify Summary (Exact to screenshot)
    expect(find.text('Total Menu'), findsOneWidget);
    expect(find.text('Rp 93.000'), findsOneWidget);
    expect(find.text('Est. Pajak (PB1)'), findsOneWidget);
    expect(find.text('Rp 4.500'), findsOneWidget);
    expect(find.text('Ongkos Kirim'), findsOneWidget);
    expect(find.text('Promo'), findsOneWidget);
    expect(find.text('Rp 10.000'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('Rp 107.500'), findsOneWidget);

    // Verify Bottom CTA
    expect(find.text('Lanjut ke Pembayaran'), findsOneWidget);

    // Verify Empty Cart state
    menuController.clearCart();
    await tester.pumpAndSettle();

    expect(find.text('Keranjang Belanja Masih Kosong'), findsOneWidget);
    expect(find.text('Eksplor Menu Sehat'), findsOneWidget);
  });

  testWidgets('Renders CheckoutScreen correctly', (WidgetTester tester) async {
    final menuController = NutriMealMenuController();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: menuController,
        child: const MaterialApp(home: CheckoutScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Konfirmasi Pesanan'), findsOneWidget);
    expect(find.text('Jadwal Pengiriman'), findsOneWidget);
    expect(find.text('Hari Ini, 12:00 - 13:00 WIB'), findsOneWidget);
    expect(find.text('Bayar Sekarang'), findsOneWidget);
  });

  testWidgets('Renders AddressScreen correctly', (WidgetTester tester) async {
    final menuController = NutriMealMenuController();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: menuController,
        child: const MaterialApp(home: AddressScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pilih Alamat Pengiriman'), findsOneWidget);
    expect(find.text('NutriMeal'), findsOneWidget);
    expect(find.text('ALAMAT TERSIMPAN (3)'), findsOneWidget);
    expect(find.text('Tambah Alamat Baru'), findsOneWidget);
    expect(find.text('Gunakan Alamat Ini'), findsOneWidget);
  });

  testWidgets('Renders JadwalScreen with calendar, lunch & dinner, and nutrition stats', (WidgetTester tester) async {
    final menuController = NutriMealMenuController();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: menuController,
        child: const MaterialApp(home: JadwalScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sen'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('Makan Siang'), findsOneWidget);
    expect(find.text('Ayam Bakar Madu & Quinoa Hijau'), findsOneWidget);
    expect(find.text('Makan Malam'), findsOneWidget);
    expect(find.text('Salmon Teriyaki & Nasi Merah'), findsOneWidget);
    expect(find.text('Nutrisi Mingguan', skipOffstage: false), findsOneWidget);
    expect(find.textContaining('80% target protein', skipOffstage: false), findsOneWidget);
  });

  testWidgets('Renders NutriBotChatScreen with AI nutrition assistant & recommendation', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: NutriBotChatScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('NutriBot AI'), findsOneWidget);
    expect(find.text('Asisten Nutrisi & Kalori 24/7'), findsOneWidget);
    expect(find.text('Total Kalori'), findsOneWidget);
    expect(find.text('420 kkal'), findsOneWidget);
    expect(find.text('Poke Bowl Salmon'), findsOneWidget);
    expect(find.text('Tanya kalori, menu, atau diet...'), findsOneWidget);
  });

  testWidgets('Renders AdminChatScreen with customer care & ticket card', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: AdminChatScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Admin NutriCare'), findsOneWidget);
    expect(find.text('Customer Care & Ahli Gizi • '), findsOneWidget);
    expect(find.text('#TIK-8492', skipOffstage: false), findsOneWidget);
    expect(find.text('Status Tiket Permintaan', skipOffstage: false), findsOneWidget);
    expect(find.textContaining('Pacific Century Place', skipOffstage: false), findsOneWidget);
    expect(find.text('Tulis pesan ke NutriCare...'), findsOneWidget);
  });

  testWidgets('Renders ProfileScreen correctly', (WidgetTester tester) async {
    final menuController = NutriMealMenuController();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: menuController,
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nadia Salsabila'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('HARI BERUNTUN'), findsOneWidget);
    expect(find.text('Elite'), findsOneWidget);
    expect(find.text('MEMBER'), findsOneWidget);
    expect(find.text('Informasi Pribadi'), findsOneWidget);
    expect(find.text('Keluar'), findsOneWidget);
  });

  testWidgets('Renders ProfileDetailScreen correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ProfileDetailScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Profil'), findsOneWidget);
    expect(find.text('Kelengkapan Data Nutrisi'), findsOneWidget);
    expect(find.text('92% Lengkap'), findsOneWidget);
    expect(find.text('168 cm • 54 kg'), findsOneWidget);
    expect(find.text('BMI 19.1 (Ideal)'), findsOneWidget);
    expect(find.text('Simpan Perubahan'), findsOneWidget);
  });

  testWidgets('Renders NotifikasiScreen with updates, filter chips, and order action', (WidgetTester tester) async {
    final menuController = NutriMealMenuController();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: menuController,
        child: const MaterialApp(home: NotifikasiScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Notifikasi'), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('Pesanan'), findsOneWidget);
    expect(find.text('Promo & Diskon'), findsOneWidget);
    expect(find.text('Tandai semua dibaca'), findsOneWidget);
    expect(find.text('Kurir Sedang Menuju Lokasimu! 🛵'), findsOneWidget);
    expect(find.text('Menara Palma Lt. 12, Kuningan'), findsOneWidget);
    expect(find.text('~7 Menit'), findsOneWidget);
    expect(find.text('Rekomendasi Menu Spesial Untukmu 🥗'), findsOneWidget);
    expect(find.text('Salmon Teriyaki Bowl'), findsOneWidget);
    expect(find.text('Pesan Sekarang'), findsOneWidget);
    expect(find.text('Pembayaran Paket 5 Hari Berhasil', skipOffstage: false), findsOneWidget);
    expect(find.text('Lihat Bukti', skipOffstage: false), findsOneWidget);
  });

  testWidgets('Renders BantuanFaqScreen with NutriBot AI banner and FAQ accordions', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: BantuanFaqScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Profil'), findsOneWidget);
    expect(find.text('NUTRIBOT AI 24/7'), findsOneWidget);
    expect(find.text('Ada yang bisa kami bantu seputar menu sehat & pesananmu?'), findsOneWidget);
    expect(find.text('Saluran Bantuan Cepat'), findsOneWidget);
    expect(find.text('Live NutriBot AI'), findsOneWidget);
    expect(find.text('CS Resmi'), findsWidgets);
    expect(find.text('Pertanyaan Sering Diajukan'), findsOneWidget);
    expect(find.text('Bagaimana cara mengubah alamat pengiriman langganan harian?'), findsOneWidget);
    expect(find.text('Hubungi Layanan Pelanggan', skipOffstage: false), findsOneWidget);
  });

  testWidgets('Renders LanggananSayaScreen with active package and upcoming delivery', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: LanggananSayaScreen(showBottomNav: false)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Langganan Saya'), findsOneWidget);
    expect(find.text('Paket Sehat 30 Hari'), findsOneWidget);
    expect(find.text('BIAYA LANGGANAN'), findsOneWidget);
    expect(find.text('Rp750.000'), findsOneWidget);
    expect(find.text('12 hari terlewati (40%)'), findsOneWidget);
    expect(find.text('PENGIRIMAN BERIKUTNYA'), findsOneWidget);
    expect(find.text('Nasi Ayam Teriyaki'), findsWidgets);
    expect(find.text('Akan Dikirim'), findsOneWidget);
    expect(find.text('MENU MENDATANG'), findsOneWidget);
    expect(find.text('BENEFIT LANGGANAN AKTIF'), findsOneWidget);
    expect(find.text('Perpanjang Lebih Awal'), findsOneWidget);
    expect(find.text('Diskon 10%'), findsOneWidget);
  });

  testWidgets('Renders LanggananKatalogScreen with tier selection and sticky subscribe bar', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: LanggananKatalogScreen(showBottomNav: false)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Langganan'), findsOneWidget);
    expect(find.text('Lebih Praktis dengan Langganan'), findsOneWidget);
    expect(find.text('Pilih Paket Langganan'), findsOneWidget);
    expect(find.text('Paket Mingguan'), findsOneWidget);
    expect(find.text('Paket Bulanan Lengkap'), findsOneWidget);
    expect(find.text('PALING POPULER'), findsOneWidget);
    expect(find.text('Paket Hemat Siang'), findsOneWidget);
    expect(find.text('Kenapa Berlangganan?'), findsOneWidget);
    expect(find.text('Mulai dari'), findsOneWidget);
    expect(find.text('Mulai Langganan'), findsOneWidget);
  });

  testWidgets('Renders AddressScreen (Pilih Alamat Pengiriman) matching Image 1', (WidgetTester tester) async {
    final menuController = NutriMealMenuController();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: menuController,
        child: const MaterialApp(home: AddressScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pilih Alamat Pengiriman'), findsOneWidget);
    expect(find.text('NutriMeal'), findsOneWidget);
    expect(find.text('ALAMAT TERSIMPAN (3)'), findsOneWidget);
    expect(find.text('Pilih salah satu'), findsOneWidget);
    expect(find.text('Andi Pratama'), findsWidgets);
    expect(find.text('Hammad Feriand'), findsOneWidget);
    expect(find.text('Ubah'), findsWidgets);
    expect(find.text('Utama'), findsOneWidget);
    expect(find.text('Kantor'), findsOneWidget);
    expect(find.text('Rumah'), findsOneWidget);
    expect(find.text('Tempat Kerja'), findsOneWidget);
    expect(find.text('Semua pesanan paket sehat NutriMeal dikirim tepat waktu dengan thermal box steril.'), findsOneWidget);
    expect(find.text('Tambah Alamat Baru'), findsOneWidget);
    expect(find.text('Gunakan Alamat Ini'), findsOneWidget);
  });

  testWidgets('Renders AddressFormScreen in Edit Mode matching Image 2', (WidgetTester tester) async {
    final menuController = NutriMealMenuController();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: menuController,
        child: MaterialApp(
          home: AddressFormScreen(
            mode: AddressFormMode.edit,
            address: menuController.savedAddresses.first,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ubah Alamat Pengiriman'), findsOneWidget);
    expect(find.text('Tempel & Isi Otomatis'), findsOneWidget);
    expect(find.text('Alamat Pengiriman'), findsOneWidget);
    expect(find.text('Standar Kurir NutriMeal'), findsOneWidget);
    expect(find.text('Titik Lokasi Presisi'), findsOneWidget);
    expect(find.text('Ubah Pin'), findsOneWidget);
    expect(find.text('Atur sebagai Alamat Utama'), findsOneWidget);
    expect(find.text('Hapus Alamat'), findsOneWidget);
    expect(find.text('Simpan Alamat'), findsOneWidget);
  });

  testWidgets('Renders AddressFormScreen in Add Mode matching Image 3', (WidgetTester tester) async {
    final menuController = NutriMealMenuController();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: menuController,
        child: const MaterialApp(
          home: AddressFormScreen(
            mode: AddressFormMode.add,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tambahkan Alamat Pengiriman'), findsOneWidget);
    expect(find.text('Tempel dan Isi Otomatis ✨'), findsOneWidget);
    expect(find.text('Data Penerima'), findsOneWidget);
    expect(find.text('Katering NutriMeal'), findsOneWidget);
    expect(find.text('Titik Pengantaran Kurir'), findsOneWidget);
    expect(find.text('Ubah Pin 📍'), findsOneWidget);
    expect(find.text('Akurasi katering terverifikasi (~5m)'), findsOneWidget);
    expect(find.text('Simpan Alamat'), findsOneWidget);
  });
}



