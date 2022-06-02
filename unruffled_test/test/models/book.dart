import 'package:json_annotation/json_annotation.dart';
import 'package:unruffled/unruffled.dart';

part 'book.g.dart';

mixin CustomRemoteRepository<T extends DataModel> on RemoteRepository<T> {
  @override
  Map<String, dynamic> parseAndCondition(List<FilterOperation<T>> operations) {
    return super.parseAndCondition(operations);
  }
}

@UnruffledData(adapter: CustomRemoteRepository)
@JsonSerializable()
class Book extends DataModel {
  @Id()
  String title;
  DateTime createdAt;

  Book({
    super.unruffledKey,
    required this.title,
    required this.createdAt,
  });
}
