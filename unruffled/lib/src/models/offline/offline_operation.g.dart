// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_operation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OfflineOperation<T> _$OfflineOperationFromJson<T extends DataModel>(Map json) =>
    OfflineOperation<T>(
      key: json['key'] as String?,
      type: $enumDecode(_$OfflineOperationTypeEnumMap, json['type']),
      modelKey: json['modelKey'] as String,
      path: json['path'] as String?,
      headers: (json['headers'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e as String),
      ),
      query: (json['query'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e),
      ),
      body: (json['body'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e),
      ),
    );

Map<String, dynamic> _$OfflineOperationToJson<T extends DataModel>(
        OfflineOperation<T> instance) =>
    <String, dynamic>{
      'key': instance.key,
      'type': _$OfflineOperationTypeEnumMap[instance.type],
      'modelKey': instance.modelKey,
      'path': instance.path,
      'headers': instance.headers,
      'query': instance.query,
      'body': instance.body,
    };

const _$OfflineOperationTypeEnumMap = {
  OfflineOperationType.post: 'post',
  OfflineOperationType.patch: 'patch',
  OfflineOperationType.put: 'put',
  OfflineOperationType.delete: 'delete',
};
