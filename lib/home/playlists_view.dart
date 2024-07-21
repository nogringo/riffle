import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
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
                        showModalBottomSheet<void>(
                          showDragHandle: true,
                          context: context,
                          constraints: const BoxConstraints(maxWidth: 640),
                          isScrollControlled: true,
                          builder: (context) {
                            return SizedBox(
                              height: 150,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text("Create new playlist"),
                                        Spacer(),
                                        TextButton(
                                          onPressed: () {
                                            Get.back();
                                          },
                                          child: Text("Cancel", style: TextStyle(color: Get.theme.colorScheme.onSurfaceVariant),),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Get.back();
                                          },
                                          child: Text("Ok"),
                                        ),
                                      ],
                                    ),
                                    TextField(
                                      decoration: InputDecoration(
                                        labelText: "Name",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
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
    return ColoredBox(
      color: Colors.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: [
                Container(
                  color: Colors.amber,
                ),
                Container(
                  color: Colors.red,
                ),
                Container(
                  color: Colors.green,
                ),
              ],
            ),
          ),
          // Text(title ?? playlist.title ?? ""),
        ],
      ),
    );
  }
}
