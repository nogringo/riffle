import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:riffle/home/music_view.dart';
import 'package:riffle/models/music.dart';
import 'package:riffle/player/player_view.dart';
import 'package:riffle/repository.dart';

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
