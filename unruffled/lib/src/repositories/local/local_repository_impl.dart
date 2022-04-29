import 'dart:async';

import 'package:hive/hive.dart';
import 'package:unruffled/src/models/data_adapter.dart';
import 'package:unruffled/src/models/data_model.dart';
import 'package:unruffled/src/repositories/local/hive_local_storage.dart';
import 'package:unruffled/src/repositories/local/local_repository.dart';

class LocalRepositoryImpl<T extends DataModel<T>> extends LocalRepository<T>
    with TypeAdapter<T> {
  LocalRepositoryImpl({
    required this.dataAdapter,
    List<int>? encryptionKey,
  }) : _hiveLocalStorage = HiveLocalStorage(encryptionKey: encryptionKey);

  final HiveLocalStorage _hiveLocalStorage;

  final DataAdapter<T> dataAdapter;

  Box<T>? box;

  String get typeName => dataAdapter.typeName;

  @override
  Future<void> clear() async {
    // TODO: implement clear
  }

  @override
  Future<T> save(String key, T model) {
    throw UnimplementedError();
  }

  @override
  Future<void> delete(String key) async {
    // TODO: implement delete
  }

  @override
  List<T>? findAll() {
    // TODO: implement findAll
  }

  @override
  T? findOne(String? key) {
    // TODO: implement findOne
  }

  @override
  FutureOr<LocalRepository<T>> initialize() async {
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

  void dispose() {
    box?.close();
  }

  @override
  int get typeId {
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
