import 'package:recase/recase.dart';

class DataModel<T extends DataModel<T>> {
  Object? get id => null;

  /// Generate a typeName from Data Model type.
  /// It is used internally to generate a Hive typeId
  ///
  /// MUST BE UNIQUE FOR ALL DATA MODELS DECLARED ON UNRUFFLED INITIALIZATION
  ///
  /// Override it if your class name overlaps
  ///
  String get typeName {
    if (T == dynamic) {
      throw UnsupportedError('Please supply a type');
    }
    var type = T.toString();
    type = type.camelCase;
    return type.endsWith('s') ? type : '${type}s';
  }
}
