part of unruffled;

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
    switch (model.type) {
      case OfflineOperationType.post:
        return await _save(model);
      case OfflineOperationType.patch:
        return await _update(model);
      case OfflineOperationType.put:
        return await _update(model);
      case OfflineOperationType.delete:
        return await _delete(model);
    }
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

  Future<OfflineOperation> _save(OfflineOperation model) async {
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

  Future<OfflineOperation> _delete(OfflineOperation model) async {
    // If model is not remote synced, don't store DELETE offline operation and
    // remove all offline operation related to model.modelKey
    if (model.modelKey.startsWith(tempKey)) {
      final operations =
          getAll().where((operation) => operation.modelKey == model.modelKey);
      for (var operation in operations) {
        await box?.delete(operation.key);
      }
      return model;
    } else {
      return await _save(model);
    }
  }

  Future<OfflineOperation> _update(OfflineOperation model) async {
    // If model is not remote synced, don't store PATCH/PUT offline operation
    if (model.modelKey.startsWith(tempKey)) {
      return model;
    } else {
      return await _save(model);
    }
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
