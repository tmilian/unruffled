import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';
import 'package:unruffled/src/models/data/data_exception.dart';
import 'package:unruffled/src/models/data/data_model.dart';
import 'package:unruffled/src/models/data/data_adapter.dart';
import 'package:unruffled/src/models/data/deserialized_data.dart';
import 'package:unruffled/src/models/offline/offline_operation.dart';
import 'package:unruffled/src/repositories/internal/offline_repository.dart';
import 'package:unruffled/src/repositories/local/local_repository_interface.dart';
import 'package:unruffled/src/repositories/local/local_repository.dart';

class RemoteRepository<T extends DataModel<T>> {
  RemoteRepository({
    required this.dataAdapter,
  }) : localRepository = LocalRepositoryImpl<T>(dataAdapter: dataAdapter) {
    offlineRepository = OfflineRepository<T>(
      remoteRepository: this,
      dataAdapter: dataAdapter,
    );
  }

  @protected
  final DataAdapter<T> dataAdapter;

  @protected
  final LocalRepository<T> localRepository;

  @protected
  late OfflineRepository<T> offlineRepository;

  @protected
  String get serviceName => dataAdapter.serviceName;

  String url(
      {required RequestMethod method, Map<String, dynamic>? pathParams}) {
    switch (method) {
      case RequestMethod.GET:
        return pathParams == null
            ? '/$serviceName'
            : '/$serviceName/${pathParams['id']}';
      case RequestMethod.POST:
        return '/$serviceName';
      case RequestMethod.PATCH:
        return '/$serviceName/${pathParams?['id']}';
      case RequestMethod.PUT:
        return '/$serviceName/${pathParams?['id']}';
      case RequestMethod.DELETE:
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

  Dio get dio => GetIt.I.get();

  Future<T?> delete({
    required String key,
    String? path,
    bool local = false,
    Map<String, String>? headers,
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
    OnError<T?>? onError,
    OnOfflineException? onOfflineException,
  }) async {
    var model = await localRepository.delete(key);
    if (local) {
      return model;
    }
    return await sendRequest(
      url: path ??
          url(method: RequestMethod.DELETE, pathParams: {'id': model?.id}),
      method: RequestMethod.DELETE,
      headers: headers,
      query: query,
      onSuccess: (data) async {
        var deserialized = deserialize(data);
        return deserialized.model;
      },
      onError: (e) async => onError?.call(e) ?? _onError(e),
      onOfflineException: () async {
        onOfflineException?.call();
        await offlineRepository.save(
          OfflineOperation<T>(
            type: OfflineOperationType.DELETE,
            modelKey: model!.key,
            path: path,
            headers: headers,
            query: query,
            body: body,
          ),
        );
        return model;
      },
    );
  }

  Future<List<T>?> getAll({
    String? path,
    bool local = false,
    Map<String, String>? headers,
    Map<String, dynamic>? query,
    OnError<List<T>>? onError,
    OnOfflineException? onOfflineException,
  }) async {
    if (local) {
      return await localRepository.getAll();
    }
    return await sendRequest(
      url: path ?? url(method: RequestMethod.GET),
      method: RequestMethod.GET,
      headers: headers,
      query: query,
      onSuccess: (data) async {
        var deserialized = deserialize(data);
        for (var model in deserialized.models) {
          await localRepository.save(model.key, model);
        }
        return deserialized.models;
      },
      onError: (e) async => onError?.call(e) ?? _onError(e),
      onOfflineException: () async {
        onOfflineException?.call();
        return await getAll(local: true);
      },
    );
  }

  /// GET specific object
  ///
  /// key is required and can be your model.id or your model.key (if you need to
  /// retrieve a local object that does not exist on your server)
  ///
  Future<T?> get({
    required Object key,
    String? path,
    bool local = false,
    Map<String, String>? headers,
    Map<String, dynamic>? query,
    OnError<T?>? onError,
    OnOfflineException? onOfflineException,
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
          url(method: RequestMethod.GET, pathParams: {'id': model?.id ?? key}),
      method: RequestMethod.GET,
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
        return await (onError?.call(e) ?? _onError(e));
      },
      onOfflineException: () async {
        onOfflineException?.call();
        return model;
      },
    );
  }

  Future<T> post({
    required T model,
    String? path,
    bool local = false,
    Map<String, String>? headers,
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
    bool remote = false,
    OnError<T?>? onError,
    OnOfflineException? onOfflineException,
  }) async {
    await localRepository.save(model.key, model);
    if (local) return model;
    var result = await sendRequest<T>(
      url: path ?? url(method: RequestMethod.POST),
      method: RequestMethod.POST,
      headers: headers,
      query: query,
      onSuccess: (data) async {
        var deserialized = deserialize(data);
        var newModel = deserialized.model;
        if (newModel != null) {
          await localRepository.delete(model.key);
          await localRepository.save(newModel.key, newModel);
        }
        return newModel;
      },
      onError: (e) async => onError?.call(e) ?? _onError(e),
      onOfflineException: () async {
        onOfflineException?.call();
        await offlineRepository.save(
          OfflineOperation<T>(
            type: OfflineOperationType.POST,
            modelKey: model.key,
            path: path,
            headers: headers,
            query: query,
            body: body,
          ),
        );
        return model;
      },
    );
    return result ?? model;
  }

  Future<T> put({
    required T model,
    String? path,
    bool local = false,
    Map<String, String>? headers,
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
    bool remote = false,
    OnError<T?>? onError,
    OnOfflineException? onOfflineException,
  }) async {
    await localRepository.save(model.key, model);
    if (local) return model;
    var result = await sendRequest<T>(
      url: path ??
          url(
              method: RequestMethod.PUT,
              pathParams: {'id': model.id.toString()}),
      method: RequestMethod.PUT,
      headers: headers,
      query: query,
      onSuccess: (data) async {
        var deserialized = deserialize(data);
        return deserialized.model;
      },
      onError: (e) async => onError?.call(e) ?? _onError(e),
      onOfflineException: () async {
        onOfflineException?.call();
        await offlineRepository.save(
          OfflineOperation<T>(
            type: OfflineOperationType.PUT,
            modelKey: model.key,
            path: path,
            headers: headers,
            query: query,
            body: body,
          ),
        );
        return model;
      },
    );
    return result ?? model;
  }

  Future<T> patch({
    required T model,
    String? path,
    bool local = false,
    Map<String, String>? headers,
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
    bool remote = false,
    OnError<T?>? onError,
    OnOfflineException? onOfflineException,
  }) async {
    await localRepository.save(model.key, model);
    if (local) return model;
    var result = await sendRequest<T>(
      url: path ??
          url(
              method: RequestMethod.PATCH,
              pathParams: {'id': model.id.toString()}),
      method: RequestMethod.PATCH,
      headers: headers,
      query: query,
      onSuccess: (data) async {
        var deserialized = deserialize(data);
        return deserialized.model;
      },
      onError: (e) async => onError?.call(e) ?? _onError(e),
      onOfflineException: () async {
        onOfflineException?.call();
        await offlineRepository.save(
          OfflineOperation<T>(
            type: OfflineOperationType.PATCH,
            modelKey: model.key,
            path: path,
            headers: headers,
            query: query,
            body: body,
          ),
        );
        return model;
      },
    );
    return result ?? model;
  }

  Future<RemoteRepository<T>> initialize() async {
    await localRepository.initialize();
    return this;
  }

  Future<R?> sendRequest<R>({
    required String url,
    RequestMethod method = RequestMethod.GET,
    Map<String, String>? headers,
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
    required OnSuccess<R> onSuccess,
    required OnError<R> onError,
    OnOfflineException? onOfflineException,
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
      if (_isConnectivityError(e)) {
        return await onOfflineException?.call();
      }
      final dataException = DataException(e,
          stackTrace: e.stackTrace, statusCode: e.response?.statusCode);
      return await onError(dataException);
    }
  }

  Future<List<OfflineOperation>> get offlineOperations {
    return offlineRepository.getAll();
  }

  FutureOr<R?> _onError<R>(DataException e) {
    throw e;
  }

  bool _isConnectivityError(Object? error) {
    // timeouts via http's `connectionTimeout` are
    // also socket exceptions
    // we check the exception like this in order not to import `dart:io`
    final _err = error.toString();
    return _err.startsWith('SocketException') ||
        _err.startsWith('Connection closed before full header was received') ||
        _err.startsWith('HandshakeException');
  }

  void dispose() {
    localRepository.dispose();
  }
}

typedef OnSuccess<R> = Future<R?> Function(Object? data);

typedef OnError<R> = Future<R?> Function(DataException e);

typedef OnOfflineException = Function();

enum RequestMethod {
  GET,
  POST,
  PATCH,
  PUT,
  DELETE,
}
