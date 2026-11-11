import 'package:image_picker/image_picker.dart' show XFile;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../core/constants/api_config.dart';
import '../data/local/secure/secure_storage_service.dart';

class AuthController extends ChangeNotifier {
  // Google Sign-In instance untuk autentikasi akun Google resmi
  late final GoogleSignIn _googleSignIn;

  AuthController() {
    _googleSignIn = GoogleSignIn(
      serverClientId: ApiConfig.webClientId,
      scopes: const ['email', 'profile'],
    );

    // Requirement 3: Pulihkan sesi pengguna dari secure storage saat app dibuka
    restoreSession();
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

  // Extended Customer Profile Data (synchronized with MySQL Backend)
  String? _customerPhone;
  String? _customerAvatarUrl;
  String? _customerAddress;
  double _customerHeight = 163.0;
  double _customerWeight = 52.0;
  int _customerAge = 24;
  List<String> _customerAllergies = ['Kacang'];
  String _customerDietGoal = 'Defisit Kalori';
  int _customerTargetCalories = 1800;
  bool _customerTwoFactorAuth = true;

  void _resetCustomerProfile() {
    _customerAvatarUrl = null;
    _customerPhone = null;
    _customerAddress = null;
    _customerHeight = 163.0;
    _customerWeight = 52.0;
    _customerAge = 24;
    _customerAllergies = [];
    _customerDietGoal = 'Defisit Kalori';
    _customerTargetCalories = 1800;
    _customerTwoFactorAuth = true;
  }

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

  // Profile Getters
  String? get customerPhone => _customerPhone;
  String? get customerAvatarUrl => _customerAvatarUrl;
  String? get customerAddress => _customerAddress;
  double get customerHeight => _customerHeight;
  double get customerWeight => _customerWeight;
  int get customerAge => _customerAge;
  List<String> get customerAllergies => _customerAllergies;
  String get customerDietGoal => _customerDietGoal;
  int get customerTargetCalories => _customerTargetCalories;
  bool get customerTwoFactorAuth => _customerTwoFactorAuth;

  String? get namaError => _namaError;
  String? get emailError => _emailError;
  String? get whatsappError => _whatsappError;
  String? get passwordError => _passwordError;
  String? get konfirmasiPasswordError => _konfirmasiPasswordError;
  String? get forgotPasswordEmailError => _forgotPasswordEmailError;

  // For Google Sign-In (real), expose basic info
  RealGoogleUser? get selectedGoogleAccount => _selectedGoogleAccount;

  // Requirement 3: Restore session from FlutterSecureStorage
  Future<void> restoreSession() async {
    try {
      final creds = await SecureStorageService.instance.getUserCredentials();
      final token = creds['token'];
      if (token != null && token.isNotEmpty) {
        _authToken = token;
        _customerId = creds['userId'];
        _currentUserName = creds['name'];
        _currentUserEmail = creds['email'];
        _isLoggedIn = true;
        notifyListeners();
        if (kDebugMode) {
          print('[NutriMeal Auth] 🔐 Sesi berhasil dipulihkan dari FlutterSecureStorage: $_currentUserEmail');
        }
      }
    } catch (e) {
      if (kDebugMode) print('[NutriMeal Auth] ⚠️ Gagal memulihkan sesi dari secure storage: $e');
    }
  }

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
          } else {
            // Backend berhasil dihubungi namun menolak kredensial atau error
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
      _resetCustomerProfile(); // Bersihkan profil lama agar akun baru tidak mewarisi foto lama
      final customerData = successData['data'];
      _authToken = customerData?['token'];
      _customerId = customerData?['customer']?['id'] ?? customerData?['id'];
      _currentUserName = customerData?['customer']?['name'] ?? customerData?['name'] ?? email.split('@').first;
      _currentUserEmail = customerData?['customer']?['email'] ?? customerData?['email'] ?? email;
      _isLoggedIn = true;
      _backendMessage = 'Login berhasil';

      if (customerData?['customer'] != null) {
        _applyCustomerData(customerData['customer']);
      } else {
        await fetchCustomerProfile();
      }

      // Requirement 3.a: Simpan token & kredensial ke flutter_secure_storage
      if (_authToken != null) {
        await SecureStorageService.instance.saveUserCredentials(
          token: _authToken,
          userId: _customerId,
          email: _currentUserEmail,
          name: _currentUserName,
        );
      }

      if (kDebugMode) print('[NutriMeal Auth] ✅ Login berhasil & tersimpan di SecureStorage: $_currentUserEmail');
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

            // Sukses menyimpan ke database
      // Jangan langsung login otomatis, agar user login manual terlebih dahulu
      _resetCustomerProfile(); // Bersihkan seluruh profil akun lama
      _authToken = null;
      _customerId = null;
      _currentUserName = null;
      _currentUserEmail = null;
      _isLoggedIn = false;
      _backendMessage = 'Pendaftaran berhasil. Silakan masuk dengan akun Anda.';

      if (kDebugMode) print('[NutriMeal Auth] 🚀 Register berhasil tersimpan di DB: ${email.trim()}');
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

      // Requirement 3.a: Simpan token Google / backend ke flutter_secure_storage
      if (_authToken != null) {
        await SecureStorageService.instance.saveUserCredentials(
          token: _authToken,
          userId: _customerId,
          email: _currentUserEmail,
          name: _currentUserName,
        );
      }

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

        if (kDebugMode) {
          if (data['success'] == true) {
            print('[NutriMeal Auth] ✅ Berhasil terhubung ke: $url');
          } else {
            print('[NutriMeal Auth] ⚠️ Backend response (${response.statusCode}) di $url: ${data['message']}');
          }
        }
        return data;
      } on Exception catch (e) {
        if (kDebugMode) print('[NutriMeal Auth] ⚠️ Tidak dapat dijangkau $urlStr: $e');
        continue;
      }
    }
    return null;
  }

  // =========================================================
  // SYNC CUSTOMER PROFILE DENGAN BACKEND (MySQL)
  // =========================================================
  void _applyCustomerData(dynamic data) {
    if (data == null) return;
    if (data['id'] != null) _customerId = data['id'].toString();
    if (data['name'] != null && data['name'].toString().isNotEmpty) {
      _currentUserName = data['name'].toString();
    }
    if (data['email'] != null && data['email'].toString().isNotEmpty) {
      _currentUserEmail = data['email'].toString();
    }
    _customerPhone = (data['phone'] != null && data['phone'].toString().trim().isNotEmpty)
        ? data['phone'].toString().trim()
        : null;

    // SANGAT PENTING: Jika di database avatar_url kosong/null, pastikan direset menjadi null
    // agar akun baru TIDAK mewarisi foto profil akun sebelumnya!
    final rawAvatar = data['avatar_url'];
    if (rawAvatar != null &&
        rawAvatar.toString().trim().isNotEmpty &&
        rawAvatar.toString().trim() != 'null') {
      _customerAvatarUrl = rawAvatar.toString().trim();
    } else {
      _customerAvatarUrl = null;
    }

    _customerAddress = (data['address'] != null && data['address'].toString().trim().isNotEmpty)
        ? data['address'].toString().trim()
        : null;

    if (data['height_cm'] != null) {
      _customerHeight = double.tryParse(data['height_cm'].toString()) ?? 163.0;
    }
    if (data['weight_kg'] != null) {
      _customerWeight = double.tryParse(data['weight_kg'].toString()) ?? 52.0;
    }
    if (data['age'] != null) {
      _customerAge = int.tryParse(data['age'].toString()) ?? 24;
    }
    if (data['target_calories'] != null) {
      _customerTargetCalories = int.tryParse(data['target_calories'].toString()) ?? 1800;
    }
    if (data['dietary_goals'] != null) {
      if (data['dietary_goals'] is List) {
        final list = data['dietary_goals'] as List;
        _customerDietGoal = list.isNotEmpty ? list.first.toString() : 'Defisit Kalori';
      } else {
        _customerDietGoal = data['dietary_goals'].toString();
      }
    }
    if (data['allergies'] != null) {
      if (data['allergies'] is List) {
        _customerAllergies = (data['allergies'] as List)
            .map((e) => e.toString().trim())
            .where((s) => s.isNotEmpty)
            .toList();
      } else if (data['allergies'] is String) {
        _customerAllergies = data['allergies']
            .toString()
            .split(',')
            .map((e) => e.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }
    } else {
      _customerAllergies = [];
    }
    if (data['two_factor_auth'] != null) {
      _customerTwoFactorAuth = data['two_factor_auth'] == 1 ||
          data['two_factor_auth'] == true ||
          data['two_factor_auth'] == '1';
    }
  }

  Future<void> fetchCustomerProfile() async {
    final token = _authToken;
    final id = _customerId;
    final email = _currentUserEmail;

    for (final urlStr in ApiConfig.candidateCustomerMeUrls) {
      try {
        final uri = Uri.parse(urlStr).replace(
          queryParameters: {
            if (id != null && id.isNotEmpty) 'id': id,
            if (email != null && email.isNotEmpty) 'email': email,
          },
        );

        final response = await http.get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final json = jsonDecode(response.body);
          if (json['success'] == true && json['data'] != null) {
            _applyCustomerData(json['data']);
            notifyListeners();
            return;
          }
        }
      } catch (e) {
        if (kDebugMode) print('[NutriMeal Auth] fetchCustomerProfile err: $e');
      }
    }

    if (id != null && id.isNotEmpty) {
      for (final base in ApiConfig.candidateCustomerUrls) {
        try {
          final url = Uri.parse('$base/$id');
          final response = await http.get(
            url,
            headers: {'Content-Type': 'application/json'},
          ).timeout(const Duration(seconds: 5));

          if (response.statusCode == 200) {
            final json = jsonDecode(response.body);
            if (json['success'] == true && json['data'] != null) {
              _applyCustomerData(json['data']);
              notifyListeners();
              return;
            }
          }
        } catch (_) {}
      }
    }
  }

  Future<bool> updateCustomerProfile({
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    String? address,
    double? heightCm,
    double? weightKg,
    int? age,
    List<String>? allergies,
    String? dietaryGoals,
    int? targetCalories,
    bool? twoFactorAuth,
  }) async {
    _isLoading = true;
    _generalError = null;
    notifyListeners();

    final targetId = _customerId;
    if (targetId == null || targetId.isEmpty) {
      if (kDebugMode) print('[NutriMeal Auth] ⚠️ Tidak ada customerId aktif. Membatalkan update profil.');
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final payload = <String, dynamic>{
      'name': name ?? _currentUserName ?? '',
      'email': email ?? _currentUserEmail ?? '',
      'phone': phone ?? _customerPhone ?? '',
      'avatar_url': avatarUrl ?? _customerAvatarUrl,
      'address': address ?? _customerAddress ?? '',
      'height_cm': heightCm ?? _customerHeight,
      'weight_kg': weightKg ?? _customerWeight,
      'age': age ?? _customerAge,
      'allergies': allergies ?? _customerAllergies,
      'dietary_goals': dietaryGoals ?? _customerDietGoal,
      'target_calories': targetCalories ?? _customerTargetCalories,
      'two_factor_auth': (twoFactorAuth ?? _customerTwoFactorAuth) ? 1 : 0,
    };

    for (final base in ApiConfig.candidateCustomerUrls) {
      try {
        final url = Uri.parse('$base/$targetId');
        if (kDebugMode) print('[NutriMeal Auth] PUT customer profile ke: $url');

        final response = await http
            .put(
              url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(payload),
            )
            .timeout(const Duration(seconds: 6));

        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (response.statusCode == 200 && data['success'] == true) {
          _applyCustomerData(data['data'] ?? payload);
          await SecureStorageService.instance.saveUserCredentials(
            token: _authToken,
            userId: _customerId,
            email: _currentUserEmail,
            name: _currentUserName,
          );
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _generalError = data['message'] ?? 'Gagal memperbarui profil di server.';
        }
      } catch (e) {
        if (kDebugMode) print('[NutriMeal Auth] Gagal PUT customer ke $base: $e');
        continue;
      }
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<Map<String, dynamic>> changeCustomerPassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final targetId = _customerId;
    if (targetId == null || targetId.isEmpty) return {'success': false, 'message': 'Sesi login tidak valid.'};
    final payload = {
      'old_password': oldPassword,
      'new_password': newPassword,
    };

    for (final base in ApiConfig.candidateCustomerUrls) {
      try {
        final url = Uri.parse('$base/$targetId');
        final response = await http
            .put(
              url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(payload),
            )
            .timeout(const Duration(seconds: 6));

        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (response.statusCode == 200 && data['success'] == true) {
          return {'success': true, 'message': data['message'] ?? 'Kata sandi berhasil diperbarui!'};
        } else {
          return {'success': false, 'message': data['message'] ?? 'Kata sandi saat ini tidak cocok.'};
        }
      } catch (e) {
        if (kDebugMode) print('[NutriMeal Auth] Gagal ubah password di $base: $e');
        continue;
      }
    }
    return {'success': false, 'message': 'Tidak dapat terhubung ke server backend.'};
  }

  // =========================================================
  // UPLOAD FOTO PROFIL DARI DEVICE KE BACKEND (MySQL & /uploads)
  // =========================================================
  Future<String?> uploadProfileImage(XFile imageFile) async {
    _isLoading = true;
    notifyListeners();

    try {
      final bytes = await imageFile.readAsBytes();
      final filename = imageFile.name.isNotEmpty
          ? imageFile.name
          : 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';

      for (final urlStr in ApiConfig.candidateUploadUrls) {
        try {
          final uri = Uri.parse(urlStr);
          if (kDebugMode) print('[NutriMeal Auth] Mengunggah foto profil ke: $uri');

          final request = http.MultipartRequest('POST', uri);
          request.files.add(
            http.MultipartFile.fromBytes(
              'image',
              bytes,
              filename: filename,
            ),
          );

          final streamedResponse =
              await request.send().timeout(const Duration(seconds: 15));
          final response = await http.Response.fromStream(streamedResponse);

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body) as Map<String, dynamic>;
            if (data['success'] == true && data['imageUrl'] != null) {
              final rawPath = data['imageUrl'].toString();
              final resolved = ApiConfig.resolveImageUrl(rawPath);
              _customerAvatarUrl = resolved;
              _isLoading = false;
              notifyListeners();
              return resolved;
            }
          }
        } catch (e) {
          if (kDebugMode) print('[NutriMeal Auth] Gagal upload foto di $urlStr: $e');
          continue;
        }
      }
    } catch (e) {
      if (kDebugMode) print('[NutriMeal Auth] Error uploadProfileImage: $e');
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _currentUserEmail = null;
    _currentUserName = null;
    _authToken = null;
    _customerId = null;
    _selectedGoogleAccount = null;
    _backendMessage = null;
    _resetCustomerProfile(); // Bersihkan foto dan data profil akun saat keluar
    _googleSignIn.signOut().catchError((_) => null);
    // Requirement 3: Hapus semua data sensitif dari SecureStorage saat logout
    await SecureStorageService.instance.clearAllSecrets();
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
