import 'package:uuid/uuid.dart';

const String tempKey = 'temp@';

class DataModel<T extends DataModel<T>> {
  Object? get id => null;

  String get key => id?.toString() ?? '$tempKey${Uuid().v1()}';
}
