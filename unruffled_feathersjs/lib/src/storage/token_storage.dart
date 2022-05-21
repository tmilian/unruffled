part of unruffled_feathersjs;

abstract class TokenStorage {
  Future<void> setAccessToken({String? token});

  Future<String?> getAccessToken();

  Future<void> setRefreshToken({String? token});

  Future<String?> getRefreshToken();

  Future<void> setUser({Map<String, dynamic>? user});

  Future<Map<String, dynamic>?> getUser();
}
