import 'package:hive_flutter/hive_flutter.dart';

class CacheService {
  static const String _userBox = 'user_box';
  static const String _settingsBox = 'settings_box';
  static const String _authBox = 'auth_box';
  
  static late Box _userData;
  static late Box _settings;
  static late Box _authData;

  static Future<void> initialize() async {
    _userData = await Hive.openBox(_userBox);
    _settings = await Hive.openBox(_settingsBox);
    _authData = await Hive.openBox(_authBox);
  }

  // Auth data methods
  static Future<void> saveAuthToken(String token) async {
    await _authData.put('auth_token', token);
  }

  static String? getAuthToken() {
    return _authData.get('auth_token');
  }

  static Future<void> saveRefreshToken(String token) async {
    await _authData.put('refresh_token', token);
  }

  static String? getRefreshToken() {
    return _authData.get('refresh_token');
  }

  static Future<void> clearAuthData() async {
    await _authData.clear();
  }

  // User data methods
  static Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    await _userData.put('user_profile', profile);
  }

  static Map<String, dynamic>? getUserProfile() {
    final data = _userData.get('user_profile');
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  static Future<void> saveBuddies(List<Map<String, dynamic>> buddies) async {
    await _userData.put('buddies', buddies);
  }

  static List<Map<String, dynamic>> getBuddies() {
    final data = _userData.get('buddies');
    return data != null ? List<Map<String, dynamic>>.from(data) : [];
  }

  static Future<void> saveRoutines(List<Map<String, dynamic>> routines) async {
    await _userData.put('routines', routines);
  }

  static List<Map<String, dynamic>> getRoutines() {
    final data = _userData.get('routines');
    return data != null ? List<Map<String, dynamic>>.from(data) : [];
  }

  // Settings methods
  static Future<void> saveAppSettings(Map<String, dynamic> settings) async {
    await _settings.put('app_settings', settings);
  }

  static Map<String, dynamic> getAppSettings() {
    final data = _settings.get('app_settings');
    return data != null ? Map<String, dynamic>.from(data) : {};
  }

  static Future<void> saveDarkMode(bool isDark) async {
    await _settings.put('dark_mode', isDark);
  }

  static bool getDarkMode() {
    return _settings.get('dark_mode', defaultValue: false);
  }

  static Future<void> saveFirstLaunch(bool isFirst) async {
    await _settings.put('first_launch', isFirst);
  }

  static bool isFirstLaunch() {
    return _settings.get('first_launch', defaultValue: true);
  }

  static Future<void> saveOnboardingCompleted(bool completed) async {
    await _settings.put('onboarding_completed', completed);
  }

  static bool isOnboardingCompleted() {
    return _settings.get('onboarding_completed', defaultValue: false);
  }

  // Clear all data
  static Future<void> clearAllData() async {
    await _userData.clear();
    await _settings.clear();
    await _authData.clear();
  }

  // Cache management
  static Future<void> clearUserData() async {
    await _userData.clear();
  }

  static Future<void> saveLastSyncTime(DateTime time) async {
    await _settings.put('last_sync', time.millisecondsSinceEpoch);
  }

  static DateTime? getLastSyncTime() {
    final timestamp = _settings.get('last_sync');
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }
} 