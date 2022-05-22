import 'package:meta/meta_meta.dart';

/// Annotation to create an Unruffled collection.
@Target({TargetKind.classType})
class UnruffledData {
  final Type? adapter;
  final String? serviceName;
  const UnruffledData({this.adapter, this.serviceName});
}
