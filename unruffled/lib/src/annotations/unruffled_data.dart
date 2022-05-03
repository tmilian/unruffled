import 'package:meta/meta_meta.dart';

/// Annotation to create an Unruffled collection.
@Target({TargetKind.classType})
class UnruffledData {
  /// Should properties and accessors of parent classes and mixins be included?
  final bool inheritance;

  /// Allows you to override the default collection accessor.
  ///
  /// Example:
  /// ```dart
  /// @UnruffledData(accessor: 'col')
  /// class MyCol {
  ///   int? id;
  /// }
  ///
  /// // access colection using: isar.col
  /// ```
  final String? accessor;

  /// Annotation to create an Isar collection.
  const UnruffledData({this.inheritance = true, this.accessor});
}
