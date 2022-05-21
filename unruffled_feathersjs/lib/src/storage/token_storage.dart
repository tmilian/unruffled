part of unruffled_feathersjs;

abstract class TokenStorage {
  Future<void> setAccessToken({required String token});

  Future<String?> getAccessToken();

  Future<void> setRefreshToken({required String token});

  Future<String?> getRefreshToken();

  Future<void> setUser({required Map<String, dynamic> user});

  Future<Map<String, dynamic>?> getUser();
}
