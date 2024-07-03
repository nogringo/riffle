import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riffle/add_music_popup/add_music_popup_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddMusicPopupView extends StatelessWidget {
  const AddMusicPopupView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AddMusicPopupController());
    // TODO animate the size of the AlertDialog when the mode change
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GetBuilder<AddMusicPopupController>(
            builder: (controller) {
              return Text(
                controller.isAddMusicMode
                    ? AppLocalizations.of(context)!.addAMusic
                    : AppLocalizations.of(context)!.importYourData,
              );
            },
          ),
          const CloseButton(),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GetBuilder<AddMusicPopupController>(
            builder: (controller) {
              return Text(
                controller.isAddMusicMode
                    ? AppLocalizations.of(context)!
                        .enterAYoutubeVideoLinkToAddANewMusic
                    : AppLocalizations.of(context)!.pasteYourExportedDataBellow,
              );
            },
          ),
          const SizedBox(height: 12),
          GetBuilder<AddMusicPopupController>(
            builder: (controller) {
              if (controller.isAddMusicMode) {
                return Column(
                  children: [
                    Focus(
                      onFocusChange: controller.linkFocusChange,
                      child: TextField(
                        controller: controller.linkController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: AppLocalizations.of(context)!.videoLink,
                          errorText: [
                            null,
                            AppLocalizations.of(context)!.required,
                            AppLocalizations.of(context)!.invalide,
                          ][controller.linkError],
                        ),
                        onSubmitted: (_) => controller.addMusic(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () => controller.setMode(PopupMode.importData),
                      label:
                          Text(AppLocalizations.of(context)!.orImportYourData),
                      icon: const Icon(Icons.download),
                    ),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Focus(
                    onFocusChange: controller.exportedDataFocusChange,
                    child: TextField(
                      controller: controller.exportedDataController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: AppLocalizations.of(context)!.exportedData,
                        errorText: [
                          null,
                          AppLocalizations.of(context)!.required,
                          AppLocalizations.of(context)!.invalide,
                        ][controller.exportedDataError],
                      ),
                      onSubmitted: (_) => controller.import(),
                    ),
                  ),
                  // const SizedBox(height: 12),
                  // CupertinoSlidingSegmentedControl<ImportMode>(
                  //   groupValue: controller.importMode,
                  //   onValueChanged: controller.changeImportMode,
                  //   thumbColor: Get.theme.colorScheme.primaryContainer,
                  //   children: <ImportMode, Widget>{
                  //     ImportMode.merge: Text(
                  //       'Merge',
                  //       style: TextStyle(
                  //         color: controller.importMode == ImportMode.merge
                  //             ? Get.theme.colorScheme.onPrimaryContainer
                  //             : null,
                  //       ),
                  //     ),
                  //     ImportMode.replace: Text(
                  //       'Replace',
                  //       style: TextStyle(
                  //         color: controller.importMode == ImportMode.replace
                  //             ? Get.theme.colorScheme.onPrimaryContainer
                  //             : null,
                  //       ),
                  //     ),
                  //   },
                  // ),
                ],
              );
            },
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: Get.back,
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        GetBuilder<AddMusicPopupController>(builder: (controller) {
          return FilledButton(
            onPressed: controller.isAddMusicMode
                ? controller.addMusic
                : controller.import,
            child: Text(
              controller.isAddMusicMode
                  ? AppLocalizations.of(context)!.add
                  : AppLocalizations.of(context)!.import,
            ),
          );
        }),
      ],
    );
  }
}
