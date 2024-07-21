import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:riffle/add_music_popup/add_music_popup_view.dart';
import 'package:riffle/edit_popup_view.dart';
import 'package:riffle/home/menu.dart';
import 'package:riffle/models/music.dart';
import 'package:riffle/repository.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeController extends GetxController {
  static HomeController get to => Get.find();

  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;
  set selectedIndex(int value) {
    _selectedIndex = value;
    update();
  }

  void menuAction(Menu menuOption, Music music) async {
    switch (menuOption) {
      case Menu.download:
        // music.fetchMetaData();
        break;
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
        music.delete();
        break;
      case Menu.saveToPlaylist:
        Get.dialog(AlertDialog(
          title: Row(
            children: [
              Text("Save to"),
              CloseButton(),
            ],
          ),
          actions: [
            TextButton(onPressed: () {
              
            }, child: Text("Create a new playlist"))
          ],
        ));
        break;
      default:
    }
  }

  void openEditMusicPopup(Music music) {
    // final textController = music.titleController;
    Get.dialog(EditPopupView(
      textEditingController: TextEditingController(),
      onSave: () {
        Get.back();
        // music.rename(textController.text);
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
      // await launchUrl(Uri.parse(File(music.thumbnailPath).parent.path));
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

  void openAddMusicPopup() {
    Get.dialog(const AddMusicPopupView());
  }

  void seek(double value) {
    int position =
        (value * Repository.to.selectedMusic!.duration!.inMilliseconds).toInt();
    Repository.to.seek(Duration(milliseconds: position));
  }

  void onDestinationSelected(int value) {
    selectedIndex = value;
  }
}
