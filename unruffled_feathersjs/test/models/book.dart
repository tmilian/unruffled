import 'package:json_annotation/json_annotation.dart';
import 'package:unruffled/unruffled.dart';
import 'package:unruffled_feathersjs/unruffled_feathersjs.dart';

part 'book.g.dart';

@UnruffledFeathersJsData()
@JsonSerializable()
class Book extends DataModel<Book> {
  @override
  int? id;
  String title;
  int pages;
  DateTime createdAt;

  Book({
    super.key,
    this.id,
    required this.title,
    required this.pages,
    required this.createdAt,
  });
}
