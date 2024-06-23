import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riffle/custom_app_bar.dart';
import 'package:riffle/home/home_page_controller.dart';
import 'package:riffle/home/menu.dart';
import 'package:riffle/models/music.dart';
import 'package:riffle/repository.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomePageController());

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: Repository.to.onKeyEvent,
      child: GetBuilder<Repository>(
        builder: (repository) {
          return Scaffold(
            appBar: const CustomAppBar(),
            body: GetBuilder<Repository>(
              builder: (repositoryController) {
                if (repositoryController.musicList.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Hey, there is nothing here !",
                            textAlign: TextAlign.center,
                            style: Get.textTheme.displaySmall,
                          ),
                          const SizedBox(height: 8),
                          FilledButton.icon(
                            onPressed: HomePageController.to.openAddMusicPopup,
                            label:
                                const Text("Start by adding your first Music"),
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ReorderableListView.builder(
                  padding: const EdgeInsets.only(bottom: 128),
                  onReorder: Repository.to.onReorderMusic,
                  proxyDecorator: (child, _, __) => child,
                  buildDefaultDragHandles: GetPlatform.isMobile,
                  itemCount: Repository.to.musicList.length,
                  itemBuilder: musicViewBuilder,
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: HomePageController.to.openAddMusicPopup,
              child: const Icon(Icons.add),
            ),
            bottomNavigationBar: repository.selectedMusic == null
                ? null
                : const AudioPlayerController(),
          );
        },
      ),
    );
  }
}

Widget musicViewBuilder(context, index) {
  final music = Repository.to.musicList[index];
  return GetBuilder<Music>(
    key: Key("$index"),
    init: music,
    global: false,
    builder: (musicController) {
      if (!musicController.loaded || !musicController.exists) {
        return Container();
      }

      return Theme(
        data: music.themeData,
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: ReorderableDragStartListener(
            index: index,
            enabled: GetPlatform.isDesktop,
            child: Stack(
              children: [
                Positioned.fill(
                  child: LayoutBuilder(builder: (context, constraints) {
                    return Transform.translate(
                      offset: Offset(constraints.maxWidth / 4, 0),
                      child: Image.file(
                        File(music.thumbnailPath),
                        fit: BoxFit.cover,
                      ),
                    );
                  }),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          music.themeData.colorScheme.primaryContainer,
                          music.themeData.colorScheme.primaryContainer
                              .withAlpha(150),
                          Colors.transparent,
                        ],
                        begin: const Alignment(-0.3, 0),
                      ),
                    ),
                  ),
                ),
                ListTile(
                  onTap: () {
                    Repository.to.select(music);
                  },
                  title: Text(
                    music.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: music.themeData.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  subtitle: Text(
                    "${music.duration.inMinutes}:${(musicController.duration.inSeconds % 60).toString().padLeft(2, "0")}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: music.themeData.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  trailing: PopupMenuButton(
                    iconColor: music.themeData.colorScheme.onPrimaryContainer,
                    onSelected: (value) {
                      return HomePageController.to.menuAction(value, music);
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        const PopupMenuItem(
                          value: Menu.edit,
                          child: ListTile(
                            leading: Icon(Icons.edit),
                            title: Text("Edit"),
                          ),
                        ),
                        const PopupMenuItem(
                          value: Menu.copyLink,
                          child: ListTile(
                            leading: Icon(Icons.link),
                            title: Text("Get link"),
                          ),
                        ),
                        if (GetPlatform.isDesktop)
                          const PopupMenuItem(
                            value: Menu.openFolder,
                            child: ListTile(
                              leading: Icon(Icons.folder),
                              title: Text("Open folder"),
                            ),
                          ),
                        const PopupMenuItem(
                          value: Menu.delete,
                          child: ListTile(
                            leading: Icon(Icons.delete),
                            title: Text("Delete"),
                          ),
                        ),
                      ];
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class AudioPlayerController extends StatelessWidget {
  const AudioPlayerController({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GetBuilder<Repository>(builder: (_) {
            return Image.file(
              File(Repository.to.selectedMusic!.thumbnailPath),
              fit: BoxFit.cover,
            );
          }),
        ),
        Positioned.fill(
          child: Opacity(
            opacity: 0.6,
            child: ColoredBox(
              color: Get.theme.colorScheme.primaryContainer,
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Row(
              children: [
                GetBuilder<Repository>(
                  builder: (_) {
                    switch (Repository.to.player.state) {
                      case PlayerState.playing:
                        return IconButton(
                          onPressed: Repository.to.pause,
                          icon: const Icon(Icons.pause),
                        );
                      case PlayerState.paused:
                        return IconButton(
                          onPressed: Repository.to.resume,
                          icon: const Icon(Icons.play_arrow),
                        );
                      case PlayerState.completed:
                        return IconButton(
                          onPressed: Repository.to.replay,
                          icon: const Icon(Icons.replay),
                        );
                      default:
                        return IconButton(
                          onPressed: Repository.to.replay,
                          icon: const Icon(Icons.replay),
                        );
                    }
                  },
                ),
                const SizedBox(width: 8),
                GetBuilder<Repository>(
                  builder: (repositoryController) {
                    Duration position =
                        repositoryController.playerCurrentPosition;
                    return Text(
                      "${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, "0")}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    );
                  },
                ),
                const Spacer(),
                IconButton(
                  onPressed: Repository.to.onLoopButtonPressed,
                  icon: GetBuilder<Repository>(
                    builder: (context) {
                      return Opacity(
                        opacity: Repository.to.repeatMode == RepeatMode.noRepeat
                            ? 0.5
                            : 1,
                        child: Icon(
                          Repository.to.repeatMode == RepeatMode.repeatOne
                              ? Icons.repeat_one
                              : Icons.repeat,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: -22,
          left: -24,
          right: -24,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              thumbShape: SliderComponentShape.noThumb,
              trackShape: const RectangularSliderTrackShape(),
            ),
            child: GetBuilder<Repository>(
              builder: (_) {
                return Slider(
                  value: Repository.to.playerSeekerPosition,
                  onChangeStart: Repository.to.onSeekStart,
                  onChanged: Repository.to.seek,
                  onChangeEnd: Repository.to.onSeekEnd,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
