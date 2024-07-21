// import 'dart:convert';

// import 'package:riffle/models/music.dart';
// import 'package:riffle/models/playlist.dart';
// import 'package:riffle/repository.dart';

// class LocalStorage {
//   String? mnemonic;
//   Map<String, Music> musics = {};
//   Map<String, Playlist> playlists = {};
//   List history = [];

//   LocalStorage() {
//     String rawLocalStorage = Repository.to.box.read("localStorage");
//     Map<String, dynamic> jsonLocalStorage = jsonDecode(rawLocalStorage);

//     mnemonic = jsonLocalStorage["mnemonic"];
//   }

//   Map<String, dynamic> toJson() {
//     Map<String, dynamic> result = {
//       "musics": musics.map((key, value) => MapEntry(key, value.toJson())),
//       "playlists": playlists.map((key, value) => MapEntry(key, value.toJson())),
//       "history": history
//     };

//     if (mnemonic != null) result["mnemonic"] = mnemonic;

//     return result;
//   }
// }
