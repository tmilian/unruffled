import 'dart:io';

import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:unruffled/unruffled.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';

import 'models/book.dart';
import 'models/user.dart';

class Post {}

void main() async {
  final hiveDir = '${Directory.current.path}/test/hive';
  Dio dio = Dio();
  DioAdapter dioAdapter = DioAdapter(dio: dio);

  /// Ensure that there are no hive boxes
  await Directory(hiveDir).delete(recursive: true);
  await Future.delayed(Duration(milliseconds: 500));

  /// Create Unruffled instance
  final unruffled = await Unruffled(
          baseDirectory: hiveDir,
          defaultBaseUrl: 'http://example.com',
          dio: dio)
      .registerAdapter(UserAdapter())
      .registerAdapter(BookAdapter())
      .init();

  group('GET', () {
    final testUser = User(
      id: 143,
      name: 'John',
      surname: 'Doe',
    );
    RemoteRepository<User> remote = unruffled.repository<User>();

    test('Remote only resource available', () async {
      var route = remote.url(
        method: RequestMethod.GET,
        pathParams: {'id': '${testUser.id}'},
      );
      dioAdapter.onGet(route, (server) {
        return server.reply(200, testUser.toJson());
      });
      var user = await remote.get(
        key: testUser.id.toString(),
      );
      expect(user?.id, testUser.id);
    });

    test('Local resource available', () async {
      var user = await remote.get(key: testUser.id.toString(), local: true);
      expect(user?.id, testUser.id);
    });

    test('Remote & Local available', () async {
      var route = remote.url(
        method: RequestMethod.GET,
        pathParams: {'id': '${testUser.id}'},
      );
      dioAdapter.onGet(route, (server) {
        return server.reply(200, testUser.toJson());
      });
      var user = await remote.get(key: testUser.id.toString());
      expect(user?.id, testUser.id);
    });

    test('Remote unavailable', () async {
      var route = remote.url(
        method: RequestMethod.GET,
        pathParams: {'id': '${testUser.id}'},
      );
      dioAdapter.onGet(route, (server) {
        return server.reply(404, 'Not found');
      });
      expect(() async {
        await remote.get(key: testUser.id.toString());
      }, throwsA(isA<DataException>()));
    });

    test('Local unavailable', () async {
      expect(() async {
        await remote.get(key: testUser.id.toString(), local: true);
      }, throwsA(isA<DataException>()));
    });
  });
}
