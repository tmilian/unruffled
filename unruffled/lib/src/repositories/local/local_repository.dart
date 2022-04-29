import 'dart:async';

import 'package:unruffled/src/models/data_model.dart';

abstract class LocalRepository<T extends DataModel<T>> {
  FutureOr<LocalRepository<T>> initialize();

  List<T>? findAll();

  T? findOne(String? key);

  Future<T> save(String key, T model);

  Future<void> delete(String key);

  Future<void> clear();
}
