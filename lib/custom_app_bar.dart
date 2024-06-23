import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riffle/desktop_windows_buttons.dart';
import 'package:riffle/repository.dart';
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
          GetBuilder<Repository>(
            builder: (c) {
              return Switch(
                value: c.isSyncEnabled,
                onChanged: c.onSyncSwitchToggle,
                thumbIcon: const WidgetStatePropertyAll(Icon(Icons.sync)),
              );
            },
          ),
          if (GetPlatform.isDesktop) const DesktopWindowButtons(),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
