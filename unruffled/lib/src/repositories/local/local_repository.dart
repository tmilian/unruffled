import 'dart:async';

import 'package:hive/hive.dart';
import 'package:unruffled/src/models/data/data_adapter.dart';
import 'package:unruffled/src/models/data/data_model.dart';
import 'package:unruffled/src/repositories/internal/type_manager.dart';
import 'package:unruffled/src/repositories/local/hive_local_storage.dart';
import 'package:unruffled/src/repositories/local/local_repository_interface.dart';
import 'package:collection/collection.dart';

class LocalRepositoryImpl<T extends DataModel<T>> extends LocalRepository<T>
    with TypeAdapter<T> {
  LocalRepositoryImpl({
    required DataAdapter<T> dataAdapter,
  }) : super(dataAdapter);

  Box<T>? box;

  String get typeName => dataAdapter.serviceName;

  @override
  Future<void> clear() async {
    await box?.clear();
  }

  @override
  Future<T> save(String key, T model) async {
    await box?.put(key, model);
    return model;
  }

  @override
  Future<T?> delete(String key) async {
    var obj = await get(key);
    await box?.delete(key);
    return obj;
  }

  @override
  Future<List<T>> getAll() async {
    return box?.values.toList() ?? [];
  }

  @override
  Future<T?> get(String? key) async {
    return box?.get(key);
  }

  @override
  Future<T?> getFromId(Object? id) async {
    var models = await getAll();
    return models.firstWhereOrNull(
      (model) => model.id?.toString() == id?.toString(),
    );
  }

  @override
  Future<LocalRepository<T>> initialize() async {
    if (!Hive.isBoxOpen(typeName)) {
      if (!Hive.isAdapterRegistered(typeId)) {
        Hive.registerAdapter<T>(this);
      }
    }
    try {
      box = await HiveLocalStorage.to.openBox<T>(typeName);
    } catch (e) {
      await HiveLocalStorage.to.deleteBox(typeName);
      box = await HiveLocalStorage.to.openBox<T>(typeName);
    }
    return this;
  }

  @override
  Future<void> dispose() async {
    await box?.close();
  }

  @override
  int get typeId => TypeManager.to.get(typeName);

  @override
  T read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    var fields = <String, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      var name = reader.read().toString();
      var value = reader.read();
      fields[name] = value;
    }
    return dataAdapter.deserialize(fields);
  }

  @override
  void write(BinaryWriter writer, T obj) {
    final map = dataAdapter.serialize(obj);
    writer.writeByte(map.keys.length);
    map.forEach((key, value) {
      writer.write(key);
      writer.write(value);
    });
  }
}
