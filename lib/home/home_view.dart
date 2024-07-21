import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:riffle/controllers/music_controller.dart';
import 'package:riffle/home/home_controller.dart';
import 'package:riffle/home/menu.dart';
import 'package:riffle/models/music.dart';
import 'package:riffle/player/player_controller.dart';
import 'package:riffle/player/player_view.dart';
import 'package:riffle/repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder(
            stream: Repository.to.isar.musics.watchLazy(),
            builder: (context, snapshot) {
              return ListView(
                children: Repository.to.isar.musics
                    .where()
                    .findAllSync()
                    .map(
                      (e) => MusicView(music: e),
                    )
                    .toList(),
              );
            },
          ),
        ),
        const PlayerView(),
      ],
    );
  }
}

class MusicView extends StatelessWidget {
  final Music music;

  const MusicView({super.key, required this.music});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MusicController>(
      init: music.controller,
      global: false,
      builder: (c) {
        return Card(
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              if (c.thumbnailExists)
                Positioned.fill(
                  child: LayoutBuilder(builder: (context, constraints) {
                    return Transform.translate(
                      offset: Offset(constraints.maxWidth / 4, 0),
                      child: Image.file(
                        File(c.thumbnailPath),
                        fit: BoxFit.cover,
                      ),
                    );
                  }),
                ),
              if (c.colorScheme != null)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          c.colorScheme!.primaryContainer,
                          c.colorScheme!.primaryContainer.withAlpha(150),
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
                          title: Text(AppLocalizations.of(context)!.addToQueue),
                        ),
                      ),
                      PopupMenuItem(
                        value: Menu.saveToPlaylist,
                        child: ListTile(
                          leading: const Icon(Icons.playlist_add),
                          title: Text(
                              AppLocalizations.of(context)!.saveToPlaylist),
                        ),
                      ),
                      if (music.title == null)
                        PopupMenuItem(
                          value: Menu.download,
                          child: ListTile(
                            leading: const Icon(Icons.download),
                            title: Text(AppLocalizations.of(context)!.download),
                          ),
                        ),
                      if (music.title != null)
                        PopupMenuItem(
                          value: Menu.edit,
                          child: ListTile(
                            leading: const Icon(Icons.edit),
                            title: Text(AppLocalizations.of(context)!.edit),
                          ),
                        ),
                      PopupMenuItem(
                        value: Menu.copyLink,
                        child: ListTile(
                          leading: const Icon(Icons.link),
                          title: Text(AppLocalizations.of(context)!.getLink),
                        ),
                      ),
                      if (GetPlatform.isDesktop)
                        PopupMenuItem(
                          value: Menu.openFolder,
                          child: ListTile(
                            leading: const Icon(Icons.folder),
                            title:
                                Text(AppLocalizations.of(context)!.openFolder),
                          ),
                        ),
                      PopupMenuItem(
                        value: Menu.delete,
                        child: ListTile(
                          leading: const Icon(Icons.delete),
                          title: Text(AppLocalizations.of(context)!.delete),
                        ),
                      ),
                    ];
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

String durationToReadable(Duration duration) {
  return "${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, "0")}";
}
