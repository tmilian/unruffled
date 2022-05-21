import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:unruffled_feathersjs/unruffled_feathersjs.dart';

import '../models/book.dart';

late DioAdapter dioAdapter;
late UnruffledFeathersJs unruffled;

void setUpFn() async {
  final hiveDir = '${Directory.current.path}/test/hive';

  /// Create Unruffled instance
  unruffled = UnruffledFeathersJs(
    baseDirectory: hiveDir,
    defaultBaseUrl: 'http://example.com',
    tokenStorage: MockTokenStorage(),
  );
  await unruffled.registerRepository(BookRepository()).init();

  Dio dio = GetIt.I.get();
  dioAdapter = DioAdapter(dio: dio);
}

void tearDownFn() async {
  await unruffled.dispose();
}

class MockTokenStorage implements TokenStorage {
  String _accessToken = '';
  String _refreshToken = '';
  Map<String, dynamic> _user = {};

  @override
  Future<String?> getAccessToken() async => _accessToken;

  @override
  Future<String?> getRefreshToken() async => _refreshToken;

  @override
  Future<void> setAccessToken({required String token}) async =>
      _accessToken = token;

  @override
  Future<void> setRefreshToken({required String token}) async =>
      _refreshToken = token;

  @override
  Future<Map<String, dynamic>?> getUser() async => _user;

  @override
  Future<void> setUser({required Map<String, dynamic> user}) async =>
      _user = user;
}
