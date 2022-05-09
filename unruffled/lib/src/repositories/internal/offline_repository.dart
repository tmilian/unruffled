import 'dart:async';

import 'package:hive/hive.dart';
import 'package:unruffled/src/models/data/data_adapter.dart';
import 'package:unruffled/src/models/data/data_model.dart';
import 'package:unruffled/src/models/offline/offline_operation.dart';
import 'package:unruffled/src/repositories/internal/type_manager.dart';
import 'package:unruffled/src/repositories/local/hive_local_storage.dart';
import 'package:collection/collection.dart';

class OfflineRepository<T extends DataModel<T>>
    with TypeAdapter<OfflineOperation> {
  OfflineRepository({
    required this.dataAdapter,
  });

  final DataAdapter<T> dataAdapter;

  Box<OfflineOperation>? box;

  String get boxName => 'unruffled_offline_${dataAdapter.serviceName}';

  Future<void> clear() async {
    await box?.clear();
  }

  Future<OfflineOperation> save(OfflineOperation model) async {
    // Get offline operation from storage if exists
    var json = model.toJson()..removeWhere((k, v) => k == 'key');
    var item = getAll().firstWhereOrNull((op) {
      var opJson = op.toJson()..removeWhere((k, v) => k == 'key');
      return opJson.toString() == json.toString();
    });
    // If doesn't exist create a new one
    if (item == null) {
      await box?.put(model.key, model);
    }
    return item ?? model;
  }

  Future<OfflineOperation?> delete(OfflineOperation model) async {
    var json = model.toJson()..removeWhere((k, v) => k == 'key');
    var item = getAll().firstWhereOrNull((op) {
      var opJson = op.toJson()..removeWhere((k, v) => k == 'key');
      return opJson.toString() == json.toString();
    });
    if (item != null) {
      await box?.delete(item.key);
    }
    return item;
  }

  List<OfflineOperation> getAll() {
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
      box = await HiveLocalStorage.to.openBox<OfflineOperation>(boxName);
    } catch (e) {
      await HiveLocalStorage.to.deleteBox(boxName);
      box = await HiveLocalStorage.to.openBox<OfflineOperation>(boxName);
    }
    return this;
  }

  Future<void> dispose() async {
    await box?.close();
    box = null;
  }

  @override
  int get typeId => TypeManager.to.get(boxName);

  @override
  OfflineOperation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <String, dynamic>{
      for (int i = 0; i < numOfFields; i++)
        reader.read().toString(): reader.read(),
    };
    return OfflineOperation<T>.fromJson(fields);
  }

  @override
  void write(BinaryWriter writer, OfflineOperation obj) {
    final map = obj.toJson();
    writer.writeByte(map.keys.length);
    map.forEach((key, value) {
      writer.write(key);
      writer.write(value);
    });
  }
}
