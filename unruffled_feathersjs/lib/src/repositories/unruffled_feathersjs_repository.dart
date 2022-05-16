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
        var deserialized = deserialize(data);
        for (var model in deserialized.models) {
          await localRepository.save(model.key, model);
        }
        var models = deserialized.models;
        if (data is Map &&
            data.containsKey('total') &&
            data.containsKey('limit') &&
            data.containsKey('skip')) {
          return Paginate(
            total: data['total'],
            limit: data['limit'],
            skip: data['skip'],
            data: models,
          );
        }
        return Paginate(
          total: models.length,
          limit: models.length,
          skip: 0,
          data: models,
        );
      },
      onError: (e) => throw e,
      onOfflineException: () async {
        onOfflineException?.call();
        return await getAllPaginated(local: true, queryBuilder: queryBuilder);
      },
    );
  }

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
