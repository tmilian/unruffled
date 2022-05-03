// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as int?,
      name: json['name'] as String,
      surname: json['surname'] as String,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'surname': instance.surname,
    };

// **************************************************************************
// DataAdapterGenerator
// **************************************************************************

class UserAdapter extends DataAdapter<User> {
  @override
  Map<String, dynamic> serialize(User model) => _$UserToJson(model);

  @override
  User deserialize(Map<String, dynamic> map) => _$UserFromJson(map);
}
