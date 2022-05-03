import 'dart:async';

import 'package:unruffled/unruffled.dart';

abstract class UnruffledInterface {
  Future<List<T>?> getAll<T extends DataModel<T>>();

  Future<T?> get<T extends DataModel<T>>(String key);

  Future<T> post<T extends DataModel<T>>(T model);

  Future<T?> delete<T extends DataModel<T>>(String key);
}
