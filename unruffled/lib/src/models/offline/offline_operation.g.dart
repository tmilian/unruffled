// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_operation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OfflineOperation<T> _$OfflineOperationFromJson<T extends DataModel<T>>(
        Map<String, dynamic> json) =>
    OfflineOperation<T>(
      key: json['key'] as String?,
      type: $enumDecode(_$OfflineOperationTypeEnumMap, json['type']),
      modelKey: json['modelKey'] as String,
      path: json['path'] as String?,
      headers: (json['headers'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      query: json['query'] as Map<String, dynamic>?,
      body: json['body'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$OfflineOperationToJson<T extends DataModel<T>>(
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
  OfflineOperationType.post: 'POST',
  OfflineOperationType.patch: 'PATCH',
  OfflineOperationType.put: 'PUT',
  OfflineOperationType.delete: 'DELETE',
};
