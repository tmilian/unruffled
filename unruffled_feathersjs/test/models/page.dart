import 'package:json_annotation/json_annotation.dart';
import 'package:unruffled/unruffled.dart';
import 'package:unruffled_feathersjs/unruffled_feathersjs.dart';

part 'page.g.dart';

mixin PageRemoteRepository<T extends DataModel>
    on FeathersJsRemoteRepository<T> {
  Future<void> syncGitlabVariable({required Object key}) async {
    final path = url(
      method: RequestMethod.get,
      pathParams: {'id': key},
    );
    return await sendRequest<void>(
      url: '$path/gitlab',
      method: RequestMethod.post,
      onSuccess: (data) async {},
      onError: (e) => throw e,
    );
  }
}

@UnruffledFeathersJsData(adapter: PageRemoteRepository)
@JsonSerializable()
class Page extends DataModel {
  @Id()
  int? id;
  String title;
  int pages;
  DateTime createdAt;

  Page({
    super.unruffledKey,
    this.id,
    required this.title,
    required this.pages,
    required this.createdAt,
  });
}
