import 'package:dio/dio.dart';
import 'package:unruffled/src/models/data_adapter.dart';
import 'package:unruffled/src/models/data_model.dart';
import 'package:unruffled/src/repositories/remote/remote_repository_impl.dart';

class Unruffled {
  Unruffled({this.baseUrl, this.encryptionKey});

  final String? baseUrl;
  final List<int>? encryptionKey;

  final Map<Type, RemoteRepositoryImpl> _remoteRepositories = {};

  void registerAdapter<T extends DataModel<T>>(DataAdapter<T> adapter) {
    _remoteRepositories[T] = RemoteRepositoryImpl<T>(
      dataAdapter: adapter,
      encryptionKey: encryptionKey,
    );
  }

  Future<Unruffled> init({
    required String baseDirectory,
  }) async {
    for (var adapter in _remoteRepositories.values) {
      await adapter.initialize();
    }
    return this;
  }
}
