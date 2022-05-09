import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:unruffled/src/models/data/data_adapter.dart';
import 'package:unruffled/src/models/data/data_model.dart';
import 'package:unruffled/src/models/offline/offline_operation.dart';
import 'package:unruffled/src/repositories/internal/type_manager.dart';
import 'package:unruffled/src/repositories/local/hive_local_storage.dart';
import 'package:unruffled/src/repositories/remote/remote_repository.dart';

import 'repositories/local/local_repository.dart';

class Unruffled {
  Unruffled({
    required this.baseDirectory,
    required String defaultBaseUrl,
    Map<String, dynamic>? defaultHeaders,
    List<int>? encryptionKey,
    Dio? dio,
  }) : dio = (dio
              ?..options.baseUrl = defaultBaseUrl
              ..options.headers = defaultHeaders) ??
            Dio(BaseOptions(
              baseUrl: defaultBaseUrl,
              headers: defaultHeaders,
            )) {
    GetIt.I.registerSingleton(HiveLocalStorage(encryptionKey: encryptionKey));
    GetIt.I.registerSingleton(TypeManager());
  }

  final Dio dio;

  final String baseDirectory;

  final List<RemoteRepository> _remoteRepositories = [];

  Unruffled registerAdapter<T extends DataModel<T>>(DataAdapter<T> adapter) {
    _remoteRepositories.add(RemoteRepository<T>(
      localRepository: LocalRepositoryImpl<T>(dataAdapter: adapter),
      dio: dio,
    ));
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

  RemoteRepository<T> repository<T extends DataModel<T>>() {
    for (var element in _remoteRepositories) {
      if (element is RemoteRepository<T>) {
        return element;
      }
    }
    throw ("It seems that your class ${T.toString()} doesn't have a ${T.toString()}Adapter() registered");
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
    _remoteRepositories.clear();
  }
}
