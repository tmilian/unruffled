import 'dart:async';

import 'package:unruffled/src/models/collection.dart';
import 'package:unruffled/src/models/data_model.dart';

abstract class RemoteRepository<T extends DataModel<T>> {
  FutureOr<RemoteRepository<T>> initialize();

  Future<Collection<T>>? findAll();

  Future<T>? findOne(String key);

  Future<T> save(String key, T model);

  Future<void> delete(String key);

  Future<void> clear();
}
