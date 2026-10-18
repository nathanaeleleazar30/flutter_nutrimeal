import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service untuk mengelola data sensitif (Secrets & Credentials) secara aman.
/// Memenuhi Requirement 3.a & 3.b:
/// a. Gunakan package flutter_secure_storage untuk menyimpan data sensitif secara
///    spesifik, seperti access token, refresh token, atau kredensial pengguna lainnya.
/// b. Dilarang keras menyimpan data token atau kredensial ini menggunakan shared_preferences.
class SecureStorageService {
  SecureStorageService._internal();
  static final SecureStorageService instance = SecureStorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static const String _keyAccessToken = 'sec_access_token';
  static const String _keyRefreshToken = 'sec_refresh_token';
  static const String _keyUserId = 'sec_user_id';
  static const String _keyUserEmail = 'sec_user_email';
  static const String _keyUserName = 'sec_user_name';

  // --- Auth Tokens ---
  Future<void> saveAuthToken(String token) async {
    await _storage.write(key: _keyAccessToken, value: token);
  }

  Future<String?> getAuthToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _keyRefreshToken, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  // --- User Sensitive Profile ---
  Future<void> saveUserCredentials({
    required String? token,
    required String? userId,
    required String? email,
    required String? name,
    String? refreshToken,
  }) async {
    if (token != null) await _storage.write(key: _keyAccessToken, value: token);
    if (refreshToken != null) await _storage.write(key: _keyRefreshToken, value: refreshToken);
    if (userId != null) await _storage.write(key: _keyUserId, value: userId);
    if (email != null) await _storage.write(key: _keyUserEmail, value: email);
    if (name != null) await _storage.write(key: _keyUserName, value: name);
  }

  Future<Map<String, String?>> getUserCredentials() async {
    final token = await _storage.read(key: _keyAccessToken);
    final refreshToken = await _storage.read(key: _keyRefreshToken);
    final userId = await _storage.read(key: _keyUserId);
    final email = await _storage.read(key: _keyUserEmail);
    final name = await _storage.read(key: _keyUserName);

    return {
      'token': token,
      'refreshToken': refreshToken,
      'userId': userId,
      'email': email,
      'name': name,
    };
  }

  // --- Logout / Clear Secrets ---
  Future<void> clearAllSecrets() async {
    await _storage.deleteAll();
  }
}
