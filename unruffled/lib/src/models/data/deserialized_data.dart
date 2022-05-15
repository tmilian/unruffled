part of unruffled;

class DeserializedData<T> {
  const DeserializedData(this.models, {this.included = const []});
  final List<T> models;
  final List<DataModel> included;
  T? get model => models.singleOrNull;
}
