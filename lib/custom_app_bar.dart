import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:riffle/desktop_windows_buttons.dart';
import 'package:riffle/repository.dart';
import 'package:riffle/scanner/mobile_scanner_overlay.dart';
import 'package:riffle/theme_controller.dart';
import 'package:toastification/toastification.dart';
import 'package:window_manager/window_manager.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: GetPlatform.isDesktop
          ? (_) {
              windowManager.startDragging();
            }
          : null,
      behavior: HitTestBehavior.opaque,
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
          const SettingsMenuButton(),
          if (GetPlatform.isDesktop) const DesktopWindowButtons(),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class SettingsMenuButton extends StatelessWidget {
  const SettingsMenuButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<Repository>(builder: (c) {
      return MenuAnchor(
        builder:
            (BuildContext context, MenuController controller, Widget? child) {
          return IconButton(
            onPressed: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            icon: const Icon(Icons.settings),
          );
        },
        menuChildren: [
          if (c.syncCode != null)
            ListTile(
              onTap: () async {
                await Clipboard.setData(
                  ClipboardData(text: Repository.to.syncCode!),
                );
                toastification.show(
                  style: ToastificationStyle.simple,
                  title: const Text("Sync code copied"),
                  alignment: Alignment.bottomCenter,
                  autoCloseDuration: const Duration(seconds: 4),
                  applyBlurEffect: true,
                );
              },
              leading: const Icon(Icons.copy),
              title: const Text("Copy Sync code"),
            ),
          if (c.syncCode != null)
            ListTile(
              onTap: () {
                Get.dialog(const QrCodePopupView());
              },
              leading: const Icon(Icons.qr_code),
              title: const Text("Create QR code"),
            ),
          if (GetPlatform.isMobile)
            ListTile(
              onTap: () {
                Get.to(const BarcodeScannerWithOverlay());
              },
              leading: const Icon(Icons.qr_code_scanner),
              title: const Text("Scan QR code"),
            ),
          ListTile(
            onTap: () async {
              await Clipboard.setData(
                ClipboardData(text: jsonEncode(Repository.to.musicList)),
              );
              toastification.show(
                style: ToastificationStyle.simple,
                title: const Text("You data has been copied"),
                alignment: Alignment.bottomCenter,
                autoCloseDuration: const Duration(seconds: 4),
                applyBlurEffect: true,
              );
            },
            leading: const Icon(Icons.upload),
            title: const Text("Export your data"),
          ),
          ListTile(
            onTap: () async {
              Get.dialog(AlertDialog(
                title: const Text("Clear all your data"),
                content: const Text("Do you want to clear all your data ?"),
                actions: [
                  TextButton(
                    onPressed: Get.back,
                    child: const Text("No"),
                  ),
                  FilledButton(
                    onPressed: () {
                      Repository.to.clearApp();
                      Get.back();
                    },
                    child: const Text("Yes"),
                  ),
                ],
              ));
            },
            leading: const Icon(Icons.clear_all),
            title: const Text("Clear all your data"),
          ),
        ],
      );
    });
  }
}

class QrCodePopupView extends StatelessWidget {
  const QrCodePopupView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Theme(
        data: ThemeController.to.lightTheme,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: PrettyQrView.data(
              data: Repository.to.syncCode!,
              errorCorrectLevel: QrErrorCorrectLevel.H,
              decoration: PrettyQrDecoration(
                image: PrettyQrDecorationImage(
                  image: const AssetImage(
                    'assets/music_note_24dp_FILL0_wght400_GRAD0_opsz24.png',
                  ),
                  colorFilter: ColorFilter.mode(
                    Get.theme.colorScheme.primaryContainer,
                    BlendMode.srcIn,
                  ),
                ),
                shape: PrettyQrSmoothSymbol(
                  color: Get.theme.colorScheme.primaryContainer,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
