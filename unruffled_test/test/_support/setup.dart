import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:unruffled/unruffled.dart';

import '../models/book.dart';
import '../models/user.dart';

late DioAdapter dioAdapter;
late Unruffled unruffled;

void setUpFn() async {
  final hiveDir = '${Directory.current.path}/test/hive';
  Dio dio = Dio();
  dioAdapter = DioAdapter(dio: dio);

  /// Create Unruffled instance
  unruffled = await Unruffled(
          baseDirectory: hiveDir,
          defaultBaseUrl: 'http://example.com',
          dio: dio)
      .registerRepository(UserRepository())
      .registerRepository(BookRepository())
      .init();
}

void tearDownFn() async {
  await unruffled.dispose();
}
