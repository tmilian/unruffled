import 'dart:async';

import 'package:unruffled/src/models/collection.dart';
import 'package:unruffled/src/models/data_adapter.dart';
import 'package:unruffled/src/models/data_model.dart';
import 'package:unruffled/src/repositories/local/local_repository.dart';
import 'package:unruffled/src/repositories/local/local_repository_impl.dart';
import 'package:unruffled/src/repositories/remote/remote_repository.dart';

class RemoteRepositoryImpl<T extends DataModel<T>> extends RemoteRepository<T> {
  RemoteRepositoryImpl({required this.dataAdapter, List<int>? encryptionKey})
      : localRepository = LocalRepositoryImpl<T>(
          dataAdapter: dataAdapter,
          encryptionKey: encryptionKey,
        );

  final DataAdapter<T> dataAdapter;
  final LocalRepository<T> localRepository;

  @override
  FutureOr<RemoteRepository<T>> initialize() async {
    await localRepository.initialize();
    return this;
  }

  @override
  Future<void> clear() {
    // TODO: implement clear
    throw UnimplementedError();
  }

  @override
  Future<void> delete(String key) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<Collection<T>>? findAll() {
    // TODO: implement findAll
    throw UnimplementedError();
  }

  @override
  Future<T>? findOne(String key) {
    // TODO: implement findOne
    throw UnimplementedError();
  }

  @override
  Future<T> save(String key, T model) {
    // TODO: implement save
    throw UnimplementedError();
  }
}
