import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../constants/app_constants.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Token Management
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: AppConstants.accessTokenKey, value: accessToken),
      _storage.write(key: AppConstants.refreshTokenKey, value: refreshToken),
      _storage.write(key: AppConstants.isLoggedInKey, value: 'true'),
    ]);
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: AppConstants.accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: AppConstants.refreshTokenKey);
  }

  static Future<bool> isLoggedIn() async {
    final isLoggedIn = await _storage.read(key: AppConstants.isLoggedInKey);
    return isLoggedIn == 'true';
  }

  // User Data Management
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _storage.write(
      key: AppConstants.userDataKey,
      value: jsonEncode(userData),
    );
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final userData = await _storage.read(key: AppConstants.userDataKey);
    if (userData != null) {
      return jsonDecode(userData);
    }
    return null;
  }

  // Clear All Data
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Clear Tokens Only
  static Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: AppConstants.accessTokenKey),
      _storage.delete(key: AppConstants.refreshTokenKey),
      _storage.delete(key: AppConstants.isLoggedInKey),
    ]);
  }

  // Generic Storage Methods
  static Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  static Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  static Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }
}