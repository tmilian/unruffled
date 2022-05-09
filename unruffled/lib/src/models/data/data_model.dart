import 'package:uuid/uuid.dart';

const String tempKey = 'temp@';

class DataModel<T extends DataModel<T>> {
  DataModel(this.id, String? key)
      : key = key ?? id?.toString() ?? '$tempKey${Uuid().v1()}';

  Object? id;

  String key;
}
