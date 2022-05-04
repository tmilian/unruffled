import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:unruffled/src/models/data_adapter.dart';
import 'package:unruffled/src/models/data_model.dart';
import 'package:unruffled/src/repositories/local/hive_local_storage.dart';
import 'package:unruffled/src/repositories/remote/remote_repository.dart';
import 'package:unruffled/src/unruffled_interface.dart';

class Unruffled extends UnruffledInterface {
  Unruffled({
    required this.baseDirectory,
    required String defaultBaseUrl,
    Map<String, dynamic>? defaultHeaders,
    List<int>? encryptionKey,
    Dio? dio,
  }) {
    GetIt.I.registerSingleton(dio ??
        Dio(BaseOptions(
          baseUrl: defaultBaseUrl,
          headers: defaultHeaders,
        )));
    GetIt.I.registerSingleton(HiveLocalStorage(encryptionKey: encryptionKey));
  }

  final String baseDirectory;
  final List<RemoteRepository> _remoteRepositories = [];

  Unruffled registerAdapter<T extends DataModel<T>>(DataAdapter<T> adapter) {
    _remoteRepositories.add(RemoteRepository<T>(dataAdapter: adapter));
    return this;
  }

  Future<Unruffled> init() async {
    Hive.init(baseDirectory);
    for (var remote in _remoteRepositories) {
      await remote.initialize();
    }
    return this;
  }

  @override
  Future<T?> delete<T extends DataModel<T>>(String key) async {
    return await getRepository<T>().delete(key: key);
  }

  @override
  Future<List<T>?> getAll<T extends DataModel<T>>() async {
    return await getRepository<T>().getAll();
  }

  @override
  Future<T?> get<T extends DataModel<T>>(String key) async {
    return await getRepository<T>().get(key: key);
  }

  @override
  Future<T> post<T extends DataModel<T>>(T model) async {
    return await getRepository<T>().post(model: model);
  }

  RemoteRepository<T> getRepository<T extends DataModel<T>>() {
    for (var element in _remoteRepositories) {
      if (element is RemoteRepository<T>) {
        return element;
      }
    }
    throw ("It seems that your class ${T.toString()} doesn't have a ${T.toString()}Adapter() registered");
  }
}
