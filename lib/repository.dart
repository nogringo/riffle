import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:riffle/models/music.dart';
import 'package:riffle/my_audio_handler.dart';
import 'package:riffle/sync_popup/sync_popup_view.dart';
import 'package:riffle/theme_controller.dart';

enum RepeatMode { noRepeat, repeatOne, repeat }

class Repository extends GetxController {
  static Repository get to => Get.find();

  final box = GetStorage();
  List<Music> musicList = [];
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
    super.update(ids, condition);
  }

  void loadMusicList() {
    List<dynamic> savedMusicList = jsonDecode(box.read("music") ?? "[]");
    musicList = [];
    for (Map<String, dynamic> savedMusic in savedMusicList) {
      musicList.add(Music.fromJson(savedMusic));
    }
    update();

    if (isSyncEnabled) listenToMusics();
  }

  void listenToMusics() {
    syncSubscription?.cancel();
    syncSubscription = syncCodeDocRef.snapshots().listen(
      (event) {
        final docData = event.data();
        if (docData == null) return;

        if (jsonEncode(docData["musicList"]) == jsonEncode(musicList)) return;

        musicList = [];
        for (Map<String, dynamic> savedMusic in docData["musicList"]) {
          musicList.add(Music.fromJson(savedMusic));
        }
        update();
        saveMusicOnDevice();
      },
    );
  }

  void saveMusicOnDevice() {
    box.write("music", jsonEncode(musicList));
  }

  void saveMusicOnFirestore() {
    if (!isSyncEnabled) return;
    syncCodeDocRef
        .set({"musicList": musicList.map((e) => e.toJson()).toList()});
  }

  void addNewMusic(Music newMusic) async {
    musicList.add(newMusic);
    update();
    saveMusicOnDevice();
    saveMusicOnFirestore();
  }

  void select(Music music) async {
    if (music.themeData != null) {
      ThemeController.to.changeTheme(music.themeData!);
    }

    selectedMusic = music;

    if (GetPlatform.isMobile) {
      MyAudioHandler.to.mediaItem.add(selectedMusic!.mediaItem);
    }

    if (player.source != null) await player.seek(Duration.zero);
    player.play(DeviceFileSource(selectedMusic!.audioPath!));

    update();
  }

  resume() {
    player.resume();
  }

  pause() {
    player.pause();
  }

  replay() async {
    player.play(DeviceFileSource(selectedMusic!.audioPath!));
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

  void seek(double value) async {
    if (player.source == null) {
      await player.setSourceDeviceFile(selectedMusic!.audioPath!);
    }

    int position = (value * selectedMusic!.duration!.inMilliseconds).toInt();
    player.seek(Duration(milliseconds: position));
  }

  void onSeekEnd(double value) {
    if (playerStateOnSeekStart != PlayerState.paused) {
      resume();
    }
    playerStateOnSeekStart = null;
  }

  void onReorderMusic(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final Music item = musicList.removeAt(oldIndex);
    musicList.insert(newIndex, item);
    update();
    saveMusicOnDevice();
    saveMusicOnFirestore();
  }

  void playPause() {
    bool isPlaying = player.state == PlayerState.playing;
    if (isPlaying) {
      pause();
      return;
    }
    resume();
  }

  void nextTrack() {}

  void skipToNext() {}

  void onSyncSwitchToggle(bool value) async {
    if (value) {
      return Get.dialog(const SyncPopupView());
    }

    isSyncEnabled = value;
  }

  void clearApp() {
    syncCode = null;
    for (Music element in musicList) {
      element.delete();
    }
    musicList = [];
  }
}
