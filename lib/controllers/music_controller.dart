import 'package:get/get.dart';
import 'package:riffle/api.dart';
import 'package:riffle/models/music.dart';
import 'package:riffle/repository.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

// class MusicController extends GetxController {
//   static MusicController get to => Get.find();

//   Music music;

//   MusicController({required this.music}) {
//     asyncConstructor();
//   }

//   void asyncConstructor() async {
//     if (music.title == null) fetchMetaData();
//     if (!music.thumbnailExists) await Api().downloadThumbnail(music);
//     music.computeThumbnailColorScheme();
//   }

//   fetchMetaData() async {
//     final yt = YoutubeExplode();
//     try {
//       final videoData = await yt.videos.get(music.youtubeVideoId);

//       music.title = videoData.title;
//       music.duration = videoData.duration;

//       await Repository.to.isar.writeTxn(() async {
//         await Repository.to.isar.musics.put(music);
//       });
//     } catch (e) {
//       print("No internet");
//     }

//     yt.close();
//   }

//   void delete() {
//     music.delete();
//   }
// }
