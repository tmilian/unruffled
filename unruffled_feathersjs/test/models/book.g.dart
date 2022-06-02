// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Book _$BookFromJson(Map<String, dynamic> json) => Book(
      unruffledKey: json['unruffledKey'] as String?,
      id: json['id'] as int?,
      title: json['title'] as String,
      pages: json['pages'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$BookToJson(Book instance) => <String, dynamic>{
      'unruffledKey': instance.unruffledKey,
      'id': instance.id,
      'title': instance.title,
      'pages': instance.pages,
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
  String? key(Book? model) => model?.id?.toString() ?? model?.unruffledKey;

  @override
  String get serviceName => 'service/books';
}

class $BookRemoteRepository = RemoteRepository<Book>
    with FeathersJsRemoteRepository<Book>;

class BookRepository extends $BookRemoteRepository {
  BookRepository() : super(BookAdapter());
}

class BookField extends UnruffledField<Book> {
  BookField.id() : super('id');
  BookField.title() : super('title');
  BookField.pages() : super('pages');
  BookField.createdAt() : super('createdAt');
}

extension BookUnruffledExt on Book {
  String get key => id?.toString() ?? unruffledKey;
}
