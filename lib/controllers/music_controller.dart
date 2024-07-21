import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riffle/api.dart';
import 'package:riffle/constant.dart';
import 'package:riffle/models/music.dart';
import 'package:path/path.dart' as path;
import 'package:riffle/path_provider_service.dart';
import 'package:riffle/repository.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class MusicController extends GetxController {
  static MusicController get to => Get.find();

  Music music;

  ColorScheme? colorScheme;

  Directory get musicDir {
    return Directory(path.join(
      PathProviderService().documentsPath,
      appName,
      "Music",
      music.youtubeVideoId,
    ));
  }

  String get thumbnailPath => path.join(musicDir.path, "thumbnail.jpg");

  bool get thumbnailExists => File(thumbnailPath).existsSync();

  MusicController({required this.music}) {
    asyncConstructor();
  }

  void asyncConstructor() async {
    if (music.title == null) fetchMetaData();
    if (!thumbnailExists) await Api().downloadThumbnail(music);
    computeThumbnailColorScheme();
  }

  fetchMetaData() async {
    final yt = YoutubeExplode();
    try {
      final videoData = await yt.videos.get(music.youtubeVideoId);

      music.title = videoData.title;
      music.duration = videoData.duration;

      await Repository.to.isar.writeTxn(() async {
        await Repository.to.isar.musics.put(music);
      });
    } catch (e) {
      print("No internet");
    }

    yt.close();
  }

  void computeThumbnailColorScheme() async {
    if (!thumbnailExists) return;

    colorScheme = await ColorScheme.fromImageProvider(
      provider: FileImage(File(thumbnailPath)),
      brightness: Get.theme.brightness,
    );
    update();
  }

  void delete() async {
    await musicDir.delete(recursive: true);

    await Repository.to.isar.writeTxn(() async {
      await Repository.to.isar.musics.delete(music.id);
    });
  }
}
