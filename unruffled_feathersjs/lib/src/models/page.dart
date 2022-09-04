part of unruffled_feathersjs;

@JsonSerializable(genericArgumentFactories: true)
class Paginate<T extends DataModel> {
  int total;
  int limit;
  int skip;
  List<T> data;

  Paginate({
    required this.total,
    required this.limit,
    required this.skip,
    required this.data,
  });

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$PaginateToJson(this, toJsonT);

  factory Paginate.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$PaginateFromJson(json, fromJsonT);
}
