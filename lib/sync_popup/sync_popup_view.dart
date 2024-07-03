import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riffle/sync_popup/sync_popup_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SyncPopupView extends StatelessWidget {
  const SyncPopupView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SyncPopupController());
    return AlertDialog(
      title: Row(
        children: [
          Text(AppLocalizations.of(context)!.syncYourDevices),
          const SizedBox(width: 8),
          const CloseButton(),
        ],
      ),
      content: Focus(
        onFocusChange: SyncPopupController.to.onFocusChange,
        child: GetBuilder<SyncPopupController>(
          builder: (c) {
            return TextField(
              controller: c.syncCodeController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.syncCode,
                suffixIcon: Builder(
                  builder: (context) {
                    if (GetPlatform.isMobile) {
                      return PopupMenuButton(
                        onSelected: c.selectSyncPopupValue,
                        itemBuilder: (BuildContext context) {
                          return [
                            PopupMenuItem(
                              value: SyncPopupMenu.generateSyncCode,
                              child: ListTile(
                                leading: const Icon(Icons.generating_tokens),
                                title: Text(AppLocalizations.of(context)!
                                    .generateYourSyncCode),
                              ),
                            ),
                            if (GetPlatform.isMobile)
                              PopupMenuItem(
                                value: SyncPopupMenu.scanQrCode,
                                child: ListTile(
                                  leading: const Icon(Icons.qr_code_scanner),
                                  title: Text(
                                      AppLocalizations.of(context)!.scanQRCode),
                                ),
                              ),
                          ];
                        },
                      );
                    }
                    return IconButton(
                      onPressed: c.generateNewSyncCode,
                      icon: const Icon(Icons.generating_tokens),
                    );
                  },
                ),
                errorText: [
                  null,
                  AppLocalizations.of(context)!.required
                ][c.syncCodeError],
              ),
              onChanged: c.onSyncCodeChange,
              onSubmitted: (_) => c.startSync,
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        FilledButton(
          onPressed: SyncPopupController.to.startSync,
          child: Text(AppLocalizations.of(context)!.startSync),
        ),
      ],
    );
  }
}
