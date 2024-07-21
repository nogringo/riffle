import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlayerView extends StatelessWidget {
  const PlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kToolbarHeight,
      color: Get.theme.colorScheme.primaryContainer,
      child: Stack(
        children: [
          Slider(
            value: 1,
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }
}
