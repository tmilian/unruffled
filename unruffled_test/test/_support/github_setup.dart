import 'dart:io';

import 'package:unruffled/unruffled.dart';
import 'package:dio/dio.dart';

import '../models/github_user.dart';

late Unruffled unruffled;
final hiveDir = '${Directory.current.path}/test/hive';

void setUpFn() async {
  final dio = Dio();
  dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));

  /// Create Unruffled instance
  unruffled = await Unruffled(
    baseDirectory: hiveDir,
    defaultBaseUrl: 'http://api.github.com',
    dio: dio,
  ).registerRepository(GithubUserRepository()).init();
}

void tearDownFn() async {
  await unruffled.dispose();
}

void tearDownAllFn() async {
  await Directory(hiveDir).delete(recursive: true);
}
