import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riffle/api.dart';
import 'package:path/path.dart' as path;
import 'package:riffle/constant.dart';
import 'package:riffle/path_provider_service.dart';
import 'package:riffle/repository.dart';
import 'package:toastification/toastification.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class Music extends GetxController {
  static Music get to => Get.find();

  String youtubeVideoId;

  String? title;
  Duration? duration;

  ColorScheme? colorScheme;

  late String thumbnailPath;

  ThemeData? get themeData {
    if (colorScheme == null) return null;
    return ThemeData.from(colorScheme: colorScheme!);
  }

  TextEditingController get titleController {
    return TextEditingController(text: title);
  }

  MediaItem get mediaItem {
    return MediaItem(
      id: youtubeVideoId,
      title: title ?? youtubeVideoId,
      duration: duration,
      artUri: Uri.file(
        thumbnailPath,
      ),
    );
  }

  Directory get musicDir {
    return Directory(path.join(
      PathProviderService().documentsPath,
      appName,
      "Music",
      youtubeVideoId,
    ));
  }

  bool get thumbnailExists => File(thumbnailPath).existsSync();
  bool get audioExists => musicDir
      .listSync()
      .where((entitie) => entitie.path.endsWith(".mp3"))
      .isNotEmpty;

  String? get audioPath {
    try {
      return musicDir
          .listSync()
          .where((entitie) => entitie.path.endsWith(".mp3"))
          .first
          .path;
    } catch (e) {
      return null;
    }
  }

  Music({required this.youtubeVideoId, this.title, this.duration}) {
    thumbnailPath = path.join(
      musicDir.path,
      "thumbnail.jpg",
    );

    if (thumbnailExists) {
      computeThumbnailColorScheme();
    } else {
      asyncConstructor();
    }
  }

  void asyncConstructor() async {
    try {
      await download();
    } catch (e) {
      //
    }
  }

  Future<void> download() async {
    try {
      await downloadMetaData();
      await downloadAudio();
    } catch (e) {
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        title: const Text("Download error"),
        description: const Text("Check your internet connectivity"),
        alignment: Alignment.bottomLeft,
        borderRadius: BorderRadius.circular(12.0),
        applyBlurEffect: true,
        showProgressBar: false,
        closeOnClick: true,
        icon: const Icon(Icons.wifi_off)
      );
    }
  }

  Future<void> downloadMetaData() async {
    final yt = YoutubeExplode();
    final videoData = await yt.videos.get(youtubeVideoId);
    title = videoData.title;
    duration = videoData.duration;
    yt.close();

    await Api().downloadThumbnail(this);
    computeThumbnailColorScheme();

    update();
    Repository.to.saveMusicOnDevice();
    Repository.to.saveMusicOnFirestore();
  }

  Future<void> downloadAudio() async {
    await Api().downloadAudio(this);
    update();
  }

  void computeThumbnailColorScheme() async {
    if (!thumbnailExists) return;

    colorScheme = await ColorScheme.fromImageProvider(
      provider: FileImage(File(thumbnailPath)),
      brightness: Get.theme.brightness,
    );
    update();
  }

  Future<String> getTitle() async {
    if (title != null) return title!;
    var yt = YoutubeExplode();
    final videoData = await yt.videos.get(youtubeVideoId);
    title = videoData.title;
    yt.close();
    update();
    return title!;
  }

  Future<Duration> getDuration() async {
    if (duration != null) return duration!;
    if (audioPath != null) {
      final player = AudioPlayer();
      await player.setSourceDeviceFile(audioPath!);
      final duration = await player.getDuration();
      player.dispose();
      update();
      return duration!;
    }
    var yt = YoutubeExplode();
    final videoData = await yt.videos.get(youtubeVideoId);
    duration = videoData.duration;
    yt.close();
    update();
    return duration!;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {
      'youtubeVideoId': youtubeVideoId,
    };

    if (title != null) result["title"] = title!;
    if (duration != null) result["duration"] = duration!.inMilliseconds;

    return result;
  }

  factory Music.fromJson(Map<String, dynamic> json) {
    return Music(
      youtubeVideoId: json['youtubeVideoId'],
      title: json["title"],
      duration: json["duration"] != null
          ? Duration(milliseconds: json["duration"])
          : null,
    );
  }

  Future<void> rename(String newName) async {
    // final parentDir = Directory(filePath).parent;
    // final newPath = path.join(parentDir.path, "$newName$extension");
    // await File(filePath).rename(newPath);
    // filePath = newPath;
    // update();
    // return;
  }

  Future<void> delete() async {
    try {
      await musicDir.delete(recursive: true);
    } catch (e) {
      //
    }
  }
}
