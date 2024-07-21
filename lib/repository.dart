import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:isar/isar.dart';
import 'package:riffle/models/music.dart';
import 'package:riffle/my_audio_handler.dart';
import 'package:riffle/sync_popup/sync_popup_view.dart';

enum RepeatMode { noRepeat, repeatOne, repeat }

class Repository extends GetxController {
  static Repository get to => Get.find();

  late Isar isar;
  final box = GetStorage();
  Music? selectedMusic;

  final player = AudioPlayer();

  RepeatMode repeatMode = RepeatMode.noRepeat;
  PlayerState? playerStateOnSeekStart;
  Duration playerCurrentPosition = Duration.zero;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? syncSubscription;

  double get playerSeekerPosition {
    double position = playerCurrentPosition.inMilliseconds /
        selectedMusic!.duration!.inMilliseconds;
    if (position > 1) return 1;
    if (position < 0) return 0;
    return position;
  }

  String? get syncCode => box.read("syncCode");

  set syncCode(String? value) {
    if (value != null) value = value.trim();
    if (value == "") value = null;
    box.write("syncCode", value);

    if (value == null) isSyncEnabled = false;
  }

  bool get isSyncEnabled {
    if (syncCode == null) return false;
    return box.read("isSyncEnabled") ?? false;
  }

  set isSyncEnabled(bool isSyncEnabled) {
    if (isSyncEnabled) {
      listenToMusics();
    } else {
      syncSubscription?.cancel();
    }

    box.write("isSyncEnabled", isSyncEnabled);
    update();
  }

  DocumentReference<Map<String, dynamic>> get syncCodeDocRef =>
      FirebaseFirestore.instance.collection("users").doc(syncCode);

  Repository() {
    player.onPlayerStateChanged.listen((PlayerState event) {
      if (event == PlayerState.completed) {
        if (repeatMode == RepeatMode.repeatOne) {
          repeatMode = RepeatMode.noRepeat;
          replay();
        } else if (repeatMode == RepeatMode.repeat) {
          replay();
        }
      }

      update();
    });

    player.onPositionChanged.listen((newPosition) {
      playerCurrentPosition = newPosition;
      update();
    });
  }

  @override
  void update([List<Object>? ids, bool condition = true]) {
    if (GetPlatform.isMobile) MyAudioHandler.to.update();
    try {
      super.update(ids, condition);
    } catch (e) {
      //
    }
  }

  // void loadMusicList() {
  //   List<dynamic> savedMusicList = jsonDecode(box.read("music") ?? "[]");
  //   musicList = [];
  //   for (Map<String, dynamic> savedMusic in savedMusicList) {
  //     musicList.add(Music.fromJson(savedMusic));
  //   }
  //   update();

  //   if (isSyncEnabled) listenToMusics();
  // }

  void listenToMusics() {
    syncSubscription?.cancel();
    syncSubscription = syncCodeDocRef.snapshots().listen(
      (event) {
        final docData = event.data();
        if (docData == null) return;

        // if (jsonEncode(docData["musicList"]) == jsonEncode(musicList)) return;

        // musicList = [];
        // for (Map<String, dynamic> savedMusic in docData["musicList"]) {
        //   // musicList.add(Music.fromJson(savedMusic));
        // }
        // update();
        // saveMusicOnDevice();
      },
    );
  }

  void addNewMusic(Music newMusic) async {
    await isar.writeTxn(() async {
      await isar.musics.put(newMusic);
    });
  }

  void select(Music music) async {
    // if (music.colorScheme != null) {
    //   ThemeController.to.changeTheme(
    //     ThemeData.from(colorScheme: music.colorScheme!),
    //   );
    // }

    selectedMusic = music;

    if (GetPlatform.isMobile) {
      // MyAudioHandler.to.mediaItem.add(selectedMusic!.mediaItem);
    }

    if (player.source != null) await player.seek(Duration.zero);
    // player.play(DeviceFileSource(selectedMusic!.audioPath!));

    update();
  }

  resume() {
    player.resume();
  }

  pause() {
    player.pause();
  }

  void replay() async {
    // player.play(DeviceFileSource(selectedMusic!.audioPath!));
  }

  void onLoopButtonPressed() async {
    repeatMode = {
      RepeatMode.repeat: RepeatMode.noRepeat,
      RepeatMode.noRepeat: RepeatMode.repeatOne,
      RepeatMode.repeatOne: RepeatMode.repeat,
    }[repeatMode]!;
    update();
  }

  void onKeyEvent(KeyEvent value) {
    bool isKeyDown = value.runtimeType == KeyDownEvent;
    bool spacePressed = value.logicalKey.keyId == 0x00000020;

    if (spacePressed && isKeyDown) {
      if (player.state == PlayerState.playing) {
        pause();
      } else {
        resume();
      }
    }
  }

  void onSeekStart(double value) {
    playerStateOnSeekStart = player.state;
    pause();
  }

  void seek(Duration position) async {
    if (player.source == null) {
      // await player.setSourceDeviceFile(selectedMusic!.audioPath!);
    }

    player.seek(position);

    if (player.state == PlayerState.completed) {
      resume();
    }
  }

  void onSeekEnd(double value) {
    if (playerStateOnSeekStart != PlayerState.paused) {
      resume();
    }
    playerStateOnSeekStart = null;
  }

  void playPause() {
    bool isPlaying = player.state == PlayerState.playing;
    if (isPlaying) {
      pause();
      return;
    }
    resume();
  }

  void skipToPreviousTrack() {}

  void skipToNextTrack() {}

  void onSyncSwitchToggle(bool value) async {
    if (value) {
      return Get.dialog(const SyncPopupView());
    }

    isSyncEnabled = value;
  }

  void clearApp() {
    // TODO
  }
}
