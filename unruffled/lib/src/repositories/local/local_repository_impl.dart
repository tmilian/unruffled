part of unruffled;

class LocalRepositoryImpl<T extends DataModel> extends LocalRepository<T>
    with TypeAdapter<T>, LocalQueryParser<List<T>, T> {
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
  Future<List<T>> getAll({QueryBuilder<T>? queryBuilder}) async {
    var values = box?.values.toList() ?? [];
    if (queryBuilder != null) {
      values = parse(
        data: values,
        queryBuilder: queryBuilder,
        orParser: (list) {
          return list.toSet().expand((element) => element).toList();
        },
        andParser: (list) => list
            .map((e) => e.toSet())
            .reduce((a, b) => a.intersection(b))
            .toList(),
      );
    }
    return values;
  }

  @override
  Future<T?> get(String? key) async {
    return box?.get(key);
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

  @override
  List<T> parsePagination(int limit, int page, List<T> object) {
    final start = limit * max(0, (page - 1)).toInt();
    if (start >= object.length) {
      return [];
    }
    return object.sublist(start, min(limit + start, object.length));
  }

  @override
  List<T> parseSort(SortCondition<T> sort, List<T> object) {
    object.sort((a, b) {
      final prop1 =
          getProperty(sort.property.property, dataAdapter.serialize(a));
      final prop2 =
          getProperty(sort.property.property, dataAdapter.serialize(b));
      return sort.sort == SortType.asc
          ? prop1.compareTo(prop2)
          : prop2.compareTo(prop1);
    });
    return object;
  }

  @override
  List<T> parseEqual(FilterCondition<T> condition, List<T> object) {
    return object.where((model) {
      final property = getProperty(
        condition.property.property,
        dataAdapter.serialize(model),
      );
      return property == condition.value;
    }).toList();
  }

  @override
  List<T> parseGreaterThan(FilterCondition<T> condition, List<T> object) {
    return object.where((model) {
      final value = condition.value;
      final property = getProperty(
        condition.property.property,
        dataAdapter.serialize(model),
      );
      if (property is num && value is num) {
        return condition.include ? property >= value : property > value;
      }
      return false;
    }).toList();
  }

  @override
  List<T> parseInValues(FilterCondition<T> condition, List<T> object) {
    return object.where((model) {
      final property = getProperty(
        condition.property.property,
        dataAdapter.serialize(model),
      );
      return condition.values.contains(property);
    }).toList();
  }

  @override
  List<T> parseLessThan(FilterCondition<T> condition, List<T> object) {
    return object.where((model) {
      final value = condition.value;
      final property = getProperty(
        condition.property.property,
        dataAdapter.serialize(model),
      );
      if (property is num && value is num) {
        return condition.include ? property <= value : property < value;
      }
      return false;
    }).toList();
  }

  @override
  List<T> parseNotEqual(FilterCondition<T> condition, List<T> object) {
    return object.where((model) {
      final property = getProperty(
        condition.property.property,
        dataAdapter.serialize(model),
      );
      return property != condition.value;
    }).toList();
  }
}
