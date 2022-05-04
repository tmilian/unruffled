import 'package:json_annotation/json_annotation.dart';
import 'package:unruffled/src/models/data_model.dart';
import 'package:unruffled/src/repositories/remote/remote_repository.dart';
import 'package:uuid/uuid.dart';

part 'offline_operation.g.dart';

/// Offline Operation represents request that has failed due to network
/// connectivity
///
/// We store only post/patch/put/delete operations
///
/// Offline operation does not support custom operations at this time
///
@JsonSerializable()
class OfflineOperation<T extends DataModel<T>> {
  final String key;
  final OfflineOperationType type;
  final String modelKey;
  final String? path;
  final Map<String, String>? headers;
  final Map<String, dynamic>? query;
  final Map<String, dynamic>? body;
  @JsonKey(ignore: true)
  late RemoteRepository<T> remoteRepository;

  OfflineOperation({
    String? key,
    required this.type,
    required this.modelKey,
    this.path,
    this.headers,
    this.query,
    this.body,
  }) : key = key ?? 'offline@${Uuid().v1()}';

  Map<String, dynamic> toJson() => _$OfflineOperationToJson(this);

  factory OfflineOperation.fromJson(Map<String, dynamic> json) =>
      _$OfflineOperationFromJson(json);

  Future<void> retry() async {
    var model = await remoteRepository.get(key: modelKey, local: true);
    if (model == null) {
      throw ('Error no model found for key $modelKey');
    }
    switch (type) {
      case OfflineOperationType.POST:
        await remoteRepository.post(
          model: model,
          path: path,
          headers: headers,
          query: query,
          body: body,
        );
        break;
      case OfflineOperationType.PATCH:
        await remoteRepository.patch(
          model: model,
          path: path,
          headers: headers,
          query: query,
          body: body,
        );
        break;
      case OfflineOperationType.PUT:
        await remoteRepository.put(
          model: model,
          path: path,
          headers: headers,
          query: query,
          body: body,
        );
        break;
      case OfflineOperationType.DELETE:
        await remoteRepository.delete(
          key: modelKey,
          path: path,
          headers: headers,
          query: query,
          body: body,
        );
        break;
    }
  }
}

enum OfflineOperationType { POST, PATCH, PUT, DELETE }
