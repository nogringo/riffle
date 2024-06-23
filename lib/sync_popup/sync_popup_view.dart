import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:riffle/sync_popup/sync_popup_controller.dart';
import 'package:riffle/theme_controller.dart';

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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Focus(
            onFocusChange: SyncPopupController.to.onFocusChange,
            child: GetBuilder<SyncPopupController>(
              builder: (c) {
                return TextField(
                  controller: c.syncCodeController,
                  decoration: InputDecoration(
                    labelText: "Sync code",
                    suffixIcon: IconButton(
                      tooltip: "Generate your Sync code",
                      onPressed: c.generateNewSyncCode,
                      icon: const Icon(Icons.generating_tokens),
                    ),
                    errorText: [null, "Field required"][c.syncCodeError],
                  ),
                  onChanged: c.onSyncCodeChange,
                  onSubmitted: (_) => c.startSync,
                );
              },
            ),
          ),
          GetBuilder<SyncPopupController>(
            builder: (c) {
              if (c.syncCode.isEmpty) return Container();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: Get.height / 3,
                    maxWidth: Get.height / 3,
                  ),
                  child: Theme(
                    data: ThemeController.to.lightTheme,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: PrettyQrView.data(
                          data: c.syncCode,
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
                ),
              );
            },
          ),
        ],
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
