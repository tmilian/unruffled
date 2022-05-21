import 'package:json_annotation/json_annotation.dart';
import 'package:unruffled/unruffled.dart';

part 'book.g.dart';

mixin FeathersJsRemoteRepository<T extends DataModel<T>>
    on RemoteRepository<T> {
  @override
  Map<String, dynamic> parseAndCondition(List<FilterOperation<T>> operations) {
    return super.parseAndCondition(operations);
  }
}

@UnruffledData(adapter: FeathersJsRemoteRepository)
@JsonSerializable()
class Book extends DataModel<Book> {
  @override
  int? id;
  String title;
  DateTime createdAt;

  Book({super.key, this.id, required this.title, required this.createdAt});
}
