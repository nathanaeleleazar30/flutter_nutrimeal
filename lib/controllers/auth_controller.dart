import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../core/constants/api_config.dart';

class AuthController extends ChangeNotifier {
  // Google Sign-In instance untuk autentikasi akun Google resmi
  late final GoogleSignIn _googleSignIn;

  AuthController() {
    String? clientId;
    try {
      if (Platform.isAndroid) {
        clientId = ApiConfig.androidClientId;
      }
    } catch (_) {}

    _googleSignIn = GoogleSignIn(
      serverClientId: ApiConfig.webClientId,
      clientId: clientId,
      scopes: const ['email', 'profile'],
    );
  }

  // Loading & Session State
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _currentUserEmail;
  String? _currentUserName;
  String? _authToken;
  String? _customerId;
  String? _backendMessage;

  // Form Validation Errors
  String? _namaError;
  String? _emailError;
  String? _whatsappError;
  String? _passwordError;
  String? _konfirmasiPasswordError;
  String? _forgotPasswordEmailError;

  // General error message (for backend errors)
  String? _generalError;

  // Selected Google Account (only set after successful real Google Sign-In)
  RealGoogleUser? _selectedGoogleAccount;

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get currentUserEmail => _currentUserEmail;
  String? get currentUserName => _currentUserName;
  String? get authToken => _authToken;
  String? get customerId => _customerId;
  String? get backendMessage => _backendMessage;
  String? get generalError => _generalError;

  String? get namaError => _namaError;
  String? get emailError => _emailError;
  String? get whatsappError => _whatsappError;
  String? get passwordError => _passwordError;
  String? get konfirmasiPasswordError => _konfirmasiPasswordError;
  String? get forgotPasswordEmailError => _forgotPasswordEmailError;

  // For Google Sign-In (real), expose basic info
  RealGoogleUser? get selectedGoogleAccount => _selectedGoogleAccount;

  // Validation Logic
  void clearErrors() {
    _namaError = null;
    _emailError = null;
    _whatsappError = null;
    _passwordError = null;
    _konfirmasiPasswordError = null;
    _forgotPasswordEmailError = null;
    _generalError = null;
    notifyListeners();
  }

  void setValidationErrorsManual({
    String? emailErr,
    String? passwordErr,
  }) {
    _emailError = emailErr;
    _passwordError = passwordErr;
    notifyListeners();
  }

  bool validateLoginForm(String email, String password) {
    clearErrors();
    bool isValid = true;

    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      _emailError = 'Email tidak boleh kosong';
      isValid = false;
    } else if (!trimmedEmail.contains('@')) {
      _emailError = 'Format email tidak valid';
      isValid = false;
    }

    if (password.isEmpty) {
      _passwordError = 'Password tidak boleh kosong';
      isValid = false;
    }

