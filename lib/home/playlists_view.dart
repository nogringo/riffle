import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:riffle/create_new_playlist_bottom_sheet/create_new_playlist_bottom_sheet_view.dart';
import 'package:riffle/home/home_controller.dart';
import 'package:riffle/models/playlist.dart';
import 'package:riffle/player/player_view.dart';
import 'package:riffle/repository.dart';

class PlaylistsView extends StatelessWidget {
  const PlaylistsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Playlists",
                      style: Get.textTheme.titleMedium,
                    ),
                    IconButton(
                      onPressed: () {
                        HomeController.to.bottomSheet =
                            const CreateNewPlaylistBottomSheetView();
                      },
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
              StreamBuilder(
                stream: Repository.to.isar.playlists.watchLazy(),
                builder: (context, snapshot) {
                  final playlists =
                      Repository.to.isar.playlists.where().findAllSync();
                  if (playlists.isEmpty) {
                    return const Center(
                      child: Text("You don't have any playlist"),
                    );
                  }
                  return Column(
                    children: playlists
                        .map((e) => PlaylistView(playlist: e))
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
        const PlayerView(),
      ],
    );
  }
}

class PlaylistView extends StatelessWidget {
  final Playlist playlist;

  const PlaylistView({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(builder: (context, constraints) {
            return Column(
              children: [
                Container(
                  // margin: EdgeInsets.only(bottom: 3),
                  height: 8,
                  width: constraints.maxWidth * 0.6,
                  decoration: BoxDecoration(
                    color: Get.theme.colorScheme.onPrimary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                ),
                Container(
                  // margin: EdgeInsets.only(bottom: 3),
                  height: 8,
                  width: constraints.maxWidth * 0.8,
                  decoration: BoxDecoration(
                    color: Get.theme.colorScheme.primary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                ),
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    children: [
                      if (playlist.musics.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(
                            File(playlist.musics.first.thumbnailPath),
                          ),
                        ),
                      if (playlist.musics.isEmpty)
                        Container(
                          decoration: BoxDecoration(
                            color: Get.theme.colorScheme.inversePrimary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: Chip(
                          label: Text("${playlist.musics.length} Musics"),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                20.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(playlist.name),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
