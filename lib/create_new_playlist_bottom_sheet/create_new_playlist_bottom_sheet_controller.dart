import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riffle/home/home_controller.dart';
import 'package:riffle/models/playlist.dart';
import 'package:riffle/repository.dart';

class CreateNewPlaylistBottomSheetController extends GetxController {
  static CreateNewPlaylistBottomSheetController get to => Get.find();

  TextEditingController nameController = TextEditingController();

  String get name => nameController.text.trim();
  bool get canCreateNewPlaylist => name.isNotEmpty;

  void createNewPlaylist() async {
    if (!canCreateNewPlaylist) return;

    Playlist newPlaylist = Playlist(name: name);

    await Repository.to.isar.writeTxn(() async {
      await Repository.to.isar.playlists.put(newPlaylist);
    });

    HomeController.to.bottomSheet = null;
  }
}
