import 'package:json_annotation/json_annotation.dart';
import 'package:unruffled/unruffled.dart';
import 'package:unruffled_feathersjs/unruffled_feathersjs.dart';

part 'book.g.dart';

@UnruffledFeathersJsData(serviceName: 'service/books')
@JsonSerializable()
class Book extends DataModel {
  @Id()
  int? id;
  String title;
  int pages;
  DateTime createdAt;

  Book({
    super.unruffledKey,
    this.id,
    required this.title,
    required this.pages,
    required this.createdAt,
  });
}
