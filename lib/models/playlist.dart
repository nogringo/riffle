import 'package:isar/isar.dart';
import 'package:riffle/models/music.dart';

part 'playlist.g.dart';

@collection
class Playlist {
  Id id = Isar.autoIncrement;

  String name;
  final musics = IsarLinks<Music>();

  Playlist({required this.name});
}
