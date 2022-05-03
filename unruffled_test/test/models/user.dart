import 'package:json_annotation/json_annotation.dart';
import 'package:unruffled/unruffled.dart';

part 'user.g.dart';

@UnruffledData()
@JsonSerializable()
class User extends DataModel<User> {
  @override
  int? id;
  String name;
  String surname;

  User({this.id, required this.name, required this.surname});
}
