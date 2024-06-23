import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riffle/sync_popup/sync_popup_controller.dart';

class SyncPopupView extends StatelessWidget {
  const SyncPopupView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SyncPopupController());
    return AlertDialog(
      title: const Row(
        children: [
          Text("Sync your devices"),
          SizedBox(width: 8),
          CloseButton(),
        ],
      ),
      content: Focus(
        onFocusChange: SyncPopupController.to.onFocusChange,
        child: GetBuilder<SyncPopupController>(
          builder: (c) {
            return TextField(
              controller: c.syncCodeController,
              decoration: InputDecoration(
                labelText: "Sync code",
                suffixIcon: Builder(
                  builder: (context) {
                    if (GetPlatform.isMobile) {
                      return PopupMenuButton(
                        onSelected: c.selectSyncPopupValue,
                        itemBuilder: (BuildContext context) {
                          return [
                            const PopupMenuItem(
                              value: SyncPopupMenu.generateSyncCode,
                              child: ListTile(
                                leading: Icon(Icons.generating_tokens),
                                title: Text("Generate your Sync code"),
                              ),
                            ),
                            if (GetPlatform.isMobile)
                              const PopupMenuItem(
                                value: SyncPopupMenu.scanQrCode,
                                child: ListTile(
                                  leading: Icon(Icons.qr_code_scanner),
                                  title: Text("Scan QR code"),
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
                errorText: [null, "Field required"][c.syncCodeError],
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
          child: const Text("Cancel"),
        ),
        FilledButton(
          onPressed: SyncPopupController.to.startSync,
          child: const Text("Start sync"),
        ),
      ],
    );
  }
}
