import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 138,
      child: WindowCaption(
        brightness: MediaQuery.of(context).platformBrightness,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}