import 'package:shared_preferences/shared_preferences.dart';

/// Service untuk mengelola pengaturan dan data aplikasi kecil non-sensitif.
/// Memenuhi Requirement 2.a: Gunakan package shared_preferences hanya untuk
/// menyimpan data aplikasi yang kecil dan tidak sensitif.
/// Dilarang keras menyimpan token atau kredensial di sini!
class PreferencesService {
  PreferencesService._internal();
  static final PreferencesService instance = PreferencesService._internal();

  static const String _keyThemeMode = 'app_theme_mode';
  static const String _keyIsFirstTime = 'app_is_first_time';
  static const String _keySelectedFilterCategory =
      'app_selected_filter_category';
  static const String _keyLastCacheSyncUtcMillis =
      'app_last_cache_sync_utc_millis';
  static const String _keyNotificationEnabled = 'app_notification_enabled';
  static const String _keyQrisIdempotencyKey = 'qris_checkout_idempotency_key';
  static const String _keyQrisIdempotencyFingerprint =
      'qris_checkout_idempotency_fingerprint';
  static const String _keyQrisIdempotencyCustomerId =
      'qris_checkout_idempotency_customer_id';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _safePrefs async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  // --- Theme Mode ---
  Future<String> getThemeMode() async {
    final prefs = await _safePrefs;
    return prefs.getString(_keyThemeMode) ?? 'light';
  }

  Future<void> setThemeMode(String themeMode) async {
    final prefs = await _safePrefs;
    await prefs.setString(_keyThemeMode, themeMode);
  }

  // --- First Time / Onboarding ---
  Future<bool> isFirstTime() async {
    final prefs = await _safePrefs;
    return prefs.getBool(_keyIsFirstTime) ?? true;
  }

  Future<void> setFirstTimeCompleted() async {
    final prefs = await _safePrefs;
    await prefs.setBool(_keyIsFirstTime, false);
  }

  // --- Category Filter Preference ---
  Future<String?> getSelectedFilterCategory() async {
    final prefs = await _safePrefs;
    return prefs.getString(_keySelectedFilterCategory);
  }

  Future<void> setSelectedFilterCategory(String? category) async {
    final prefs = await _safePrefs;
    if (category == null) {
      await prefs.remove(_keySelectedFilterCategory);
    } else {
      await prefs.setString(_keySelectedFilterCategory, category);
    }
  }

  // --- Last Cache Sync (UTC Millis) ---
  Future<int?> getLastCacheSyncUtcMillis() async {
    final prefs = await _safePrefs;
    return prefs.getInt(_keyLastCacheSyncUtcMillis);
  }

  Future<void> setLastCacheSyncUtcMillis(int utcMillis) async {
    final prefs = await _safePrefs;
    await prefs.setInt(_keyLastCacheSyncUtcMillis, utcMillis);
  }

  // --- Notification Toggle ---
  Future<bool> isNotificationEnabled() async {
    final prefs = await _safePrefs;
    return prefs.getBool(_keyNotificationEnabled) ?? true;
  }

  Future<void> setNotificationEnabled(bool enabled) async {
    final prefs = await _safePrefs;
    await prefs.setBool(_keyNotificationEnabled, enabled);
  }

  // --- QRIS Checkout Idempotency State (non-sensitif: hanya UUID v4 & hash sidik keranjang) ---
  Future<({String key, String fingerprint, String customerId})?>
  getCheckoutIdempotencyState() async {
    final prefs = await _safePrefs;
    final key = prefs.getString(_keyQrisIdempotencyKey);
    final fp = prefs.getString(_keyQrisIdempotencyFingerprint);
    final custId = prefs.getString(_keyQrisIdempotencyCustomerId);
    if (key == null || key.isEmpty || fp == null || fp.isEmpty) {
      return null;
    }
    return (key: key, fingerprint: fp, customerId: custId ?? '');
  }

  Future<void> saveCheckoutIdempotencyState({
    required String key,
    required String fingerprint,
    required String customerId,
  }) async {
    final prefs = await _safePrefs;
    await prefs.setString(_keyQrisIdempotencyKey, key);
    await prefs.setString(_keyQrisIdempotencyFingerprint, fingerprint);
    await prefs.setString(_keyQrisIdempotencyCustomerId, customerId);
  }

  Future<void> clearCheckoutIdempotencyState() async {
    final prefs = await _safePrefs;
    await prefs.remove(_keyQrisIdempotencyKey);
    await prefs.remove(_keyQrisIdempotencyFingerprint);
    await prefs.remove(_keyQrisIdempotencyCustomerId);
  }

  // Clear all non-sensitive preferences
  Future<void> clearAllPreferences() async {
    final prefs = await _safePrefs;
    await prefs.clear();
  }
}
