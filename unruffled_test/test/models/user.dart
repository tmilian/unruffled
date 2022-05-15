import 'package:json_annotation/json_annotation.dart';
import 'package:unruffled/unruffled.dart';

part 'user.g.dart';

@UnruffledData()
@JsonSerializable()
class User extends DataModel<User> {
  String name;
  String surname;
  int age;

  User({
    String? key,
    int? id,
    required this.name,
    required this.surname,
    this.age = 18,
  }) : super(id, key);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
