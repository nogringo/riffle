import 'dart:io';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as path;
import 'package:riffle/api.dart';
import 'package:riffle/constant.dart';
import 'package:riffle/path_provider_service.dart';
import 'package:riffle/repository.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

part 'music.g.dart';

@collection
class Music {
  Id id = Isar.autoIncrement;

  String youtubeVideoId;
  String? title;
  int? durationInMillisecond;
  int? startTimeInMillisecond;
  int? endTimeInMillisecond;

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
  Duration? get startTime => startTimeInMillisecond == null
      ? null
      : Duration(milliseconds: startTimeInMillisecond!);

  set startTime(Duration? value) {
    if (value == null) {
      startTimeInMillisecond = null;
      return;
    }
    startTimeInMillisecond = value.inMilliseconds;
  }

  @ignore
  Duration? get endTime => endTimeInMillisecond == null
      ? null
      : Duration(milliseconds: endTimeInMillisecond!);

  set endTime(Duration? value) {
    if (value == null) {
      endTimeInMillisecond = null;
      return;
    }
    endTimeInMillisecond = value.inMilliseconds;
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

  @ignore
  bool get isMetaDataFetched => title != null;

  @ignore
  bool get thumbnailExists => File(thumbnailPath).existsSync();

  Music({
    required this.youtubeVideoId,
    this.title,
    this.durationInMillisecond,
    this.startTimeInMillisecond,
    this.endTimeInMillisecond,
  }) {
    asyncConstructor();
  }

  void asyncConstructor() async {
    if (title == null) await fetchMetaData();
    if (!thumbnailExists) await Api().downloadThumbnail(this);
  }

  Future<ColorScheme?> getColorScheme(Brightness brightness) async {
    if (!thumbnailExists) return null;

    return ColorScheme.fromImageProvider(
      provider: FileImage(File(thumbnailPath)),
      brightness: brightness,
    );
  }

  fetchMetaData() async {
    final yt = YoutubeExplode();
    try {
      final videoData = await yt.videos.get(youtubeVideoId);

      title = videoData.title;
      duration = videoData.duration;

      await Repository.to.isar.writeTxn(() async {
        await Repository.to.isar.musics.put(this);
      });
    } catch (e) {
      print("No internet");
    }

    yt.close();
  }

  void delete() async {
    await musicDir.delete(recursive: true);

    await Repository.to.isar.writeTxn(() async {
      await Repository.to.isar.musics.delete(id);
    });
  }
}
