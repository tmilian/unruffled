// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GithubUser _$GithubUserFromJson(Map<String, dynamic> json) => GithubUser(
      unruffledKey: json['unruffledKey'] as String?,
      login: json['login'] as String,
      id: json['id'] as int,
      avatarUrl: json['avatar_url'] as String,
      url: json['url'] as String,
    );

Map<String, dynamic> _$GithubUserToJson(GithubUser instance) =>
    <String, dynamic>{
      'unruffledKey': instance.unruffledKey,
      'login': instance.login,
      'id': instance.id,
      'avatar_url': instance.avatarUrl,
      'url': instance.url,
    };

// **************************************************************************
// DataAdapterGenerator
// **************************************************************************

class GithubUserAdapter extends DataAdapter<GithubUser> {
  @override
  Map<String, dynamic> serialize(GithubUser model) => _$GithubUserToJson(model);

  @override
  GithubUser deserialize(Map<String, dynamic> map) => _$GithubUserFromJson(map);

  @override
  String? key(GithubUser? model) =>
      model?.login.toString() ?? model?.unruffledKey;

  @override
  String get serviceName => 'users';
}

class GithubUserRepository extends RemoteRepository<GithubUser> {
  GithubUserRepository() : super(GithubUserAdapter());
}

class GithubUserField extends UnruffledField<GithubUser> {
  GithubUserField.login() : super('login');
  GithubUserField.id() : super('id');
  GithubUserField.avatarUrl() : super('avatarUrl');
  GithubUserField.url() : super('url');
}

extension GithubUserUnruffledExt on GithubUser {
  String get key => login.toString();
}
