import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class Functions {
  static Future<Directory> getMusicDir() async {
    final applicationDir = await getApplicationDocumentsDirectory();
    final musicDir = Directory(path.join(
      applicationDir.path,
      "Riffle",
      "Music",
    ));
    if (!(await musicDir.exists())) {
      await musicDir.create(recursive: true);
    }

    return musicDir;
  }
}
