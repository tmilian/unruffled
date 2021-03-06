part of unruffled;

abstract class DataAdapter<T extends DataModel> {
  Map<String, dynamic> serialize(T model);

  T deserialize(Map<String, dynamic> map);

  String? key(T? model);

  /// Generate a typeName from Data Model type.
  /// It is used internally to generate a Hive typeId
  String get serviceName {
    if (T == dynamic) {
      throw UnsupportedError('Please supply a type');
    }
    var type = T.toString();
    type = type.camelCase;
    return type.endsWith('s') ? type : '${type}s';
  }

  void toType(void Function<T>() callback) => callback<T>();
}
