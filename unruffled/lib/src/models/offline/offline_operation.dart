import 'package:json_annotation/json_annotation.dart';
import 'package:unruffled/unruffled.dart';
import 'package:uuid/uuid.dart';

part 'offline_operation.g.dart';

/// Offline Operation represents request that has failed due to network
/// connectivity
///
/// We store only post/patch/put/delete operations
///
/// Offline operation does not support custom operations at this time
///
@JsonSerializable(explicitToJson: true, anyMap: true)
class OfflineOperation<T extends DataModel> {
  final String key;
  final OfflineOperationType type;
  final String modelKey;
  final String? path;
  final Map<String, String>? headers;
  final Map<String, dynamic>? query;
  final Map<String, dynamic>? body;

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

  Future<void> retry(RemoteRepository<T> remoteRepository) async {
    var model = await remoteRepository.get(key: modelKey, local: true);
    if (model == null) {
      throw ('Error no model found for key $modelKey');
    }
    switch (type) {
      case OfflineOperationType.post:
        await remoteRepository.post(
          model: model,
          path: path,
          headers: headers,
          query: query,
          body: body,
        );
        break;
      case OfflineOperationType.patch:
        await remoteRepository.patch(
          model: model,
          path: path,
          headers: headers,
          query: query,
          body: body,
        );
        break;
      case OfflineOperationType.put:
        await remoteRepository.put(
          model: model,
          path: path,
          headers: headers,
          query: query,
          body: body,
        );
        break;
      case OfflineOperationType.delete:
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

enum OfflineOperationType { post, patch, put, delete }
