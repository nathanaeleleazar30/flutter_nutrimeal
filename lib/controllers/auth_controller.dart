import 'package:flutter/foundation.dart';

class GoogleAccount {
  final String name;
  final String email;
  final String avatarInitials;
  final int avatarColorValue;

  const GoogleAccount({
    required this.name,
    required this.email,
    required this.avatarInitials,
    required this.avatarColorValue,
  });
}

class AuthController extends ChangeNotifier {
  // Loading & Session State
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _currentUserEmail;
  String? _currentUserName;

  // Form Validation Errors
  String? _namaError;
  String? _emailError;
  String? _whatsappError;
  String? _passwordError;
  String? _konfirmasiPasswordError;
  String? _forgotPasswordEmailError;

  // Selected Google Account
  GoogleAccount? _selectedGoogleAccount;

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get currentUserEmail => _currentUserEmail;
  String? get currentUserName => _currentUserName;

  String? get namaError => _namaError;
  String? get emailError => _emailError;
  String? get whatsappError => _whatsappError;
  String? get passwordError => _passwordError;
  String? get konfirmasiPasswordError => _konfirmasiPasswordError;
  String? get forgotPasswordEmailError => _forgotPasswordEmailError;
  GoogleAccount? get selectedGoogleAccount => _selectedGoogleAccount;

  // Preset Google Accounts from the design screenshot
  final List<GoogleAccount> googleAccounts = const [
    GoogleAccount(
      name: 'Abdullah Hammadi',
      email: 'hamma000@student.ub.ac.id',
      avatarInitials: 'AH',
      avatarColorValue: 0xFF2D3748,
    ),
    GoogleAccount(
      name: 'Bintang Habibillah',
      email: 'bintang123@student.ub.ac.id',
      avatarInitials: 'BH',
      avatarColorValue: 0xFFB45309,
    ),
    GoogleAccount(
      name: 'Nathanael Eleazar Handoko',
      email: 'nathan@student.ub.ac.id',
      avatarInitials: 'NE',
      avatarColorValue: 0xFF831843,
    ),
    GoogleAccount(
      name: 'Relian Rachmad Adam',
      email: 'relianrelian11@student.ub.ac.id',
      avatarInitials: 'RR',
      avatarColorValue: 0xFFDC2626,
    ),
  ];

  // Validation Logic
  void clearErrors() {
    _namaError = null;
    _emailError = null;
    _whatsappError = null;
    _passwordError = null;
    _konfirmasiPasswordError = null;
    _forgotPasswordEmailError = null;
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
      _emailError = 'email tidak boleh kosong';
      isValid = false;
    } else if (!trimmedEmail.contains('@')) {
      _emailError = 'format email tidak valid';
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
      _emailError = 'email tidak boleh kosong dan harus menggunakan @student.ub.ac.id';
      isValid = false;
    } else if (!trimmedEmail.contains('@student.ub.ac.id') && !trimmedEmail.contains('@gmail.com') && !trimmedEmail.contains('@')) {
      _emailError = 'email tidak boleh kosong dan harus menggunakan @student.ub.ac.id';
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

  // Authentication Actions
  Future<bool> login(String email, String password) async {
    if (!validateLoginForm(email, password)) return false;

    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 900));

    _isLoading = false;
    _isLoggedIn = true;
    _currentUserEmail = email;
    _currentUserName = email.split('@').first;
    notifyListeners();
    return true;
  }

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
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 900));

    _isLoading = false;
    _currentUserEmail = email;
    _currentUserName = nama;
    notifyListeners();
    return true;
  }

  void selectGoogleAccount(GoogleAccount account) {
    _selectedGoogleAccount = account;
    _currentUserEmail = account.email;
    _currentUserName = account.name;
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _currentUserEmail = null;
    _currentUserName = null;
    _selectedGoogleAccount = null;
    clearErrors();
    notifyListeners();
  }
}
