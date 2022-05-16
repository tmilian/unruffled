/// Support for doing something awesome.
///
/// More dartdocs go here.
library unruffled;

import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:recase/recase.dart';
import 'package:unruffled/src/models/offline/offline_operation.dart';
import 'package:uuid/uuid.dart';

export 'src/annotations/unruffled_data.dart';
export 'src/models/offline/offline_operation.dart';

part 'src/extensions/dynamic.dart';
part 'src/models/data/data_adapter.dart';
part 'src/models/data/data_exception.dart';
part 'src/models/data/data_model.dart';
part 'src/models/data/deserialized_data.dart';
part 'src/models/query/query_builder.dart';
part 'src/models/query/unruffled_field.dart';
part 'src/repositories/internal/offline_repository.dart';
part 'src/repositories/internal/type_manager.dart';
part 'src/repositories/local/hive_local_storage.dart';
part 'src/repositories/local/local_query_parser.dart';
part 'src/repositories/local/local_repository.dart';
part 'src/repositories/local/local_repository_impl.dart';
part 'src/repositories/remote/remote_query_parser.dart';
part 'src/repositories/remote/remote_repository.dart';
part 'src/unruffled.dart';
