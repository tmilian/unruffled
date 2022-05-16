part of unruffled;

class RemoteRepository<T extends DataModel<T>> = _RemoteRepository<T>
    with _RemoteQueryParser<T>;

abstract class _RemoteRepository<T extends DataModel<T>> {
  _RemoteRepository(this.dataAdapter) {
    localRepository = LocalRepositoryImpl<T>(dataAdapter: dataAdapter);
    offlineRepository = OfflineRepository<T>(dataAdapter: dataAdapter);
  }

  final Dio dio = GetIt.I.get();

  final DataAdapter<T> dataAdapter;

  @protected
  late LocalRepository<T> localRepository;

  @protected
  late OfflineRepository<T> offlineRepository;

  @protected
  String get serviceName => dataAdapter.serviceName;

  bool get isInitialized => _isInit;

  var _isInit = false;

  Future<RemoteRepository<T>> initialize() async {
    await localRepository.initialize();
    await offlineRepository.initialize();
    _isInit = true;
    return this as RemoteRepository<T>;
  }

  String url({
    required RequestMethod method,
    Map<String, dynamic>? pathParams,
  }) {
    switch (method) {
      case RequestMethod.get:
        return pathParams == null
            ? '/$serviceName'
            : '/$serviceName/${pathParams['id']}';
      case RequestMethod.post:
        return '/$serviceName';
      case RequestMethod.patch:
        return '/$serviceName/${pathParams?['id']}';
      case RequestMethod.put:
        return '/$serviceName/${pathParams?['id']}';
      case RequestMethod.delete:
        return '/$serviceName/${pathParams?['id']}';
    }
  }

  @protected
  DeserializedData<T> deserialize(Object? data, {String? key}) {
    final result = DeserializedData<T>([], included: []);
    if (data == null || data == '') {
      return result;
    }
    if (data is Map) {
      data = [data];
    }
    if (data is Iterable) {
      for (final obj in data) {
        final model = dataAdapter.deserialize(obj);
        if (model.id != null) {
          result.models.add(model);
        }
      }
    }
    return result;
  }

  @protected
  Map<String, dynamic> serialize(T model) {
    return dataAdapter.serialize(model);
  }

  /// Delete a model
  ///
  /// [key] is required (use your model.key)
  ///
  /// Delete local model by default and attempt to delete model on remote
  /// server.
  ///
  /// If a connectivity issue occurs :
  /// - When id is not null, create a DELETE offline operation to allow you to
  /// retry operation later.
  /// - When id is null, all offline operations related to this model are
  /// deleted to prevent server side object creation.
  ///
  Future<T?> delete({
    required String key,
    String? path,
    Map<String, String>? headers,
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
    OfflineExceptionCallback? onOfflineException,
  }) async {
    var model = await localRepository.delete(key);
    final offlineOperation = OfflineOperation<T>(
      type: OfflineOperationType.delete,
      modelKey: model?.key ?? '',
      path: path,
      headers: headers,
      query: query,
      body: body,
    );
    var isLocalModel = key.toString().startsWith(tempKey);
    if (isLocalModel) {
      await offlineRepository.save(offlineOperation);
      return model;
    }
    return await sendRequest(
      url: path ??
          url(method: RequestMethod.delete, pathParams: {'id': model?.id}),
      method: RequestMethod.delete,
      headers: headers,
      query: query,
      onSuccess: (data) async {
        var deserialized = deserialize(data);
        await offlineRepository.delete(offlineOperation);
        return deserialized.model;
      },
      onError: (e) async => _onError(e),
      onOfflineException: () async {
        onOfflineException?.call();
        await offlineRepository.save(offlineOperation);
        return model;
      },
    );
  }

