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
  String title;
  DateTime createdAt;

  Book({String? key, int? id, required this.title, required this.createdAt})
      : super(id, key);
}
