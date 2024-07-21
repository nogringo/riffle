import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riffle/models/music.dart';
import 'package:riffle/repository.dart';

enum PopupMode { addMusic, importData }

enum ImportMode { merge, replace }

class AddMusicPopupController extends GetxController {
  static AddMusicPopupController get to => Get.find();

  PopupMode popupMode = PopupMode.addMusic;
  ImportMode importMode = ImportMode.merge;
  TextEditingController linkController = TextEditingController();
  TextEditingController exportedDataController = TextEditingController();
  int linkError = 0;
  int exportedDataError = 0;

  get isAddMusicMode => popupMode == PopupMode.addMusic;

  void linkFocusChange(bool hasFocus) {
    if (hasFocus) return;
    linkError = 0;
    update();
  }

  void exportedDataFocusChange(bool hasFocus) {
    if (hasFocus) return;
    exportedDataError = 0;
    update();
  }

  void addMusic() async {
    if (linkController.text.isEmpty) {
      linkError = 1;
      update();
      return;
    }

    // extract video id
    final id = extractId(linkController.text);
    if (!isYouTubeVideoId(id)) {
      linkError = 2;
      update();
      return;
    }

    await Repository.to.isar.writeTxn(() async {
      await Repository.to.isar.musics.put(Music(youtubeVideoId: id));
    });

    Get.back();
  }

  void setMode(PopupMode newMode) {
    popupMode = newMode;
    update();
  }

  void changeImportMode(ImportMode? value) {
    if (value != null) importMode = value;
    update();
  }
}

String extractId(String str) {
  if (!str.contains("/")) return str;

  final uri = Uri.parse(str);
  if (uri.path == "/watch") return uri.queryParameters["v"]!;

  return uri.path.split("/")[1];
}

bool isYouTubeVideoId(String input) {
  RegExp regExp = RegExp(
    r'^([A-Za-z0-9_-]{11})$', // Pattern for YouTube video ID
  );
  return regExp.hasMatch(input);
}
