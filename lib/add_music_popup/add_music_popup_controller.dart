import 'dart:convert';

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

  void addMusic() {
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

    Repository.to.addNewMusic(Music(youtubeVideoId: id));

    Get.back();
  }

  void import() {
    if (exportedDataController.text.isEmpty) {
      exportedDataError = 1;
      update();
      return;
    }

    String json = exportedDataController.text;
    List<Music> exportedMusicList = [];
    try {
      List<dynamic> exportedData = jsonDecode(json);
      for (var musicData in exportedData) {
        exportedMusicList.add(Music.fromJson(musicData));
      }
    } catch (e) {
      exportedDataError = 2;
      update();
      return;
    }

    if (importMode == ImportMode.merge) {
      int lastFoundIndex = -1;
      for (Music music in exportedMusicList) {
        final foundIndex = Repository.to.musicList.indexWhere(
          (e) => e.youtubeVideoId == music.youtubeVideoId,
        );
        final exist = foundIndex != -1;

        if (exist) {
          lastFoundIndex = foundIndex;
        } else {
          lastFoundIndex++;
          Repository.to.musicList.insert(lastFoundIndex, music);
        }
      }
    } else {
      for (Music music in Repository.to.musicList) {
        final exist = exportedMusicList.firstWhereOrNull(
              (e) => e.youtubeVideoId == music.youtubeVideoId,
            ) !=
            null;
        if (!exist) music.delete();
      }
      Repository.to.musicList = exportedMusicList;
    }

    Repository.to.saveMusicOnDevice();
    Repository.to.saveMusicOnFirestore();
    Repository.to.update();

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
