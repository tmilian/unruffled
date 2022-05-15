import 'package:meta/meta_meta.dart';

/// Annotation to create an Unruffled collection.
@Target({TargetKind.classType})
class UnruffledData {
  final Type? adapter;
  const UnruffledData({this.adapter});
}
