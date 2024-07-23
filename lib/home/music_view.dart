import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riffle/home/home_controller.dart';
import 'package:riffle/home/menu.dart';
import 'package:riffle/models/music.dart';
import 'package:riffle/player/player_controller.dart';
import 'package:riffle/repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MusicView extends StatelessWidget {
  final Music music;

  const MusicView({super.key, required this.music});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Repository.to.isar.musics.watchObject(music.id),
      builder: (context, snapshot) {
        return FutureBuilder(
            future: music.getColorScheme(Get.theme.brightness),
            builder: (context, snapshot) {
              ColorScheme? colorScheme = snapshot.data;
              if (colorScheme == null) return Container();
              return Card(
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    if (music.thumbnailExists)
                      Positioned.fill(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Transform.translate(
                              offset: Offset(constraints.maxWidth / 4, 0),
                              child: Image.file(
                                File(music.thumbnailPath),
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
                      ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primaryContainer,
                              colorScheme.primaryContainer.withAlpha(150),
                              Colors.transparent,
                            ],
                            begin: const Alignment(-0.3, 0),
                          ),
                        ),
                      ),
                    ),
                    ListTile(
                      onTap: () {
                        PlayerController.to.queue.add(music);
                      },
                      title: Text(
                        music.title ?? music.youtubeVideoId,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: music.duration == null
                          ? null
                          : Text(
                              durationToReadable(music.duration!),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      trailing: PopupMenuButton(
                        // iconColor: theme.colorScheme.onPrimaryContainer,
                        onSelected: (value) {
                          return HomeController.to.menuAction(value, music);
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            PopupMenuItem(
                              value: Menu.addToQueue,
                              child: ListTile(
                                leading: const Icon(Icons.queue),
                                title: Text(
                                    AppLocalizations.of(context)!.addToQueue),
                              ),
                            ),
                            PopupMenuItem(
                              value: Menu.saveToPlaylist,
                              child: ListTile(
                                leading: const Icon(Icons.playlist_add),
                                title: Text(AppLocalizations.of(context)!
                                    .saveToPlaylist),
                              ),
                            ),
                            if (music.title == null)
                              PopupMenuItem(
                                value: Menu.download,
                                child: ListTile(
                                  leading: const Icon(Icons.download),
                                  title: Text(
                                      AppLocalizations.of(context)!.download),
                                ),
                              ),
                            if (music.title != null)
                              PopupMenuItem(
                                value: Menu.edit,
                                child: ListTile(
                                  leading: const Icon(Icons.edit),
                                  title:
                                      Text(AppLocalizations.of(context)!.edit),
                                ),
                              ),
                            PopupMenuItem(
                              value: Menu.copyLink,
                              child: ListTile(
                                leading: const Icon(Icons.link),
                                title:
                                    Text(AppLocalizations.of(context)!.getLink),
                              ),
                            ),
                            if (GetPlatform.isDesktop)
                              PopupMenuItem(
                                value: Menu.openFolder,
                                child: ListTile(
                                  leading: const Icon(Icons.folder),
                                  title: Text(
                                      AppLocalizations.of(context)!.openFolder),
                                ),
                              ),
                            PopupMenuItem(
                              value: Menu.delete,
                              child: ListTile(
                                leading: const Icon(Icons.delete),
                                title:
                                    Text(AppLocalizations.of(context)!.delete),
                              ),
                            ),
                          ];
                        },
                      ),
                    ),
                  ],
                ),
              );
            });
      },
    );
  }
}

String durationToReadable(Duration duration) {
  return "${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, "0")}";
}
