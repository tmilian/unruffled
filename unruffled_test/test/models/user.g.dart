// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      key: json['key'] as String?,
      id: json['id'] as int?,
      name: json['name'] as String,
      surname: json['surname'] as String,
      age: json['age'] as int? ?? 18,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'key': instance.key,
      'id': instance.id,
      'name': instance.name,
      'surname': instance.surname,
      'age': instance.age,
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

final remoteUser = RemoteRepository<User>(UserAdapter());

class UserRepository extends RemoteRepository<User> {
  UserRepository() : super(UserAdapter());
}

class UserField extends UnruffledField<User> {
  UserField.id() : super('id');
  UserField.name() : super('name');
  UserField.surname() : super('surname');
  UserField.age() : super('age');
}
