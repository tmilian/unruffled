import 'package:json_annotation/json_annotation.dart';
import 'package:unruffled/unruffled.dart';

part 'book.g.dart';

@UnruffledData()
@JsonSerializable()
class Book extends DataModel<Book> {
  String title;
  DateTime createdAt;

  Book({String? key, int? id, required this.title, required this.createdAt})
      : super(id, key);
}
