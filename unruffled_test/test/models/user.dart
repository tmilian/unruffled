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
  int age;

  User({
    super.key,
    this.id,
    required this.name,
    required this.surname,
    this.age = 18,
  });

  Map<String, dynamic> toJson() => _$UserToJson(this);

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
