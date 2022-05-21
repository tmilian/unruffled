part of unruffled_feathersjs;

class Paginate<T extends DataModel<T>> {
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
}
