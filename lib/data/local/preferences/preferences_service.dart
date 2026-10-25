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
  static const String _keySelectedFilterCategory = 'app_selected_filter_category';
  static const String _keyLastCacheSyncUtcMillis = 'app_last_cache_sync_utc_millis';
  static const String _keyNotificationEnabled = 'app_notification_enabled';

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

  // Clear all non-sensitive preferences
  Future<void> clearAllPreferences() async {
    final prefs = await _safePrefs;
    await prefs.clear();
  }
}
