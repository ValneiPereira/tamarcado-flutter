import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Access Token
  Future<void> saveAccessToken(String token) =>
      _storage.write(key: AppConstants.accessTokenKey, value: token);

  Future<String?> getAccessToken() =>
      _storage.read(key: AppConstants.accessTokenKey);

  Future<void> removeAccessToken() =>
      _storage.delete(key: AppConstants.accessTokenKey);

  // Refresh Token
  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: AppConstants.refreshTokenKey, value: token);

  Future<String?> getRefreshToken() =>
      _storage.read(key: AppConstants.refreshTokenKey);

  // User
  Future<void> saveUser(Map<String, dynamic> user) =>
      _storage.write(key: AppConstants.userKey, value: jsonEncode(user));

  Future<Map<String, dynamic>?> getUser() async {
    final str = await _storage.read(key: AppConstants.userKey);
    if (str == null) return null;
    return jsonDecode(str) as Map<String, dynamic>;
  }

  // Clear All
  Future<void> clearAll() => _storage.deleteAll();
}
