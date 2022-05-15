part of unruffled;

class TypeManager with TypeAdapter<int> {
  static TypeManager get to => GetIt.I.get();

  Box<int>? box;

  String get boxName => 'unruffled_type_registry';

  Future<void> clear() async {
    await box?.clear();
  }

  Future<int> save(String type, int id) async {
    await box?.put(type, id);
    return id;
  }

  List<int> getAll() {
    return box?.values.toList() ?? [];
  }

  int get(String type) {
    var id = box?.get(type) ?? getAll().length + 1;
    save(type, id);
    return id;
  }

  Future<TypeManager> initialize() async {
    if (!Hive.isBoxOpen(boxName)) {
      if (!Hive.isAdapterRegistered(typeId)) {
        Hive.registerAdapter(this);
      }
    }
    try {
      box = await HiveLocalStorage.to.openBox<int>(boxName);
    } catch (e) {
      await HiveLocalStorage.to.deleteBox(boxName);
      box = await HiveLocalStorage.to.openBox<int>(boxName);
    }
    return this;
  }

  Future<void> dispose() async {
    await box?.close();
  }

  @override
  int get typeId {
    return 0;
  }

  @override
  int read(BinaryReader reader) {
    return reader.readInt();
  }

  @override
  void write(BinaryWriter writer, int obj) {
    writer.writeInt(obj);
  }
}
