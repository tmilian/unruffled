import 'package:json_annotation/json_annotation.dart';
import 'package:unruffled/unruffled.dart';
import 'package:unruffled_feathersjs/unruffled_feathersjs.dart';

part 'book.g.dart';

@UnruffledData(adapter: FeathersJsRemoteRepository)
@JsonSerializable()
class Book extends DataModel<Book> {
  String title;
  int pages;
  DateTime createdAt;

  Book({
    String? key,
    int? id,
    required this.title,
    required this.pages,
    required this.createdAt,
  }) : super(id, key);
}
