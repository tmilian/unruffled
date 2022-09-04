// GENERATED CODE - DO NOT MODIFY BY HAND

part of unruffled_feathersjs;

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Paginate<T> _$PaginateFromJson<T extends DataModel>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    Paginate<T>(
      total: json['total'] as int,
      limit: json['limit'] as int,
      skip: json['skip'] as int,
      data: (json['data'] as List<dynamic>).map(fromJsonT).toList(),
    );

Map<String, dynamic> _$PaginateToJson<T extends DataModel>(
  Paginate<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'total': instance.total,
      'limit': instance.limit,
      'skip': instance.skip,
      'data': instance.data.map(toJsonT).toList(),
    };
