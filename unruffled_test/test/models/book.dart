import 'package:json_annotation/json_annotation.dart';
import 'package:unruffled/unruffled.dart';

part 'book.g.dart';

@UnruffledData()
@JsonSerializable()
class Book extends DataModel<Book> {
  @override
  int? id;
  String title;
  DateTime createdAt;

  Book({this.id, required this.title, required this.createdAt});
}
