import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:riffle/desktop_windows_buttons.dart';
import 'package:riffle/repository.dart';
import 'package:toastification/toastification.dart';
import 'package:window_manager/window_manager.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (GetPlatform.isDesktop) windowManager.startDragging();
      },
      child: AppBar(
        title: const Text("Riffle"),
        actions: [
          IconButton(
            tooltip: "Export your data",
            onPressed: () async {
              Clipboard.setData(
                ClipboardData(text: jsonEncode(Repository.to.musicList)),
              );
              toastification.show(
                style: ToastificationStyle.simple,
                title: const Text("Your data has been copied in the clipboard"),
                alignment: Alignment.bottomCenter,
                autoCloseDuration: const Duration(seconds: 4),
                applyBlurEffect: true,
              );
            },
            icon: const Icon(Icons.upload),
          ),
          if (GetPlatform.isDesktop) const DesktopWindowButtons(),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
