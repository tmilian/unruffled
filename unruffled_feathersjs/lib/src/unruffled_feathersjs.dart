import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:unruffled/unruffled.dart';
import 'package:unruffled_feathersjs/src/storage/default_token_storage_impl.dart';
import 'package:unruffled_feathersjs/src/storage/token_storage.dart';

class UnruffledFeathersJs extends Unruffled {
  UnruffledFeathersJs({
    required super.baseDirectory,
    required super.defaultBaseUrl,
    super.defaultHeaders,
    super.encryptionKey,
    super.dio,
    this.tokenStorage = const DefaultTokenStorageImpl(),
    bool useRefreshToken = true,
    this.authenticationUrl = '/authentication',
  }) : assert(authenticationUrl.startsWith('http') ||
            authenticationUrl.startsWith('/')) {
    Dio dio = GetIt.I.get();
    if (!authenticationUrl.startsWith('http')) {
      authenticationUrl = dio.options.baseUrl + authenticationUrl;
    }
    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          var token = await tokenStorage.getAccessToken();
          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioError error, handler) async {
          final token = await tokenStorage.getRefreshToken();
          if (error.response?.statusCode == 401 &&
              error.requestOptions.path != authenticationUrl &&
              token != null) {
            try {
              await refreshToken(dio, token);
            } catch (e) {
              print(e);
            }
            String? accessToken = await tokenStorage.getAccessToken();
            final requestOptions = error.response!.requestOptions;
            requestOptions.headers['Authorization'] = 'Bearer $accessToken';
            final response = await dio.fetch(requestOptions);
            return handler.resolve(response);
          }
          return handler.next(error);
        },
      ),
    );
    GetIt.I.unregister<Dio>();
    GetIt.I.registerSingleton(dio);
  }

  final TokenStorage tokenStorage;

  String authenticationUrl;

  Future<Map<String, dynamic>> authenticate({
    Map<String, String>? headers,
    required Map<String, dynamic> body,
  }) async {
    Dio dio = GetIt.I.get();
    var resp = await dio.post(authenticationUrl, data: body);
    await tokenStorage.setAccessToken(token: resp.data?['accessToken']);
    await tokenStorage.setRefreshToken(token: resp.data?['refreshToken']);
    await tokenStorage.setUser(user: resp.data?['user']);
    return resp.data;
  }

  Future<Map<String, dynamic>> refreshToken(
    Dio dio,
    String token,
  ) async {
    var response = await dio.post(
      authenticationUrl,
      data: {
        "refreshToken": token,
        "action": "refresh",
      },
    );
    await tokenStorage.setAccessToken(token: response.data?['accessToken']);
    await tokenStorage.setRefreshToken(token: response.data?['refreshToken']);
    await tokenStorage.setUser(user: response.data?['user']);
    return response.data;
  }
}
