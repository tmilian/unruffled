class Collection<T> {
  int page;
  int limit;
  int total;
  T items;

  Collection({
    required this.page,
    required this.limit,
    required this.total,
    required this.items,
  });
}
