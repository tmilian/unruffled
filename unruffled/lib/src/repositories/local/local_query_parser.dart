part of unruffled;

abstract class LocalQueryParser<T, R extends DataModel> {
  late T Function(List<T> data) orParser;
  late T Function(List<T> data) andParser;

  T parse({
    required T data,
    required QueryBuilder<R> queryBuilder,
    required T Function(List<T> data) orParser,
    required T Function(List<T> data) andParser,
  }) {
    this.orParser = orParser;
    this.andParser = andParser;
    final filterGroup = queryBuilder.filterGroup;
    final sort = queryBuilder.sort;
    final limit = queryBuilder.limit;
    final page = queryBuilder.page;
    if (filterGroup != null) {
      data = parseOperation(filterGroup, data);
    }
    if (sort != null) {
      data = parseSort(sort, data);
    }
    if (limit != null) {
      data = parsePagination(limit, page ?? 1, data);
    }
    return data;
  }

  T parseOperation(FilterOperation<R> operation, T object) {
    if (operation is FilterGroup<R>) {
      switch (operation.type) {
        case FilterGroupType.and:
          object = parseAndCondition(operation.filters, object);
          break;
        case FilterGroupType.or:
          object = parseOrCondition(operation.filters, object);
          break;
      }
    } else if (operation is FilterCondition<R>) {
      switch (operation.type) {
        case ConditionType.equal:
          object = parseEqual(operation, object);
          break;
        case ConditionType.notEqual:
          object = parseNotEqual(operation, object);
          break;
        case ConditionType.gt:
          object = parseGreaterThan(operation, object);
          break;
        case ConditionType.lt:
          object = parseLessThan(operation, object);
          break;
        case ConditionType.inRange:
          object = parseInValues(operation, object);
          break;
      }
    }
    return object;
  }

  T parsePagination(int limit, int page, T object);

  T parseSort(SortCondition<R> sort, T object);

  T parseEqual(FilterCondition<R> condition, T object);

  T parseNotEqual(FilterCondition<R> condition, T object);

  T parseGreaterThan(FilterCondition<R> condition, T object);

  T parseLessThan(FilterCondition<R> condition, T object);

  T parseInValues(FilterCondition<R> condition, T object);

  T parseOrCondition(List<FilterOperation<R>> operations, T object) {
    final list = operations
        .map(
          (operation) => parseOperation(operation, object),
        )
        .toList();
    return orParser.call(list);
  }

  T parseAndCondition(List<FilterOperation<R>> operations, T object) {
    final list = operations
        .map(
          (operation) => parseOperation(operation, object),
        )
        .toList();
    return andParser.call(list);
  }

  dynamic getProperty(String property, Map<String, dynamic> map) {
    final propNames = property.split('.');
    for (var prop in propNames) {
      final result = map[prop];
      if (result is Map) {
        map = map[prop];
      } else {
        return result;
      }
    }
    return map;
  }
}
