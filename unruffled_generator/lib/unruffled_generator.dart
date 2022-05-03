library unruffled_generator;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/data_adapter_generator.dart';

Builder getUnruffledGenerator(BuilderOptions options) =>
    SharedPartBuilder([DataAdapterGenerator()], 'unruffled_generator');
