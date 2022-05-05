import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:unruffled/src/models/data/data_adapter.dart';
import 'package:unruffled/src/models/data/data_model.dart';
import 'package:unruffled/src/repositories/local/hive_local_storage.dart';
import 'package:unruffled/src/repositories/local/local_repository_interface.dart';
import 'package:collection/collection.dart';

class LocalRepositoryImpl<T extends DataModel<T>> extends LocalRepository<T>
    with TypeAdapter<T> {
  LocalRepositoryImpl({
    required this.dataAdapter,
  });

  HiveLocalStorage get _hiveLocalStorage => GetIt.I.get();

  final DataAdapter<T> dataAdapter;

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
        Hive.registerAdapter(this);
      }
    }
    try {
      box = await _hiveLocalStorage.openBox<T>(typeName);
    } catch (e) {
      await _hiveLocalStorage.deleteBox(typeName);
      box = await _hiveLocalStorage.openBox<T>(typeName);
    }
    return this;
  }

  @override
  void dispose() {
    box?.close();
  }

  @override
  int get typeId {
    //TODO: DEFINE DYNAMICALLY TYPE ID ACCORDING EXISTING TYPES IN INTERNAL STORAGE
    return 0;
  }

  @override
  T read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <String, dynamic>{
      for (int i = 0; i < numOfFields; i++)
        reader.read().toString(): reader.read(),
    };
    return dataAdapter.deserialize(fields);
  }

  @override
  void write(BinaryWriter writer, T obj) {
    final map = dataAdapter.serialize(obj);
    writer.writeByte(map.keys.length);
    map.values.toList().asMap().forEach((index, value) {
      writer.writeByte(index);
      writer.write(value);
    });
  }
}