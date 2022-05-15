part of unruffled;

abstract class LocalRepository<T extends DataModel<T>> {
  LocalRepository(this.dataAdapter);

  Future<LocalRepository<T>> initialize();

  Future<void> dispose();

  DataAdapter<T> dataAdapter;

  Future<List<T>> getAll({QueryBuilder<T>? queryBuilder});

  Future<T?> get(String? key);

  Future<T?> getFromId(Object? id);

  Future<T> save(String key, T model);

  Future<T?> delete(String key);

  Future<void> clear();
}
