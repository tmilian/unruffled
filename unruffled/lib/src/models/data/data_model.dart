part of unruffled;

const String tempKey = 'temp@';

abstract class DataModel {
  DataModel({String? unruffledKey}) {
    this.unruffledKey = unruffledKey ?? '$tempKey${Uuid().v1()}';
  }

  /// Auto-generated key to identify a model locally
  ///
  /// When model is not synced on your server
  /// key = "{tempKey}{Random UUID}"
  ///
  /// When model is synced on your server
  /// key = id.toString()
  ///
  late String unruffledKey;
}
