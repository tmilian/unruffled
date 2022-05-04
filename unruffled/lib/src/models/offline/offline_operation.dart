import 'package:unruffled/src/models/data_adapter.dart';
import 'package:unruffled/src/models/data_model.dart';
import 'package:unruffled/src/repositories/remote/remote_repository.dart';

/// Offline Operation represents request that has failed due to network
/// connectivity
///
/// We store only post/patch/put/delete operations
///
/// Offline operation does not support custom operations at this time
///
class OfflineOperation<T extends DataModel<T>> {
  final OfflineOperationType type;
  final String modelKey;
  final Map<String, String>? headers;
  final Map<String, dynamic>? query;
  final Map<String, dynamic>? body;
  late RemoteRepository<T> adapter;

  OfflineOperation({
    required this.type,
    required this.modelKey,
    this.headers,
    this.query,
    this.body,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': type.name,
      'headers': headers,
      'query': query,
      'body': body,
    };
  }

  factory OfflineOperation.fromJson(Map<String, dynamic> json) {
    return OfflineOperation<T>(
      type:
          OfflineOperationType.values.firstWhere((e) => e.name == json['type']),
      modelKey: json['modelKey'] as String,
      headers: json['headers'] as Map<String, String>?,
      query: json['query'] as Map<String, dynamic>?,
      body: json['body'] as Map<String, dynamic>?,
    );
  }
}

class OfflineOperationAdapter extends DataAdapter<OfflineOperation> {
  @override
  Map<String, dynamic> serialize(OfflineOperation model) => model.toJson();

  @override
  OfflineOperation deserialize(Map<String, dynamic> map) =>
      OfflineOperation.fromJson(map);
}

enum OfflineOperationType { POST, PATCH, PUT, DELETE }
