import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:riffle/add_music_popup/add_music_popup_view.dart';
import 'package:riffle/edit_popup_view.dart';
import 'package:riffle/home/menu.dart';
import 'package:riffle/models/music.dart';
import 'package:riffle/repository.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePageController extends GetxController {
  static HomePageController get to => Get.find();

  HomePageController() {
    Repository.to.loadMusicList();
  }

  void menuAction(Menu menuOption, Music music) async {
    switch (menuOption) {
      case Menu.edit:
        openEditMusicPopup(music);
        break;
      case Menu.copyLink:
        copyMusicLink(music);
        break;
      case Menu.openFolder:
        openMusicFolder(music);
        break;
      case Menu.delete:
        deleteMusic(music);
        break;
      default:
    }
  }

  void openEditMusicPopup(Music music) {
    final textController = music.titleController;
    Get.dialog(EditPopupView(
      textEditingController: textController,
      onSave: () {
        Get.back();
        music.rename(textController.text);
      },
    ));
  }

  void copyMusicLink(Music music) async {
    final mediaLink = "https://youtu.be/${music.youtubeVideoId}";
    await Clipboard.setData(ClipboardData(text: mediaLink));
    toastification.show(
      style: ToastificationStyle.simple,
      title: Text(AppLocalizations.of(Get.context!)!.copied),
      alignment: Alignment.bottomCenter,
      autoCloseDuration: const Duration(seconds: 4),
      applyBlurEffect: true,
    );
  }

  void openMusicFolder(Music music) async {
    try {
      await launchUrl(Uri.parse(File(music.thumbnailPath).parent.path));
    } catch (e) {
      toastification.show(
        style: ToastificationStyle.simple,
        title: Text(AppLocalizations.of(Get.context!)!.cantOpenFileExplorer),
        alignment: Alignment.bottomCenter,
        autoCloseDuration: const Duration(seconds: 4),
        applyBlurEffect: true,
      );
    }
  }

  void deleteMusic(Music music) {
    Repository.to.musicList.remove(music);
    Repository.to.update();
    music.delete();
    Repository.to.saveMusicOnDevice();
    Repository.to.saveMusicOnFirestore();
  }

  void openAddMusicPopup() {
    Get.dialog(const AddMusicPopupView());
  }

  void seek(double value) {
    int position =
        (value * Repository.to.selectedMusic!.duration!.inMilliseconds).toInt();
    Repository.to.seek(Duration(milliseconds: position));
  }
}
