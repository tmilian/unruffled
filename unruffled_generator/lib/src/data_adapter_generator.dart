import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/visitor.dart';
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
    final classType = element.name;
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
    final remoteAdapterTypeChecker = TypeChecker.fromRuntime(RemoteRepository);
    List<String> mixins = [];
    try {
      var obj = annotation.read('adapter').objectValue;
      final mixinType = obj.toTypeValue() as ParameterizedType;

      final args = mixinType.typeArguments;

      final mixinElement = mixinType.element2;

      if (mixinElement is! ClassElement) {
        throw UnsupportedError('Ensure that your mixin is correctly defined');
      }

      if (args.length > 1) {
        throw UnsupportedError(
            'Adapter `$mixinType` MUST have at most one type argument (T extends DataModel<T>) is supported for $mixinType');
      }

      if (!remoteAdapterTypeChecker.isAssignableFromType(mixinType)) {
        throw UnsupportedError(
            'Adapter `$mixinType` MUST have a constraint `on` RemoteAdapter<$classType>');
      }
      for (var value in mixinElement.allSupertypes) {
        if (value.element2 is MixinElement && !value.element2.isPrivate) {
          final mixinType = (value.element2 as ClassElement).instantiate(
              typeArguments: [if (args.isNotEmpty) element.thisType],
              nullabilitySuffix: NullabilitySuffix.none);
          mixins.add(mixinType.getDisplayString(withNullability: false));
        }
      }
      final mainType = (mixinType.element2 as ClassElement).instantiate(
          typeArguments: [if (args.isNotEmpty) element.thisType],
          nullabilitySuffix: NullabilitySuffix.none);
      mixins.add(mainType.getDisplayString(withNullability: false));
    } catch (e) {}
    final visitor = ModelVisitor();
    element.visitChildren(visitor);
    if (visitor.ids.length != 1) {
      throw UnsupportedError('Ensure to define a unique @Id annotation');
    }
    final serviceName = annotation.peek('serviceName')?.stringValue;
    StringBuffer buffer = StringBuffer();
    buffer.writeln('''
    class ${element.name}Adapter extends DataAdapter<${element.name}> {
      @override
      Map<String, dynamic> serialize(${element.name} model) => _\$${element.name}ToJson(model);

      @override
      ${element.name} deserialize(Map<String, dynamic> map) => _\$${element.name}FromJson(map);
      
      @override
      String? key(${element.name}? model) => model?.${visitor.ids.keys.first}${visitor.ids.values.first ? '?' : ''}.toString() ?? model?.unruffledKey;
    ''');
    if (serviceName != null) {
      buffer.writeln('''
      @override
      String get serviceName => '$serviceName';
      ''');
    }
    buffer.writeln('}');
    if (mixins.isNotEmpty) {
      buffer.writeln('''
      class \$${element.name}RemoteRepository = RemoteRepository<${element.name}> with ${mixins.join(', ')};
      ''');
    }
    buffer.writeln('''
    class ${element.name}Repository extends ${mixins.isNotEmpty ? '\$${element.name}RemoteRepository' : 'RemoteRepository<${element.name}>'} {
      ${element.name}Repository() : super(${element.name}Adapter());
    }
    ''');
    buffer.writeln(
        'class ${element.name}Field extends UnruffledField<${element.name}> {');
    for (final field in visitor.fields.keys) {
      buffer.writeln("${element.name}Field.$field() : super('$field');");
    }
    buffer.writeln('}');
    final isNullable = visitor.ids.values.first;
    buffer.writeln('''
    extension ${element.name}UnruffledExt on ${element.name} {''');
    if (isNullable) {
      buffer.writeln(
          'String get key => ${visitor.ids.keys.first}?.toString() ?? unruffledKey;');
    } else {
      buffer.writeln('String get key => ${visitor.ids.keys.first}.toString();');
    }
    buffer.writeln('}');
    return buffer.toString();
  }
}

class ModelVisitor extends SimpleElementVisitor<void> {
  late String className;
  final fields = <String, dynamic>{};
  final ids = <String, bool>{};

  @override
  void visitConstructorElement(ConstructorElement element) {
    final elementReturnType = element.type.returnType.toString();
    className = elementReturnType.replaceFirst('*', '');
  }

  @override
  void visitFieldElement(FieldElement element) {
    final elementType = element.type.toString();
    if (methodHasAnnotation(Id, element)) {
      ids[element.name] =
          element.type.nullabilitySuffix == NullabilitySuffix.question;
    }
    fields[element.name] = elementType.replaceFirst('*', '');
  }

  bool methodHasAnnotation(Type annotationType, FieldElement element) {
    final annotations =
        TypeChecker.fromRuntime(annotationType).annotationsOf(element);
    return annotations.isNotEmpty;
  }
}
