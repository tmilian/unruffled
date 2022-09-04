// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Page _$PageFromJson(Map<String, dynamic> json) => Page(
      unruffledKey: json['unruffledKey'] as String?,
      id: json['id'] as int?,
      title: json['title'] as String,
      pages: json['pages'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$PageToJson(Page instance) => <String, dynamic>{
      'unruffledKey': instance.unruffledKey,
      'id': instance.id,
      'title': instance.title,
      'pages': instance.pages,
      'createdAt': instance.createdAt.toIso8601String(),
    };

// **************************************************************************
// DataAdapterGenerator
// **************************************************************************

class PageAdapter extends DataAdapter<Page> {
  @override
  Map<String, dynamic> serialize(Page model) => _$PageToJson(model);

  @override
  Page deserialize(Map<String, dynamic> map) => _$PageFromJson(map);

  @override
  String? key(Page? model) => model?.id?.toString() ?? model?.unruffledKey;
}

class $PageRemoteRepository = RemoteRepository<Page>
    with FeathersJsRemoteRepository<Page>, PageRemoteRepository<Page>;

class PageRepository extends $PageRemoteRepository {
  PageRepository() : super(PageAdapter());
}

class PageField extends UnruffledField<Page> {
  PageField.id() : super('id');
  PageField.title() : super('title');
  PageField.pages() : super('pages');
  PageField.createdAt() : super('createdAt');
}

extension PageUnruffledExt on Page {
  String get key => id?.toString() ?? unruffledKey;
}
