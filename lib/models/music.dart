import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riffle/api.dart';
import 'package:path/path.dart' as path;
import 'package:riffle/functions.dart';

class Music extends GetxController {
  static Music get to => Get.find();

  String youtubeVideoId;
  bool loaded = false;

  late bool exists;
  late String title;
  late Duration duration;
  late String thumbnailPath;
  late ThemeData themeData;

  TextEditingController get titleController =>
      TextEditingController(text: title);

  Music({required this.youtubeVideoId}) {
    load();
  }

  void load() async {
    thumbnailPath = await getThumbnailPath();

    themeData = await getThemeData();

    exists = await getExists();

    if (!exists) {
      await download();
    }

    title = await getTitle();
    duration = await getDuration();

    loaded = true;
    update();
  }

  Future<ThemeData> getThemeData() async {
    final thumbnailFile = File(thumbnailPath);

    if (!thumbnailFile.existsSync()) {
      await Api().downloadThumbnail(this);
    }

    return ThemeData.from(
      colorScheme: await ColorScheme.fromImageProvider(
        provider: FileImage(thumbnailFile),
        brightness: Brightness.dark, // TODO dynamic brightness
      ),
    );
  }

  Future<String> getAudioPath() async {
    final musicDir = await getMusicDir();
    final audioFiles =
        musicDir.listSync().where((entitie) => entitie.path.endsWith(".mp3"));

    if (audioFiles.isEmpty) {
      await Api().downloadAudio(this);
    }

    final audioPath = musicDir
        .listSync()
        .where((entitie) => entitie.path.endsWith(".mp3"))
        .first
        .path;

    return audioPath;
  }

  Future<String> getTitle() async {
    final audioPath = await getAudioPath();
    return path.basenameWithoutExtension(audioPath);
  }

  Future<Duration> getDuration() async {
    final audioPath = await getAudioPath();

    final player = AudioPlayer();
    await player.setSourceDeviceFile(audioPath);
    final duration = await player.getDuration();
    player.dispose();
    return duration!;
  }

  Future<Directory> getMusicDir() async {
    final musicDir = await Functions.getMusicDir();
    final downloadDir = Directory(path.join(
      musicDir.path,
      youtubeVideoId,
    ));
    if (!(await downloadDir.exists())) {
      await downloadDir.create(recursive: true);
    }

    return downloadDir;
  }

  Future<String> getThumbnailPath() async {
    final musicDir = await getMusicDir();
    return path.join(musicDir.path, "thumbnail.jpg");
  }

  Future<MediaItem> getMediaItem() async {
    return MediaItem(
      id: youtubeVideoId,
      title: title,
      duration: duration,
      artUri: Uri.file(
        await getThumbnailPath(),
      ),
    );
  }

  Future<bool> getAudioExists() async {
    final musicDir = await getMusicDir();
    return musicDir
        .listSync()
        .where((entitie) => entitie.path.endsWith(".mp3"))
        .isNotEmpty;
  }

  Future<bool> getThumbnailExists() async {
    final musicDir = await getMusicDir();
    return musicDir
        .listSync()
        .where((file) => path.basename(file.path) == "thumbnail.jpg")
        .isNotEmpty;
  }

  Future<bool> getExists() async {
    return await getAudioExists() && await getThumbnailExists();
  }

  Map<String, dynamic> toJson() {
    return {
      'youtubeVideoId': youtubeVideoId,
    };
  }

  factory Music.fromJson(Map<String, dynamic> json) {
    return Music(
      youtubeVideoId: json['youtubeVideoId'],
    );
  }

  Future<void> downloadAudio() async {
    await Api().downloadAudio(this);
    exists = await getExists();
    title = await getTitle();
    duration = await getDuration();
    update();
  }

  Future<void> downloadThumbnail() async {
    await Api().downloadAudio(this);
    exists = await getExists();
    title = await getTitle();
    duration = await getDuration();
    update();
  }

  Future<void> download() async {
    await Api().downloadAudio(this);
    exists = await getExists();
    title = await getTitle();
    duration = await getDuration();
    update();
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
    final musicDir = await getMusicDir();
    await musicDir.delete(recursive: true);
  }
}
