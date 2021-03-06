part of unruffled;

class HiveLocalStorage {
  HiveLocalStorage({List<int>? encryptionKey})
      : encryptionCipher =
            encryptionKey != null ? HiveAesCipher(encryptionKey) : null;

  static HiveLocalStorage get to => GetIt.I.get();

  final HiveAesCipher? encryptionCipher;

  bool get isInitialized => _isInit;

  bool _isInit = false;

  Future<void> initialized() async {
    _isInit = true;
  }

  Future<Box<B>> openBox<B>(String name) async {
    return await Hive.openBox<B>(
      name.snakeCase,
      encryptionCipher: encryptionCipher,
    );
  }

  Future<void> deleteBox(String name) async {
    try {
      name = name.snakeCase;
      if (await Hive.boxExists(name)) {
        await Hive.deleteBoxFromDisk(name);
      }
    } catch (e) {
      if (e.toString().contains('No such file or directory')) {
        // we can safely ignore?
      } else {
        rethrow;
      }
    }
  }
}
