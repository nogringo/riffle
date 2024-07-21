import 'package:flutter/material.dart';
import 'package:riffle/player/player_view.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Expanded(
          child: Center(
            child: Text("Comming soon"),
          ),
        ),
        PlayerView(),
      ],
    );
  }
}
