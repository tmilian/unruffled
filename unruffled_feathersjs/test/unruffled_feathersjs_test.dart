import 'package:flutter/widgets.dart';
import 'package:test/test.dart';
import 'package:unruffled/unruffled.dart';

import '_support/setup.dart';
import 'models/book.dart';

void main() async {
  setUp(setUpFn);
  tearDown(tearDownFn);
  tearDownAll(tearDownAllFn);

  WidgetsFlutterBinding.ensureInitialized();

  final accessToken = "accessToken1";
  final refreshToken = "refreshToken1";
  final newAccessToken = "accessToken2";
  final newRefreshToken = "refreshToken2";

  test('Authenticate', () async {
    final data = {
      "email": "test@test.com",
      "password": "test123",
      "strategy": "local",
    };
    dioAdapter.onPost(unruffled.authenticationUrl, (server) {
      return server.reply(200, {
        "accessToken": accessToken,
        "refreshToken": refreshToken,
        "authentication": {"strategy": "local"},
      });
    }, data: data);
    var result = await unruffled.authenticate(body: data);
    expect(result["accessToken"], accessToken);
  });

  test('Refresh Token', () async {
    unruffled.tokenStorage.setRefreshToken(token: refreshToken);
    final route = unruffled.repository<Book>().url(method: RequestMethod.get);
    dioAdapter.onGet(route, (server) async {
      return server.reply(401, 'Not Authenticated');
    });
    dioAdapter.onGet(route, (server) {
      return server.reply(200, [
        {
          'id': 1,
          'title': 'berv',
          'pages': 300,
          'createdAt': '10432044',
        },
        {
          'id': 2,
          'title': 'dgsgsg',
          'pages': 450,
          'createdAt': '10432044',
        }
      ]);
    }, headers: {
      'Authorization': 'Bearer $newAccessToken',
    });
    dioAdapter.onPost(unruffled.authenticationUrl, (server) {
      return server.reply(200, {
        "accessToken": newAccessToken,
        "refreshToken": newRefreshToken,
      });
    }, data: {
      'action': 'refresh',
      'refreshToken': refreshToken,
    });
    await unruffled.repository<Book>().getAll();
    expect(await unruffled.tokenStorage.getAccessToken(), newAccessToken);
  });

  test('Refresh Token', () async {
    await unruffled.tokenStorage.setAccessToken(token: accessToken);
    await unruffled.tokenStorage.setRefreshToken(token: refreshToken);
    final route = unruffled.repository<Book>().url(method: RequestMethod.get);
    dioAdapter.onGet(route, (server) async {
      return server.reply(401, 'Not Authenticated');
    });
    dioAdapter.onGet(route, (server) {
      return server.reply(200, [
        {
          'id': 1,
          'title': 'berv',
          'pages': 300,
          'createdAt': '10432044',
        },
        {
          'id': 2,
          'title': 'dgsgsg',
          'pages': 450,
          'createdAt': '10432044',
        }
      ]);
    }, headers: {
      'Authorization': 'Bearer $newAccessToken',
    });
    dioAdapter.onPost(unruffled.authenticationUrl, (server) {
      return server.reply(200, {
        "accessToken": newAccessToken,
        "refreshToken": newRefreshToken,
      });
    }, data: {
      'action': 'refresh',
      'refreshToken': refreshToken,
    });
    await unruffled.repository<Book>().getAll();
    expect(await unruffled.tokenStorage.getAccessToken(), newAccessToken);
  });
}
