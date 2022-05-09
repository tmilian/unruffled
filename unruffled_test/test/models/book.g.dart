// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Book _$BookFromJson(Map<String, dynamic> json) => Book(
      key: json['key'] as String?,
      id: json['id'] as int?,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$BookToJson(Book instance) => <String, dynamic>{
      'id': instance.id,
      'key': instance.key,
      'title': instance.title,
      'createdAt': instance.createdAt.toIso8601String(),
    };

// **************************************************************************
// DataAdapterGenerator
// **************************************************************************

class BookAdapter extends DataAdapter<Book> {
  @override
  Map<String, dynamic> serialize(Book model) => _$BookToJson(model);

  @override
  Book deserialize(Map<String, dynamic> map) => _$BookFromJson(map);
}
