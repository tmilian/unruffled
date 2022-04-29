import 'package:unruffled/src/models/data_model.dart';

abstract class DataAdapter<T extends DataModel<T>> {
  Map<String, dynamic> serialize(T model);

  T deserialize(Map<String, dynamic> map);

  String get typeName;
}
