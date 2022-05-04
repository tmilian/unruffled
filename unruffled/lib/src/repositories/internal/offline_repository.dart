import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:unruffled/src/models/data_adapter.dart';
import 'package:unruffled/src/models/data_model.dart';
import 'package:unruffled/src/models/offline/offline_operation.dart';
import 'package:unruffled/src/repositories/local/hive_local_storage.dart';
import 'package:unruffled/src/repositories/remote/remote_repository.dart';

class OfflineRepository<T extends DataModel<T>>
    with TypeAdapter<OfflineOperation> {
  OfflineRepository({
    required this.remoteRepository,
    required this.dataAdapter,
  });

  HiveLocalStorage get _hiveLocalStorage => GetIt.I.get();

  final RemoteRepository<T> remoteRepository;

  final DataAdapter<T> dataAdapter;

  Box<OfflineOperation>? box;

  String get boxName => 'unruffled_offline_${dataAdapter.serviceName}';

  Future<void> clear() async {
    await box?.clear();
  }

  Future<OfflineOperation> save(OfflineOperation model) async {
    await box?.put(model.key, model);
    return model;
  }

  Future<OfflineOperation?> delete(String key) async {
    var obj = await get(key);
    await box?.delete(key);
    return obj;
  }

  Future<List<OfflineOperation>> getAll() async {
    return box?.values.toList() ?? [];
  }

  Future<OfflineOperation?> get(String key) async {
    return box?.get(key);
  }

  Future<OfflineRepository<T>> initialize() async {
    if (!Hive.isBoxOpen(boxName)) {
      if (!Hive.isAdapterRegistered(typeId)) {
        Hive.registerAdapter(this);
      }
    }
    try {
      box = await _hiveLocalStorage.openBox<OfflineOperation>(boxName);
    } catch (e) {
      await _hiveLocalStorage.deleteBox(boxName);
      box = await _hiveLocalStorage.openBox<OfflineOperation>(boxName);
    }
    return this;
  }

  void dispose() {
    box?.close();
  }

  @override
  int get typeId {
    //TODO: DETERMINE DYNAMICALLY TYPE ID
    return 0;
  }

  @override
  OfflineOperation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <String, dynamic>{
      for (int i = 0; i < numOfFields; i++)
        reader.read().toString(): reader.read(),
    };
    var offline = OfflineOperation<T>.fromJson(fields);
    offline.remoteRepository = remoteRepository;
    return offline;
  }

  @override
  void write(BinaryWriter writer, OfflineOperation obj) {
    final map = obj.toJson();
    writer.writeByte(map.keys.length);
    map.values.toList().asMap().forEach((index, value) {
      writer.writeByte(index);
      writer.write(value);
    });
  }
}
