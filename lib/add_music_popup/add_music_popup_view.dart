import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riffle/add_music_popup/add_music_popup_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddMusicPopupView extends StatelessWidget {
  const AddMusicPopupView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AddMusicPopupController());
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
                AppLocalizations.of(context)!
                    .enterAYoutubeVideoLinkToAddANewMusic,
              );
            },
          ),
          const SizedBox(height: 12),
          GetBuilder<AddMusicPopupController>(
            builder: (controller) {
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
            onPressed: controller.addMusic,
            child: Text(
              AppLocalizations.of(context)!.add,
            ),
          );
        }),
      ],
    );
  }
}