    notifyListeners();
    return isValid;
  }

  bool validateRegisterForm({
    required String nama,
    required String email,
    required String whatsapp,
    required String password,
    required String konfirmasiPassword,
  }) {
    clearErrors();
    bool isValid = true;

    if (nama.trim().isEmpty) {
      _namaError = 'Nama lengkap tidak boleh kosong';
      isValid = false;
    }

    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      _emailError = 'Email tidak boleh kosong';
      isValid = false;
    } else if (!trimmedEmail.contains('@')) {
      _emailError = 'Format email tidak valid';
      isValid = false;
    }

    if (whatsapp.trim().isEmpty) {
      _whatsappError = 'Nomor WhatsApp tidak boleh kosong';
      isValid = false;
    }

    if (password.isEmpty) {
      _passwordError = 'Password minimal 8 karakter mengandung angka';
      isValid = false;
    } else if (password.length < 8 || !RegExp(r'\d').hasMatch(password)) {
      _passwordError = 'Password minimal 8 karakter mengandung angka';
      isValid = false;
    }

    if (konfirmasiPassword.isEmpty) {
      _konfirmasiPasswordError = 'Konfirmasi password tidak boleh kosong';
      isValid = false;
    } else if (password != konfirmasiPassword) {
      _konfirmasiPasswordError = 'Konfirmasi password tidak cocok';
      isValid = false;
    }

    notifyListeners();
    return isValid;
  }

  bool validateForgotPassword(String email) {
    _forgotPasswordEmailError = null;
    final trimmed = email.trim();
    if (trimmed.isEmpty) {
      _forgotPasswordEmailError = 'Masukkan alamat email Anda';
      notifyListeners();
      return false;
    }
    if (!trimmed.contains('@')) {
      _forgotPasswordEmailError = 'Format email tidak valid';
      notifyListeners();
      return false;
    }
    notifyListeners();
    return true;
  }

  // =========================================================
  // LOGIN — Wajib ke Backend. Tidak ada fallback/dummy.
  // =========================================================
  Future<bool> login(String email, String password) async {
    if (!validateLoginForm(email, password)) return false;

    _isLoading = true;
    _generalError = null;
    notifyListeners();

    try {
      final candidateUrls = ApiConfig.candidateLoginUrls;
      Map<String, dynamic>? successData;

      for (final urlStr in candidateUrls) {
        try {
          final url = Uri.parse(urlStr);
          if (kDebugMode) print('[NutriMeal Auth] Login ke: $url');

          final response = await http
              .post(
                url,
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({'email': email.trim(), 'password': password}),
              )
              .timeout(const Duration(seconds: 6));

          final data = jsonDecode(response.body) as Map<String, dynamic>;

          if (response.statusCode == 200 && data['success'] == true) {
            successData = data;
            break;
          } else if (response.statusCode == 401 || response.statusCode == 400) {
            // Kredensial salah — jangan coba URL lain
            _generalError = data['message'] ?? 'Email atau password salah.';
            _isLoading = false;
            notifyListeners();
            return false;
          }
        } on Exception catch (e) {
          if (kDebugMode) print('[NutriMeal Auth] ⚠️ Gagal di $urlStr: $e');
          continue;
        }
      }

      if (successData == null) {
        _generalError = 'Tidak dapat terhubung ke server. Cek koneksi jaringan.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Berhasil login dari backend
      final customerData = successData['data'];
      _authToken = customerData?['token'];
      _customerId = customerData?['customer']?['id'] ?? customerData?['id'];
      _currentUserName = customerData?['customer']?['name'] ?? customerData?['name'] ?? email.split('@').first;
      _currentUserEmail = customerData?['customer']?['email'] ?? customerData?['email'] ?? email;
      _isLoggedIn = true;
      _backendMessage = 'Login berhasil';

      if (kDebugMode) print('[NutriMeal Auth] ✅ Login berhasil: $_currentUserEmail');
    } catch (e) {
      _generalError = 'Terjadi kesalahan: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }

  // =========================================================
  // REGISTER — Wajib ke Backend. Tidak ada fallback/dummy.
  // =========================================================
  Future<bool> register({
    required String nama,
    required String email,
    required String whatsapp,
    required String password,
    required String konfirmasiPassword,
  }) async {
    if (!validateRegisterForm(
      nama: nama,
      email: email,
      whatsapp: whatsapp,
      password: password,
      konfirmasiPassword: konfirmasiPassword,
    )) {
      return false;
    }

    _isLoading = true;
    _generalError = null;
    notifyListeners();

    try {
      // Daftar customer via endpoint customer-register (simpan password ke DB)
      final resData = await _postToBackend(
        ApiConfig.candidateRegisterUrls,
        {
          'name': nama.trim(),
          'email': email.trim(),
          'phone': whatsapp.trim(),
          'password': password,
        },
      );

      if (resData == null) {
        _generalError = 'Tidak dapat terhubung ke server. Cek koneksi jaringan.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (resData['success'] != true) {
        _generalError = resData['message'] ?? 'Pendaftaran gagal.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Sukses
      final customerData = resData['data'];
      _authToken = customerData?['token'];
      _customerId = customerData?['customer']?['id'];
      _currentUserName = customerData?['customer']?['name'] ?? nama;
      _currentUserEmail = customerData?['customer']?['email'] ?? email;
      _isLoggedIn = true;
      _backendMessage = 'Pendaftaran tersimpan ke Database';

      if (kDebugMode) print('[NutriMeal Auth] ✅ Register berhasil: $_currentUserEmail');
    } catch (e) {
      _generalError = 'Terjadi kesalahan: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }

  // =========================================================
  // GOOGLE SIGN-IN RESMI (Native Google Sign-In SDK)
  // =========================================================
  Future<bool> signInWithRealGoogle() async {
    _isLoading = true;
    _generalError = null;
    _backendMessage = null;
    notifyListeners();

    try {
      if (kDebugMode) print('[NutriMeal Auth] Membuka jendela resmi Google Sign-In...');

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        if (kDebugMode) print('[NutriMeal Auth] Pengguna membatalkan pemilihan akun Google.');
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        _generalError = 'Gagal mendapatkan token dari Google. Coba lagi.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (kDebugMode) print('[NutriMeal Auth] Akun Google terpilih: ${googleUser.email}');

      final resData = await _postToBackend(
        ApiConfig.candidateGoogleAuthUrls,
        {
          'idToken': idToken,
          'email': googleUser.email,
          'name': googleUser.displayName ?? googleUser.email.split('@').first,
          'googleId': googleUser.id,
          'photoUrl': googleUser.photoUrl,
        },
      );

      if (resData == null) {
        _generalError = 'Tidak dapat terhubung ke server setelah Google Sign-In.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (resData['success'] != true) {
        _generalError = resData['message'] ?? 'Login Google gagal diverifikasi backend.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final customerData = resData['data'];
      _authToken = customerData?['token'];
      _customerId = customerData?['customer']?['id'];
      _currentUserName = customerData?['customer']?['name'] ?? googleUser.displayName;
      _currentUserEmail = customerData?['customer']?['email'] ?? googleUser.email;
      _isLoggedIn = true;
      _selectedGoogleAccount = RealGoogleUser(
        name: _currentUserName ?? googleUser.displayName ?? 'Pengguna Google',
        email: _currentUserEmail ?? googleUser.email,
        photoUrl: googleUser.photoUrl,
      );
      _backendMessage = 'Tersambung via Akun Google Resmi';

      if (kDebugMode) print('[NutriMeal Auth] ✅ Google Sign-In berhasil: $_currentUserEmail');
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) print('[NutriMeal Auth] Error Google Sign-In: $e');
      _generalError = 'Google Sign-In error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // =========================================================
  // Helper: POST ke backend — coba beberapa URL
  // =========================================================
  Future<Map<String, dynamic>?> _postToBackend(
    List<String> candidateUrls,
    Map<String, dynamic> body,
  ) async {
    final jsonBody = jsonEncode(body);

    for (final urlStr in candidateUrls) {
      try {
        final url = Uri.parse(urlStr);
        if (kDebugMode) print('[NutriMeal Auth] POST ke: $url');

        final response = await http
            .post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: jsonBody,
            )
            .timeout(const Duration(seconds: 6));

        final data = jsonDecode(response.body) as Map<String, dynamic>;

        if (response.statusCode < 500) {
          // Return data (bisa success atau error dari backend)
          if (kDebugMode) {
            if (data['success'] == true) {
              print('[NutriMeal Auth] ✅ Berhasil terhubung ke: $url');
            } else {
              print('[NutriMeal Auth] ⚠️ Backend error di $url: ${data['message']}');
            }
          }
          return data;
        }
      } on Exception catch (e) {
        if (kDebugMode) print('[NutriMeal Auth] ⚠️ Tidak dapat dijangkau $urlStr: $e');
        continue;
      }
    }
    return null;
  }

  void logout() {
    _isLoggedIn = false;
    _currentUserEmail = null;
    _currentUserName = null;
    _authToken = null;
    _customerId = null;
    _selectedGoogleAccount = null;
    _backendMessage = null;
    _googleSignIn.signOut().catchError((_) => null);
    clearErrors();
    notifyListeners();
  }
}

class RealGoogleUser {
  final String name;
  final String email;
  final String? photoUrl;

  const RealGoogleUser({
    required this.name,
    required this.email,
    this.photoUrl,
  });
}
