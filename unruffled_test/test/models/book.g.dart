// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Book _$BookFromJson(Map<String, dynamic> json) => Book(
      unruffledKey: json['unruffledKey'] as String?,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$BookToJson(Book instance) => <String, dynamic>{
      'unruffledKey': instance.unruffledKey,
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

  @override
  String? key(Book? model) => model?.title.toString() ?? model?.unruffledKey;
}

class $BookRemoteRepository = RemoteRepository<Book>
    with CustomRemoteRepository<Book>;

class BookRepository extends $BookRemoteRepository {
  BookRepository() : super(BookAdapter());
}

class BookField extends UnruffledField<Book> {
  BookField.title() : super('title');
  BookField.createdAt() : super('createdAt');
}

extension BookUnruffledExt on Book {
  String get key => title.toString();
}
