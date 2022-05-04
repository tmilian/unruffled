import 'dart:async';

import 'package:unruffled/unruffled.dart';

abstract class LocalRepository<T extends DataModel<T>> {
  Future<LocalRepository<T>> initialize();

  void dispose();

  Future<List<T>> getAll();

  Future<T?> get(String? key);

  Future<T?> getFromId(Object? id);

  Future<T> save(String key, T model);

  Future<T?> delete(String key);

  Future<void> clear();
}
