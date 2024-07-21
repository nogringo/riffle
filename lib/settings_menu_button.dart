import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:riffle/repository.dart';
import 'package:riffle/scanner/mobile_scanner_overlay.dart';
import 'package:riffle/theme_controller.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
                  title: Text(AppLocalizations.of(Get.context!)!.syncCodeCopied),
                  alignment: Alignment.bottomCenter,
                  autoCloseDuration: const Duration(seconds: 4),
                  applyBlurEffect: true,
                );
              },
              leading: const Icon(Icons.copy),
              title: Text(AppLocalizations.of(context)!.copySyncCode),
            ),
          if (c.syncCode != null)
            ListTile(
              onTap: () {
                Get.dialog(const QrCodePopupView());
              },
              leading: const Icon(Icons.qr_code),
              title: Text(AppLocalizations.of(context)!.createQRCode),
            ),
          if (GetPlatform.isMobile)
            ListTile(
              onTap: () {
                Get.to(const BarcodeScannerWithOverlay());
              },
              leading: const Icon(Icons.qr_code_scanner),
              title: Text(AppLocalizations.of(context)!.scanQRCode),
            ),
          ListTile(
            onTap: () async {
              // TODO
              // await Clipboard.setData(
              //   ClipboardData(text: jsonEncode(Repository.to.musicList)),
              // );
              toastification.show(
                style: ToastificationStyle.simple,
                title: Text(
                    AppLocalizations.of(Get.context!)!.yourDataHasBeenCopied),
                alignment: Alignment.bottomCenter,
                autoCloseDuration: const Duration(seconds: 4),
                applyBlurEffect: true,
              );
            },
            leading: const Icon(Icons.upload),
            title: Text(AppLocalizations.of(context)!.exportYourData),
          ),
          ListTile(
            onTap: () {
              Get.dialog(AlertDialog(
                title: Text(AppLocalizations.of(context)!.clearAllYourData),
                content: Text(
                    AppLocalizations.of(context)!.doYouWantToClearAllYourData),
                actions: [
                  TextButton(
                    onPressed: Get.back,
                    child: Text(AppLocalizations.of(context)!.no),
                  ),
                  FilledButton(
                    onPressed: () {
                      Repository.to.clearApp();
                      Get.back();
                    },
                    child: Text(AppLocalizations.of(context)!.yes),
                  ),
                ],
              ));
            },
            leading: const Icon(Icons.clear_all),
            title: Text(AppLocalizations.of(context)!.clearAllYourData),
          ),
        ],
      );
    });
  }
}

class QrCodePopupView extends StatelessWidget {
  const QrCodePopupView({super.key});

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
