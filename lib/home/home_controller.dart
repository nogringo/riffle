import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:riffle/add_music_popup/add_music_popup_view.dart';
import 'package:riffle/edit_popup_view.dart';
import 'package:riffle/home/menu.dart';
import 'package:riffle/models/music.dart';
import 'package:riffle/models/playlist.dart';
import 'package:riffle/repository.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeController extends GetxController {
  static HomeController get to => Get.find();

  int _selectedIndex = 0;
  Widget? _bottomSheet;

  int get selectedIndex => _selectedIndex;
  set selectedIndex(int value) {
    _selectedIndex = value;
    update();
  }

  Widget? get bottomSheet => _bottomSheet;
  set bottomSheet(Widget? widget) {
    _bottomSheet = widget;
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
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Save to"),
              CloseButton(),
            ],
          ),
          content: StreamBuilder(
              stream: Repository.to.isar.playlists.watchLazy(),
              builder: (context, snapshot) {
                final playlists =
                    Repository.to.isar.playlists.where().findAllSync();
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: playlists.map(
                    (playlist) {
                      return FutureBuilder(
                        future: playlist.musics.load(),
                        builder: (context, snapshot) {
                          return StreamBuilder(
                            stream: Repository.to.isar.playlists.watchObject(playlist.id),
                            builder: (context, snapshot) {
                              return CheckboxListTile(
                                value: playlist.musics.any((e) => e.id == music.id),
                                title: Text(playlist.name),
                                onChanged: (value) async {
                                  if (value == true) {
                                    playlist.musics.add(music);
                                  } else {
                                    playlist.musics.remove(music);
                                  }
                              
                                  await Repository.to.isar.writeTxn(() async {
                                    await playlist.musics.save();
                                    Repository.to.isar.playlists.put(playlist);
                                  });
                                },
                              );
                            }
                          );
                        },
                      );
                    },
                  ).toList(),
                );
              }),
          actions: [
            TextButton(
              onPressed: () {},
              child: const Text("Create a new playlist"),
            )
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
