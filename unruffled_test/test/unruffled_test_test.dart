import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:unruffled/unruffled.dart';
import 'package:path/path.dart' as path;
import 'package:isar/isar.dart';

import 'models/book.dart';
import 'models/user.dart';

String? testTempPath;

// Change the path for your platform to point to a local isar core build
void registerBinaries() {
  print("register binaries");
  if (!kIsWeb && testTempPath == null) {
    final dartToolDir = path.join(Directory.current.path, '.dart_tool');
    testTempPath = path.join(dartToolDir, 'test', 'tmp');
    try {
      print("initializeLibraries");
      Isar.initializeLibraries(
        libraries: {
          'windows': path.join(dartToolDir, 'libisar_windows_x64.dll'),
          'macos': path.join(dartToolDir, 'libisar_macos_x64.dylib'),
          'linux': path.join(dartToolDir, 'libisar_linux_x64.so'),
        },
      );
    } catch (e) {
      print(e);
      // ignore. maybe this is an instrumentation test
    }
  }
}

class Post {}

void main() async {
  registerBinaries();
  var unruffled = await Unruffled(
          baseDirectory: kIsWeb ? '' : testTempPath!,
          defaultBaseUrl: 'http://localhost:3030')
      .registerAdapter(UserAdapter())
      .registerAdapter(BookAdapter())
      .init();
  print(await unruffled.getAll<User>());
}
