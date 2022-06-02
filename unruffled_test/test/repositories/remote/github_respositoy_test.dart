import 'package:unruffled/unruffled.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_support/github_setup.dart';
import '../../models/github_user.dart';

RemoteRepository<GithubUser> get repository =>
    unruffled.repository<GithubUser>();

void main() async {
  setUp(setUpFn);
  tearDown(tearDownFn);
  tearDownAll(tearDownAllFn);

  test('Repository Initialized', () {
    expect(repository.isInitialized, isTrue);
  });

  group('GET ALL', () {
    int length = 0;
    test('Remote', () async {
      final results = await repository.getAll();
      length = results?.length ?? 0;
      expect(results?.isNotEmpty, isTrue);
    });

    test('Local', () async {
      final results = await repository.getAll(local: true);
      expect(results?.length, length);
    });
  });

  group('GET', () {
    String login = 'tmilian';

    test('Remote', () async {
      final user = await repository.get(key: login);
      expect(user?.key, login);
    });

    test('Local', () async {
      final user = await repository.get(key: login, local: true);
      expect(user?.key, login);
    });
  });
}
