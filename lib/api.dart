import 'dart:io';

import 'package:get/get.dart';
import 'package:riffle/models/music.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class Api extends GetConnect {
  Future<void> downloadThumbnail(Music music) async {
    final baseUrl = "https://i3.ytimg.com/vi/${music.youtubeVideoId}/";

    http.Response response;

    response = await http.get(Uri.parse(
      "${baseUrl}maxresdefault.jpg",
    ));

    if (response.statusCode == 404) {
      response = await http.get(Uri.parse(
        "${baseUrl}hqdefault.jpg",
      ));
    }

    final file = File(music.thumbnailPath);
    await file.writeAsBytes(response.bodyBytes);
  }

  Future<void> downloadAudio(Music music) async {
    var yt = YoutubeExplode();

    var streamManifest = await yt.videos.streamsClient.getManifest(
      music.youtubeVideoId,
    );

    // Get highest quality muxed stream
    StreamInfo streamInfo = streamManifest.audioOnly.withHighestBitrate();

    // Get the actual stream
    var stream = yt.videos.streamsClient.get(streamInfo);

    // Open a file for writing.
    final musicDir = await music.getMusicDir();
    final videoData = await yt.videos.get(music.youtubeVideoId);
    final musicTitle = videoData.title
        .replaceAll("/", "")
        .replaceAll("\\", "")
        .replaceAll("*", "")
        .replaceAll("?", "")
        .replaceAll("/", "")
        .replaceAll(":", "")
        .replaceAll('"', "")
        .replaceAll("|", "");
    var file = File(path.join(musicDir.path, "$musicTitle.mp3"));
    var fileStream = file.openWrite();

    // Pipe all the content of the stream into the file.
    await stream.pipe(fileStream);

    // Close the file.
    await fileStream.flush();
    await fileStream.close();

    yt.close();
  }
}
