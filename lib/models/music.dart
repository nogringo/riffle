import 'dart:io';

import 'package:isar/isar.dart';
import 'package:path/path.dart' as path;
import 'package:riffle/constant.dart';
import 'package:riffle/controllers/music_controller.dart';
import 'package:riffle/path_provider_service.dart';
import 'package:riffle/repository.dart';

part 'music.g.dart';

@collection
class Music {
  Id id = Isar.autoIncrement;

  String youtubeVideoId;
  String? title;
  int? durationInMillisecond;

  @ignore
  late MusicController controller;

  @ignore
  Duration? get duration => durationInMillisecond == null
      ? null
      : Duration(milliseconds: durationInMillisecond!);

  set duration(Duration? value) {
    if (value == null) {
      durationInMillisecond = null;
      return;
    }
    durationInMillisecond = value.inMilliseconds;
  }

  @ignore
  Directory get musicDir {
    return Directory(path.join(
      PathProviderService().documentsPath,
      appName,
      "Music",
      youtubeVideoId,
    ));
  }

  @ignore
  String get thumbnailPath => path.join(musicDir.path, "thumbnail.jpg");

  // @ignore
  // bool get isMetaDataFetched => title != null;

  // @ignore
  // bool get thumbnailExists => File(thumbnailPath).existsSync();

  Music({required this.youtubeVideoId, this.title, this.durationInMillisecond}) {
    controller = MusicController(music: this);
  }

  // fetchMetaData() async {
  //   final yt = YoutubeExplode();
  //   try {
  //     final videoData = await yt.videos.get(youtubeVideoId);

  //     title = videoData.title;
  //     duration = videoData.duration;

  //     await Repository.to.isar.writeTxn(() async {
  //       await Repository.to.isar.musics.put(this);
  //     });
  //   } catch (e) {
  //     print("No internet");
  //   }

  //   yt.close();
  // }

  // void computeThumbnailColorScheme() async {
  //   if (!thumbnailExists) return;

  //   colorScheme = await ColorScheme.fromImageProvider(
  //     provider: FileImage(File(thumbnailPath)),
  //     brightness: Get.theme.brightness,
  //   );

  //   print(colorScheme);
  // }

  void delete() async {
    await musicDir.delete(recursive: true);

    await Repository.to.isar.writeTxn(() async {
      await Repository.to.isar.musics.delete(id);
    });
  }
}
