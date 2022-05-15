import 'package:flutter_test/flutter_test.dart';
import 'package:unruffled/unruffled.dart';

import '../../_support/setup.dart';
import '../../models/user.dart';

RemoteRepository<User> get repository => unruffled.repository<User>();

void main() async {
  setUp(setUpFn);
  tearDown(tearDownFn);

  final users = [
    User(id: 1, name: 'John', surname: 'Doe', age: 20),
    User(id: 2, name: 'Jane', surname: 'Doe', age: 22),
    User(id: 3, name: 'Betty', surname: 'Kim', age: 45),
    User(id: 4, name: 'Betty', surname: 'Hilton', age: 45),
    User(id: 5, name: 'Cyrus', surname: 'Nichols', age: 30),
  ];

  test('Add test users', () async {
    for (final user in users) {
      var route = repository.url(method: RequestMethod.post);
      dioAdapter.onPost(route, (server) {
        return server.reply(200, user);
      });
      await repository.post(model: user);
    }
  });

  group('Query builders', () {
    test('Equality', () async {
      var users = await repository.getAll(
        local: true,
        queryBuilder: QueryBuilder(
          filterGroup: FilterGroup.and(
            filters: [
              FilterCondition.equal(property: UserField.name(), value: 'Betty')
            ],
          ),
        ),
      );
      expect(users?.length, 2);
    });

    test('And', () async {
      var users = await repository.getAll(
        local: true,
        queryBuilder: QueryBuilder(
          filterGroup: FilterGroup.and(
            filters: [
              FilterCondition.equal(property: UserField.name(), value: 'Betty'),
              FilterCondition.equal(
                  property: UserField.surname(), value: 'Hilton')
            ],
          ),
        ),
      );
      expect(users?.length, 1);
    });

    test('Not equal', () async {
      var users = await repository.getAll(
        local: true,
        queryBuilder: QueryBuilder(
          filterGroup: FilterGroup.and(
            filters: [
              FilterCondition.notEqual(
                  property: UserField.name(), value: 'Cyrus'),
              FilterCondition.equal(
                  property: UserField.surname(), value: 'Nichols'),
            ],
          ),
        ),
      );
      expect(users?.length, 0);
    });

    test('Or', () async {
      var users = await repository.getAll(
        local: true,
        queryBuilder: QueryBuilder(
          filterGroup: FilterGroup.or(
            filters: [
              FilterCondition.equal(property: UserField.name(), value: 'Betty'),
              FilterCondition.equal(
                  property: UserField.surname(), value: 'Nichols'),
            ],
          ),
        ),
      );
      expect(users?.length, 3);
    });

    test('Greater than', () async {
      var users = await repository.getAll(
        local: true,
        queryBuilder: QueryBuilder(
          filterGroup: FilterGroup.and(
            filters: [
              FilterCondition.greaterThan(property: UserField.age(), value: 22),
            ],
          ),
        ),
      );
      expect(users?.length, 3);
    });

    test('Greater than or equal', () async {
      var users = await repository.getAll(
        local: true,
        queryBuilder: QueryBuilder(
          filterGroup: FilterGroup.and(
            filters: [
              FilterCondition.greaterThan(
                property: UserField.age(),
                value: 22,
                include: true,
              ),
            ],
          ),
        ),
      );
      expect(users?.length, 4);
    });

    test('Lower than', () async {
      var allUsers = await repository.getAll(local: true);
      var users = await repository.getAll(
        local: true,
        queryBuilder: QueryBuilder(
          filterGroup: FilterGroup.and(
            filters: [
              FilterCondition.lowerThan(
                property: UserField.age(),
                value: 30,
              ),
            ],
          ),
        ),
      );
      expect(users?.length, (allUsers?.length ?? 0) - 3);
    });

    test('Lower than or equal', () async {
      var allUsers = await repository.getAll(local: true);
      var users = await repository.getAll(
        local: true,
        queryBuilder: QueryBuilder(
          filterGroup: FilterGroup.and(
            filters: [
              FilterCondition.lowerThan(
                property: UserField.age(),
                value: 30,
                include: true,
              ),
            ],
          ),
        ),
      );
      expect(users?.length, (allUsers?.length ?? 0) - 2);
    });
  });
}