  /// Get all objects
  ///
  Future<List<T>?> getAll({
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
      return await localRepository.getAll(queryBuilder: queryBuilder);
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
        return deserialized.models;
      },
      onError: (e) async => _onError(e),
      onOfflineException: () async {
        onOfflineException?.call();
        return await getAll(local: true);
      },
    );
  }

  /// GET specific object
  ///
  /// [key] is required (use your model.key)
  ///
  Future<T?> get({
    required Object key,
    String? path,
    bool local = false,
    Map<String, String>? headers,
    Map<String, dynamic>? query,
    OfflineExceptionCallback? onOfflineException,
  }) async {
    var isLocalModel = key.toString().startsWith(tempKey);
    T? model = isLocalModel
        ? await localRepository.get(key.toString())
        : await localRepository.getFromId(key);
    if (local || isLocalModel) {
      if (model == null) {
        await _onError(DataException('No ${T.toString()} model with key $key'));
      }
      return model;
    }
    return await sendRequest(
      url: path ??
          url(method: RequestMethod.get, pathParams: {'id': model?.id ?? key}),
      method: RequestMethod.get,
      headers: headers,
      query: query,
      onSuccess: (data) async {
        var deserialized = deserialize(data);
        var model = deserialized.model;
        if (model != null) {
          await localRepository.save(model.key, model);
        }
        return model;
      },
      onError: (e) async {
        if (model != null) {
          await localRepository.delete(model.key);
        }
        return _onError(e);
      },
      onOfflineException: () async {
        onOfflineException?.call();
        return model;
      },
    );
  }

  /// Create object
  ///
  /// [model] is required
  ///
  /// Create local [model] by default and attempt to create [model] on remote
  /// server.
  ///
  /// If a connectivity issue occurs, create on offline operation to allow you
  /// to retry operation later.
  ///
  Future<T> post({
    required T model,
    String? path,
    Map<String, String>? headers,
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
    bool remote = false,
    OfflineExceptionCallback? onOfflineException,
  }) async {
    final offlineOperation = OfflineOperation<T>(
      type: OfflineOperationType.post,
      modelKey: model.key,
      path: path,
      headers: headers,
      query: query,
      body: body,
    );
    await localRepository.save(model.key, model);
    var result = await sendRequest<T>(
      url: path ?? url(method: RequestMethod.post),
      method: RequestMethod.post,
      headers: headers,
      query: query,
      onSuccess: (data) async {
        var deserialized = deserialize(data);
        var newModel = deserialized.model;
        if (newModel != null) {
          await localRepository.delete(model.key);
          await localRepository.save(newModel.key, newModel);
        }
        await offlineRepository.delete(offlineOperation);
        return newModel;
      },
      onError: (e) async => _onError(e),
      onOfflineException: () async {
        onOfflineException?.call();
        await offlineRepository.save(offlineOperation);
        return model;
      },
    );
    return result ?? model;
  }

  /// Edit a model
  ///
  /// [model] is required
  ///
  /// Edit local model by default and attempt to edit model on remote
  /// server.
  ///
  /// If a connectivity issue occurs :
  /// - When id is not null, create a PUT offline operation to allow you to
  /// retry operation later.
  /// - When id is null, we attempt to modify an existing POST operation related
  /// to this [model] key.
  ///
  Future<T> put({
    required T model,
    String? path,
    Map<String, String>? headers,
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
    bool remote = false,
    OfflineExceptionCallback? onOfflineException,
  }) async {
    final offlineOperation = OfflineOperation<T>(
      type: OfflineOperationType.put,
      modelKey: model.key,
      path: path,
      headers: headers,
      query: query,
      body: body,
    );
    await localRepository.save(model.key, model);
    var isLocalModel = model.key.toString().startsWith(tempKey);
    if (isLocalModel) {
      await offlineRepository.save(offlineOperation);
      return model;
    }
    var result = await sendRequest<T>(
      url: path ??
          url(
              method: RequestMethod.put,
              pathParams: {'id': model.id.toString()}),
      method: RequestMethod.put,
      headers: headers,
      query: query,
      onSuccess: (data) async {
        var deserialized = deserialize(data);
        await offlineRepository.delete(offlineOperation);
        return deserialized.model;
      },
      onError: (e) async => _onError(e),
      onOfflineException: () async {
        onOfflineException?.call();
        await offlineRepository.save(offlineOperation);
        return model;
      },
    );
    return result ?? model;
  }

  /// Edit a model
  ///
  /// [model] is required
  ///
  /// Edit local model by default and attempt to edit model on remote
  /// server.
  ///
  /// If a connectivity issue occurs :
  /// - When id is not null, create a PUT offline operation to allow you to
  /// retry operation later.
  /// - When id is null, we attempt to modify an existing POST operation related
  /// to this [model] key.
  ///
  Future<T> patch({
    required T model,
    String? path,
    Map<String, String>? headers,
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
    bool remote = false,
    OfflineExceptionCallback? onOfflineException,
  }) async {
    final offlineOperation = OfflineOperation<T>(
      type: OfflineOperationType.patch,
      modelKey: model.key,
      path: path,
      headers: headers,
      query: query,
      body: body,
    );
    await localRepository.save(model.key, model);
    var isLocalModel = model.key.toString().startsWith(tempKey);
    if (isLocalModel) {
      await offlineRepository.save(offlineOperation);
      return model;
    }
    var result = await sendRequest<T>(
      url: path ??
          url(
              method: RequestMethod.patch,
              pathParams: {'id': model.id.toString()}),
      method: RequestMethod.patch,
      headers: headers,
      query: query,
      onSuccess: (data) async {
        var deserialized = deserialize(data);
        await offlineRepository.delete(offlineOperation);
        return deserialized.model;
      },
      onError: (e) async => _onError(e),
      onOfflineException: () async {
        onOfflineException?.call();
        await offlineRepository.save(offlineOperation);
        return model;
      },
    );
    return result ?? model;
  }

  Future<R?> sendRequest<R>({
    required String url,
    RequestMethod method = RequestMethod.get,
    Map<String, String>? headers,
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
    required OnSuccess<R> onSuccess,
    required OnError<R> onError,
    OnOfflineException<R>? onOfflineException,
  }) async {
    try {
      final response = await dio.fetch<Map<String, dynamic>>(
        Options(
          method: method.name,
          headers: headers,
          responseType: ResponseType.json,
        )
            .compose(dio.options, url, queryParameters: query, data: body)
            .copyWith(baseUrl: dio.options.baseUrl),
      );
      return onSuccess(response.data);
    } on DioError catch (e) {
      if (_isConnectivityError(e.error)) {
        return await onOfflineException?.call();
      } else {
        final dataException = DataException(e,
            stackTrace: e.stackTrace, statusCode: e.response?.statusCode);
        return await onError(dataException);
      }
    }
  }

  List<OfflineOperation> get offlineOperations {
    return offlineRepository.getAll();
  }

  FutureOr<R?> _onError<R>(DataException e) {
    throw e;
  }

  bool _isConnectivityError(Object? error) {
    // Try to detect connectivity error without importing dart:io
    final _err = error.toString();
    return _err.contains('SocketException') ||
        _err.contains('Connection closed before full header was received') ||
        _err.contains('HandshakeException');
  }

  Future<void> dispose() async {
    await localRepository.dispose();
  }

  Map<String, dynamic> parseQuery({required QueryBuilder<T> queryBuilder});

  Map<String, dynamic> parseLimit(int limit);

  Map<String, dynamic> parsePage(int page);

  Map<String, dynamic> parseSort(SortCondition<T> sort);

  Map<String, dynamic> parseOperation(FilterOperation<T> operation);

  Map<String, dynamic> parseEqual(FilterCondition<T> condition);

  Map<String, dynamic> parseNotEqual(FilterCondition<T> condition);

  Map<String, dynamic> parseGreaterThan(FilterCondition<T> condition);

  Map<String, dynamic> parseLessThan(FilterCondition<T> condition);

  Map<String, dynamic> parseInValues(FilterCondition<T> condition);

  Map<String, dynamic> parseOrCondition(List<FilterOperation<T>> operations);

  Map<String, dynamic> parseAndCondition(List<FilterOperation<T>> operations);
}

typedef OnSuccess<R> = Future<R?> Function(Object? data);

typedef OnError<R> = Future<R?> Function(DataException e);

typedef OnOfflineException<R> = Future<R?> Function();

typedef OfflineExceptionCallback = Function();

enum RequestMethod {
  get,
  post,
  patch,
  put,
  delete,
}
