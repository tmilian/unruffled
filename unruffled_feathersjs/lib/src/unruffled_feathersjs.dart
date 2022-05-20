import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:unruffled/unruffled.dart';
import 'package:unruffled_feathersjs/src/storage/token_storage.dart';

class UnruffledFeathersJs extends Unruffled {
  UnruffledFeathersJs({
    required super.baseDirectory,
    required super.defaultBaseUrl,
    super.defaultHeaders,
    super.encryptionKey,
    super.dio,
    required this.tokenStorage,
    bool useRefreshToken = true,
    this.authenticationUrl = '/authentication',
  }) : assert(authenticationUrl.startsWith('http') ||
            authenticationUrl.startsWith('/')) {
    Dio dio = GetIt.I.get();
    if (!authenticationUrl.startsWith('http')) {
      authenticationUrl = dio.options.baseUrl + authenticationUrl;
    }
    dio.interceptors.add(
      InterceptorsWrapper(onRequest: (options, handler) async {
        var token = await tokenStorage.getAccessToken();
        options.headers["Authorization"] = "Bearer $token";
        return handler.next(options);
      }, onResponse: (response, handler) {
        return handler.next(response);
      }, onError: (DioError error, handler) async {
        if (error.response?.statusCode == 401 &&
            error.requestOptions.path != authenticationUrl) {
          dio.lock();
          dio.interceptors.requestLock.lock();
          try {
            await refreshToken(dio);
          } catch (e) {
            print(e);
          }
          String? accessToken = await tokenStorage.getAccessToken();
          var requestOptions = error.requestOptions;
          requestOptions.headers['Authorization'] = 'Bearer $accessToken';
          final opts = Options(method: requestOptions.method);
          final response = await dio.request(
            '${error.requestOptions.baseUrl}/${requestOptions.path}',
            options: opts,
            cancelToken: requestOptions.cancelToken,
            onReceiveProgress: requestOptions.onReceiveProgress,
            data: requestOptions.data,
            queryParameters: requestOptions.queryParameters,
          );
          dio.unlock();
          dio.interceptors.requestLock.unlock();
          return handler.resolve(response);
        }
        return handler.next(error);
      }),
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
    if (resp.data['accessToken'] != null) {
      await tokenStorage.setAccessToken(token: resp.data['accessToken']);
    }
    if (resp.data['refreshToken'] != null) {
      await tokenStorage.setRefreshToken(token: resp.data['refreshToken']);
    }
    if (resp.data['user'] != null) {
      await tokenStorage.setUser(user: resp.data['user']);
    }
    return resp.data;
  }

  Future<Map<String, dynamic>> refreshToken(Dio dio) async {
    var refreshToken = await tokenStorage.getRefreshToken();
    var response = await dio.post(
      authenticationUrl,
      data: {
        "refreshToken": refreshToken,
        "action": "refresh",
      },
    );
    if (response.data['accessToken'] != null) {
      await tokenStorage.setAccessToken(token: response.data['accessToken']);
    }
    if (response.data['refreshToken'] != null) {
      await tokenStorage.setRefreshToken(
        token: response.data['refreshToken'],
      );
    }
    if (response.data['user'] != null) {
      await tokenStorage.setUser(user: response.data['user']);
    }
    return response.data;
  }
}
