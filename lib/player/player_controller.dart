import 'package:get/get.dart';
import 'package:riffle/models/music.dart';

class PlayerController extends GetxController {
  static PlayerController get to => Get.find();

  List<Music> queue = [];
}