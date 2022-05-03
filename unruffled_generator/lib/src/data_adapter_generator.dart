import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:collection/collection.dart';
import 'package:unruffled/unruffled.dart';

class DataAdapterGenerator extends GeneratorForAnnotation<UnruffledData> {
  @override
  Future<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    if (element is! ClassElement) {
      throw ('Only classes may be annotated with @UnruffledData. $element');
    }
    if (element.isAbstract) {
      throw ('Class must not be abstract. $element');
    }
    if (!element.isPublic) {
      throw ('Class must be public. $element');
    }
    final constructor =
        element.constructors.firstWhereOrNull((c) => c.periodOffset == null);
    if (constructor == null) {
      throw ('Class needs an unnamed constructor.');
    }

    return '''
    class ${element.name}Adapter extends DataAdapter<${element.name}> {
      @override
      Map<String, dynamic> serialize(${element.name} model) => _\$${element.name}ToJson(model);

      @override
      ${element.name} deserialize(Map<String, dynamic> map) => _\$${element.name}FromJson(map);
    }
    ''';
  }
}
