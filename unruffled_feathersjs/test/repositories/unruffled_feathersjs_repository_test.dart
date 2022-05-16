import 'package:test/test.dart';
import 'package:unruffled/unruffled.dart';
import 'package:unruffled_feathersjs/unruffled_feathersjs.dart';

import '../_support/setup.dart';
import '../models/book.dart';

FeathersJsRemoteRepository<Book> get repository =>
    unruffled.repository<Book>() as FeathersJsRemoteRepository<Book>;

void main() async {
  setUp(setUpFn);
  tearDown(tearDownFn);

  test('Repository Initialized', () {
    expect(repository.isInitialized, isTrue);
  });

  group('Query builders', () {
    test('Remote filters builder', () async {
      final map = repository.parseQuery(
        queryBuilder: QueryBuilder(
          limit: 10,
          page: 1,
          sort: SortCondition(property: BookField.pages(), sort: SortType.asc),
          filterGroup: FilterGroup.and(
            filters: [
              FilterCondition.equal(property: BookField.pages(), value: 20),
              FilterCondition.equal(
                property: BookField.createdAt(),
                value: DateTime(2022, 01, 01).millisecondsSinceEpoch,
              ),
              FilterCondition.inRange(
                property: BookField.pages(),
                values: [23, 25, 28],
              ),
              FilterGroup.or(
                filters: [
                  FilterCondition.inRange(
                    property: BookField.pages(),
                    values: [23, 25, 28],
                  ),
                  FilterCondition.greaterThan(
                    property: BookField.createdAt(),
                    value: DateTime(2022, 01, 01).millisecondsSinceEpoch,
                  ),
                  FilterCondition.equal(property: BookField.pages(), value: 20),
                ],
              ),
            ],
          ),
        ),
      );
      expect(map, {
        'pages': 20,
        'createdAt': 1640991600000,
        'pages[\$in][0]': 23,
        'pages[\$in][1]': 25,
        'pages[\$in][2]': 28,
        '\$or[0][pages][\$in][0]': 23,
        '\$or[0][pages][\$in][1]': 25,
        '\$or[0][pages][\$in][2]': 28,
        '\$or[1][createdAt][\$gt]': 1640991600000,
        '\$or[2][pages]': 20,
        '\$sort[pages]': 1,
        '\$limit': 10,
        '\$skip': 1
      });
    });
  });
}
