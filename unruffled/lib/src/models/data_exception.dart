class DataException implements Exception {
  final Object error;
  final StackTrace? stackTrace;
  final int? statusCode;

  const DataException(this.error, {this.stackTrace, this.statusCode});

  @override
  String toString() {
    return 'DataException: $error ${statusCode != null ? " [HTTP $statusCode]" : ""}\n${stackTrace ?? ''}';
  }
}

class OfflineException extends DataException {
  OfflineException({required Object error}) : super(error);
  @override
  String toString() {
    return 'OfflineException: $error';
  }
}
