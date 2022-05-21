part of unruffled;

const String tempKey = 'temp@';

abstract class DataModel<T extends DataModel<T>> {
  DataModel({String? key}) {
    this.key = key ?? id?.toString() ?? '$tempKey${Uuid().v1()}';
  }

  /// Remote object id
  /// Null when model has not been synced on your server
  ///
  Object? get id;

  /// Auto-generated key to identify a model locally
  ///
  /// When model is not synced on your server
  /// key = "{tempKey}{Random UUID}"
  ///
  /// When model is synced on your server
  /// key = id.toString()
  ///
  late String key;
}
