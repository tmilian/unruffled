part of unruffled_feathersjs;

mixin FeathersJsRemoteRepository<T extends DataModel<T>>
    on RemoteRepository<T> {
  Future<Paginate<T>?> getAllPaginated({
    String? path,
    bool local = false,
    Map<String, String>? headers,
    Map<String, dynamic>? query,
    QueryBuilder<T>? queryBuilder,
    OfflineExceptionCallback? onOfflineException,
    String listKey = 'data',
    String totalKey = 'total',
    String limitKey = 'limit',
    String pageKey = 'skip',
  }) async {
    if (queryBuilder != null) {
      query?.addAll(parseQuery(queryBuilder: queryBuilder));
    }
    if (local) {
      int limit = queryBuilder?.limit ?? 0;
      int skip = queryBuilder?.page ?? 0;
      var list = await localRepository.getAll(queryBuilder: queryBuilder);
      return Paginate(
        total: 0,
        limit: limit,
        skip: skip,
        data: list,
      );
    }
    return await sendRequest(
      url: path ?? url(method: RequestMethod.get),
      method: RequestMethod.get,
      headers: headers,
      query: query,
      onSuccess: (data) async {
        if (data is Map &&
            data.containsKey(listKey) &&
            data.containsKey(totalKey) &&
            data.containsKey(limitKey) &&
            data.containsKey(pageKey)) {
          var deserialized = deserialize(data[listKey]);
          for (var model in deserialized.models) {
            await localRepository.save(model.key, model);
          }
          var models = deserialized.models;
          return Paginate(
            total: data[totalKey],
            limit: data[limitKey],
            skip: data[pageKey],
            data: models,
          );
        }
        throw ('Response bad format');
      },
      onError: (e) => throw e,
      onOfflineException: () async {
        onOfflineException?.call();
        return await getAllPaginated(local: true, queryBuilder: queryBuilder);
      },
    );
  }

  @override
  Map<String, dynamic> parseLimit(int limit) => {'\$limit': limit};

  @override
  Map<String, dynamic> parsePage(int page) => {'\$skip': page};

  @override
  Map<String, dynamic> parseSort(SortCondition sort) =>
      {'\$sort[${sort.property.property}]': sort.sort == SortType.asc ? 1 : -1};

  @override
  Map<String, dynamic> parseEqual(FilterCondition<T> condition) =>
      {condition.property.property: condition.value};

  @override
  Map<String, dynamic> parseNotEqual(FilterCondition<T> condition) =>
      {'${condition.property.property}[\$ne]': condition.value};

  @override
  Map<String, dynamic> parseGreaterThan(FilterCondition<T> condition) => {
        '${condition.property.property}[${condition.include ? '\$gte' : '\$gt'}]':
            condition.value
      };

  @override
  Map<String, dynamic> parseLessThan(FilterCondition<T> condition) => {
        '${condition.property.property}[${condition.include ? '\$lte' : '\$lt'}]':
            condition.value
      };

  @override
  Map<String, dynamic> parseInValues(FilterCondition<T> condition) {
    return condition.values.asMap().map((key, value) => MapEntry(
          '${condition.property.property}[\$in][$key]',
          value,
        ));
  }

  @override
  Map<String, dynamic> parseOrCondition(List<FilterOperation<T>> operations) {
    Map<String, dynamic> map = {};
    for (var i = 0; i < operations.length; i++) {
      map.addAll(parseOperation(operations[i]).map((key, value) {
        final index = key.indexOf('[');
        if (index != -1) {
          key =
              '[${key.substring(0, index)}]${key.substring(index, key.length)}';
        } else {
          key = '[$key]';
        }
        return MapEntry('\$or[$i]$key', value);
      }));
    }
    return map;
  }

  @override
  Map<String, dynamic> parseAndCondition(List<FilterOperation<T>> operations) {
    Map<String, dynamic> map = {};
    for (var operation in operations) {
      map.addAll(parseOperation(operation));
    }
    return map;
  }
}
