import 'package:hive/hive.dart';
import 'package:unruffled/src/repositories/local/hive_local_storage.dart';

class InternalStorage {
  InternalStorage({required this.hiveLocalStorage});

  final HiveLocalStorage hiveLocalStorage;
  static const _internalBox = 'unruffled_internal_storage';

  Box<Map>? box;

  Future<InternalStorage> initialize() async {
    try {
      box = await hiveLocalStorage.openBox<Map>(_internalBox);
    } catch (e) {
      await hiveLocalStorage.deleteBox(_internalBox);
      box = await hiveLocalStorage.openBox<Map>(_internalBox);
    }
    return this;
  }
}
