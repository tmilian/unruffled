import 'package:unruffled/unruffled.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:collection/collection.dart';

import '../../_support/setup.dart';
import '../../models/user.dart';

RemoteRepository<User> get repository => unruffled.repository<User>();

void main() async {
  setUp(setUpFn);
  tearDown(tearDownFn);

  test('Repository Initialized', () {
    expect(repository.isInitialized, isTrue);
  });

  group('GET', () {
    final testUser = User(
      id: 143,
      name: 'John',
      surname: 'Doe',
    );

    test('Remote only - Resource available', () async {
      var route = repository.url(
        method: RequestMethod.get,
        pathParams: {'id': '${testUser.id}'},
      );
      dioAdapter.onGet(route, (server) {
        return server.reply(200, testUser.toJson());
      });
      var user = await repository.get(
        key: testUser.id.toString(),
      );
      expect(user?.id, testUser.id);
    });

    test('Local only - Resource available', () async {
      var user = await repository.get(key: testUser.id.toString(), local: true);
      expect(user?.id, testUser.id);
    });

    test('Remote & Local - Resource available', () async {
      var route = repository.url(
        method: RequestMethod.get,
        pathParams: {'id': '${testUser.id}'},
      );
      dioAdapter.onGet(route, (server) {
        return server.reply(200, testUser.toJson());
      });
      var user = await repository.get(key: testUser.id.toString());
      expect(user?.id, testUser.id);
    });

    test('Remote only - Resource unavailable', () async {
      var route = repository.url(
        method: RequestMethod.get,
        pathParams: {'id': '${testUser.id}'},
      );
      dioAdapter.onGet(route, (server) {
        return server.reply(404, 'Not found');
      });
      expect(() async {
        await repository.get(key: testUser.id.toString());
      }, throwsA(isA<DataException>()));
    });

    test('Local only - Resource unavailable', () async {
      expect(() async {
        await repository.get(key: testUser.id.toString(), local: true);
      }, throwsA(isA<DataException>()));
    });
  });

  group('POST', () {
    final testUser = User(
      name: 'Jane',
      surname: 'Doe',
    );
    var testUserId = 200;

    group('Server success', () {
      test('Create user', () async {
        // Create remote user
        var route = repository.url(method: RequestMethod.post);
        dioAdapter.onPost(route, (server) {
          return server.reply(
              200,
              User(
                id: testUserId,
                name: testUser.name,
                surname: testUser.surname,
              ));
        });
        var user = await repository.post(model: testUser);
        print('Remote model ${user.toJson()}');
        expect(user.id, testUserId);
      });

      test('Check user synced in local', () async {
        // Check if remote user has been synced in local
        var localUser = await repository.get(key: testUserId, local: true);
        print('Local model ${localUser?.toJson()}');
        expect(localUser?.id, testUserId);
      });
    });

    group('Server error', () {
      test('Create user', () async {
        // Fail to create a user due to server error
        var route = repository.url(method: RequestMethod.post);
        dioAdapter.onPost(route, (server) {
          return server.reply(500, 'Internal server error');
        });
        expect(() async {
          await repository.post(model: testUser);
        }, throwsA(isA<DataException>()));
        print((await repository.getAll(local: true))?.map((e) => e.toJson()));
      });

      test('Check offline operations is empty', () async {
        // Check that no offline operations has been added
        expect(repository.offlineOperations.isEmpty, isTrue);
      });
    });

    group('Connectivity error', () {
      test('Create user', () async {
        // Fail to create a user due to connectivity error
        var route = repository.url(method: RequestMethod.post);
        dioAdapter.onPost(route, (server) {
          return server.throws(
            504,
            DioError(
              requestOptions: RequestOptions(path: route),
              error: 'Connection closed before full header was received',
            ),
          );
        });
        var user = await repository.post(model: testUser);
        expect(user.key.startsWith('temp@'), isTrue);
      });

      test('Check offline operation has been added', () async {
        var operations = repository.offlineOperations;
        var localUser = await repository.get(key: testUser.key, local: true);
        expect(operations.firstWhereOrNull((e) => e.modelKey == localUser?.key),
            isNotNull);
        expect(operations.length, 1);
      });

      test('Fail to retry offline operation', () async {
        var operation = repository.offlineOperations.first;
        var route = repository.url(method: RequestMethod.post);
        dioAdapter.onPost(route, (server) {
          return server.throws(
            504,
            DioError(
              requestOptions: RequestOptions(path: route),
              error: 'Connection closed before full header was received',
            ),
          );
        });
        await operation.retry(repository);
        var localUser = await repository.get(key: testUser.key, local: true);
        expect(
          repository.offlineOperations.firstWhereOrNull(
            (e) => e.modelKey == localUser?.key,
          ),
          isNotNull,
        );
        expect(repository.offlineOperations.length, 1);
      });

      test('Succeed to retry offline operation', () async {
        var operation = repository.offlineOperations.first;
        var route = repository.url(method: RequestMethod.post);
        dioAdapter.onPost(route, (server) {
          return server.reply(
            200,
            User(
              id: testUserId,
              name: testUser.name,
              surname: testUser.surname,
            ),
          );
        });
        await operation.retry(repository);
        expect(repository.offlineOperations.length, 0);
      });
    });
  });

  group('PUT', () {
    final testUser = User(
      name: 'Jane',
      surname: 'Doe',
    );
    var testUserId = 300;

    group('Remote synced model', () {
      group('Request succeed', () {
        test('Request', () async {
          // Create remote user
          var route = repository.url(
            method: RequestMethod.put,
            pathParams: {'id': '$testUserId'},
          );
          dioAdapter.onPut(route, (server) {
            return server.reply(
              200,
              User(
                id: testUserId,
                name: testUser.name,
                surname: testUser.surname,
              ),
            );
          });
          var user = await repository.put(
            model: User(
              id: testUserId,
              name: testUser.name,
              surname: testUser.surname,
            ),
          );
          print('Remote model ${user.toJson()}');
          expect(user.id, testUserId);
        });

        test('Check user synced in local', () async {
          // Check if remote user has been synced in local
          var localUser = await repository.get(key: testUserId, local: true);
          print('Local model ${localUser?.toJson()}');
          expect(localUser?.id, testUserId);
        });
      });

      group('Request failed', () {
        test('Request', () async {
          // Create remote user
          var route = repository.url(
            method: RequestMethod.put,
            pathParams: {'id': '$testUserId'},
          );
          dioAdapter.onPut(route, (server) {
            return server.reply(500, 'Internal server error');
          });
          expect(() async {
            await repository.put(
              model: User(
                id: testUserId,
                name: testUser.name,
                surname: testUser.surname,
              ),
            );
          }, throwsA(isA<DataException>()));
        });

        test('Check user synced in local', () async {
          // Check if remote user has been synced in local
          var localUser = await repository.get(key: testUserId, local: true);
          print('Local model ${localUser?.toJson()}');
          expect(localUser?.id, testUserId);
        });
      });

      group('Connectivity error', () {
        test('Request', () async {
          // Create remote user
          var route = repository.url(
            method: RequestMethod.put,
            pathParams: {'id': '$testUserId'},
          );
          dioAdapter.onPut(route, (server) {
            return server.throws(
              504,
              DioError(
                requestOptions: RequestOptions(path: route),
                error: 'Connection closed before full header was received',
              ),
            );
          });
          var user = await repository.put(
            model: User(
              id: testUserId,
              name: testUser.name,
              surname: testUser.surname,
            ),
          );
          expect(user.id, testUserId);
        });

        test('Check offline operation has been added', () async {
          // Check that no offline operations has been added
          var operations = repository.offlineOperations;
          var localUser = await repository.get(key: testUserId, local: true);
          expect(
              operations.firstWhereOrNull((e) =>
                  e.modelKey == localUser?.key &&
                  e.type == OfflineOperationType.put),
              isNotNull);
          expect(operations.length, 1);
        });

        test('Fail to retry offline operation', () async {
          var operation = repository.offlineOperations.firstWhere(
              (element) => element.type == OfflineOperationType.put);
          var route = repository.url(
            method: RequestMethod.put,
            pathParams: {'id': '$testUserId'},
          );
          dioAdapter.onPut(route, (server) {
            return server.throws(
              504,
              DioError(
                requestOptions: RequestOptions(path: route),
                error: 'Connection closed before full header was received',
              ),
            );
          });
          await operation.retry(repository);
          var localUser = await repository.get(key: testUserId, local: true);
          expect(
            repository.offlineOperations.firstWhereOrNull(
              (e) => e.modelKey == localUser?.key,
            ),
            isNotNull,
          );
          expect(repository.offlineOperations.length, 1);
        });

        test('Succeed to retry offline operation', () async {
          var operation = repository.offlineOperations.firstWhere(
              (element) => element.type == OfflineOperationType.put);
          var route = repository.url(
            method: RequestMethod.put,
            pathParams: {'id': '$testUserId'},
          );
          dioAdapter.onPut(route, (server) {
            return server.reply(
              200,
              User(
                id: testUserId,
                name: testUser.name,
                surname: testUser.surname,
              ),
            );
          });
          await operation.retry(repository);
          expect(repository.offlineOperations.length, 0);
        });
      });
    });

    group('Remote non-synced model', () {
      test('Edit model', () async {
        var user = await repository.put(model: testUser);
        print('Remote model ${user.toJson()}');
        expect(testUser.key, user.key);
      });

      test('Check no offline operation has been added', () async {
        // Check that no offline operations has been added
        var operations = repository.offlineOperations;
        var localUser = await repository.get(key: testUser.key, local: true);
        expect(operations.firstWhereOrNull((e) => e.modelKey == localUser?.key),
            isNull);
      });
    });
  });
}
