import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:unruffled_feathersjs/src/storage/token_storage.dart';

class DefaultTokenStorageImpl implements TokenStorage {
  const DefaultTokenStorageImpl();

  static const String accessTokenKey = "ACCESS_TOKEN";
  static const String refreshTokenKey = "REFRESH_TOKEN";
  static const String userKey = "USER";

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  Future<void> setAccessToken({required String token}) async {
    await _storage.write(key: accessTokenKey, value: token);
  }

  @override
  Future<String?> getAccessToken() async {
    return await _storage.read(key: accessTokenKey);
  }

  @override
  Future<void> setRefreshToken({required String token}) async {
    await _storage.write(key: refreshTokenKey, value: token);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: refreshTokenKey);
  }

  @override
  Future<Map<String, dynamic>?> getUser() async {
    var user = await _storage.read(key: userKey);
    return user != null ? jsonDecode(user) : null;
  }

  @override
  Future<void> setUser({required Map<String, dynamic> user}) async {
    await _storage.write(key: userKey, value: jsonEncode(user));
  }
}
