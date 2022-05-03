import 'package:collection/collection.dart';
import 'package:unruffled/src/models/data_model.dart';

class DeserializedData<T> {
  const DeserializedData(this.models, {this.included = const []});
  final List<T> models;
  final List<DataModel> included;
  T? get model => models.singleOrNull;
}
