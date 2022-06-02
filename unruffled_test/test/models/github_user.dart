import 'package:json_annotation/json_annotation.dart';
import 'package:unruffled/unruffled.dart';

part 'github_user.g.dart';

@UnruffledData(serviceName: 'users')
@JsonSerializable()
class GithubUser extends DataModel {
  @Id()
  String login;
  int id;
  @JsonKey(name: 'avatar_url')
  String avatarUrl;
  String url;

  Map<String, dynamic> toJson() => _$GithubUserToJson(this);

  factory GithubUser.fromJson(Map<String, dynamic> json) =>
      _$GithubUserFromJson(json);

  GithubUser({
    super.unruffledKey,
    required this.login,
    required this.id,
    required this.avatarUrl,
    required this.url,
  });
}
