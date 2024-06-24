import 'dart:io';

import 'package:path_provider/path_provider.dart';

class PathProviderService {
  static final PathProviderService _instance = PathProviderService._internal();
  late final Directory applicationDocumentsDirectory;

  factory PathProviderService() {
    return _instance;
  }

  PathProviderService._internal();

  Future<void> init() async {
    applicationDocumentsDirectory = await getApplicationDocumentsDirectory();
  }

  String get documentsPath => applicationDocumentsDirectory.path;
}
