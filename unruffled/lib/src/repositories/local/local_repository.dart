import 'dart:async';

import 'package:unruffled/unruffled.dart';

abstract class LocalRepository<T extends DataModel<T>> {
  LocalRepository(this.dataAdapter);

  Future<LocalRepository<T>> initialize();

  Future<void> dispose();

  DataAdapter<T> dataAdapter;

  Future<List<T>> getAll();

  Future<T?> get(String? key);

  Future<T?> getFromId(Object? id);

  Future<T> save(String key, T model);

  Future<T?> delete(String key);

  Future<void> clear();
}
