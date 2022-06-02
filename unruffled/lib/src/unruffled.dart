part of unruffled;

class Unruffled {
  Unruffled({
    required this.baseDirectory,
    required String defaultBaseUrl,
    Map<String, dynamic>? defaultHeaders,
    List<int>? encryptionKey,
    Dio? dio,
  }) {
    GetIt.I.registerSingleton(TypeManager());
    GetIt.I.registerSingleton(HiveLocalStorage(encryptionKey: encryptionKey));
    GetIt.I.registerSingleton((dio
          ?..options.baseUrl = defaultBaseUrl
          ..options.headers = defaultHeaders) ??
        Dio(BaseOptions(
          baseUrl: defaultBaseUrl,
          headers: defaultHeaders,
        )));
  }

  final String baseDirectory;

  final List<RemoteRepository> _remoteRepositories = [];

  Unruffled registerRepository<T extends DataModel>(
    RemoteRepository<T> remoteRepository,
  ) {
    _remoteRepositories.add(remoteRepository);
    return this;
  }

  Future<Unruffled> init() async {
    Hive.init(baseDirectory);
    await TypeManager.to.initialize();
    for (var remote in _remoteRepositories) {
      await remote.initialize();
    }
    return this;
  }

  RemoteRepository<T> repository<T extends DataModel>() {
    for (var element in _remoteRepositories) {
      if (element is RemoteRepository<T>) {
        return element;
      }
    }
    throw ("It seems that your class ${T.toString()} doesn't have a ${T.toString()}Repository() registered");
  }

  Map<RemoteRepository, List<OfflineOperation>> get offlineOperations =>
      _remoteRepositories
          .asMap()
          .map((index, e) => MapEntry(e, e.offlineOperations));

  Future<void> dispose() async {
    for (var remote in _remoteRepositories) {
      await remote.dispose();
    }
    GetIt.I.unregister<TypeManager>();
    GetIt.I.unregister<HiveLocalStorage>();
    GetIt.I.unregister<Dio>();
    await Hive.close();
    _remoteRepositories.clear();
  }
}
