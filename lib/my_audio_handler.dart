import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:riffle/repository.dart';

class MyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  static MyAudioHandler get to => Get.find();

  AudioPlayer get player => Repository.to.player;
  Duration get playerCurrentPosition => Repository.to.playerCurrentPosition;

  MyAudioHandler() {
    player.onPlayerStateChanged.listen((event) {
      update();
    });
  }

  @override
  Future<void> play() {
    player.resume();
    return super.play();
  }

  @override
  Future<void> pause() {
    player.pause();
    return super.pause();
  }

  @override
  Future<void> seek(Duration position) {
    Repository.to.seek(position);
    return super.seek(position);
  }

  //!
  @override
  Future<void> fastForward() async {
    Repository.to.onLoopButtonPressed();
  }

  @override
  Future<void> skipToPrevious() {
    Repository.to.skipToPreviousTrack();
    return super.skipToPrevious();
  }

  @override
  Future<void> skipToNext() {
    Repository.to.skipToNextTrack();
    return super.skipToNext();
  }

  //!
  @override
  Future<void> rewind() async {
    Repository.to.replay();
  }

  void update() {
    bool isPlaying = player.state == PlayerState.playing;

    MediaControl secondBtn = MediaControl.pause;
    if (player.state == PlayerState.paused) {
      secondBtn = MediaControl.play;
    } else if (player.state == PlayerState.completed) {
      secondBtn = const MediaControl(
        androidIcon: "drawable/ic_stat_replay",
        label: "Replay button",
        action: MediaAction.rewind,
      );
    }

    playbackState.add(PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        secondBtn,
        MediaControl.skipToNext,
        MediaControl(
          androidIcon: {
            RepeatMode.noRepeat: "drawable/ic_repeat_opacity",
            RepeatMode.repeatOne: "drawable/ic_repeat_one",
            RepeatMode.repeat: "drawable/ic_stat_repeat",
          }[Repository.to.repeatMode]!,
          label: "Repeat button",
          action: MediaAction.fastForward,
        ),
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: Repository.to.selectedMusic == null
          ? AudioProcessingState.idle
          : AudioProcessingState.ready,
      playing: isPlaying,
      updatePosition: playerCurrentPosition,
      // bufferedPosition: _player.bufferedPosition,
      speed: player.playbackRate,
      // queueIndex: event.currentIndex,
    ));
  }
}
