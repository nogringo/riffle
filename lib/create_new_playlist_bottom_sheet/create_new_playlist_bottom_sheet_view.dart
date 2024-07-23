import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riffle/create_new_playlist_bottom_sheet/create_new_playlist_bottom_sheet_controller.dart';
import 'package:riffle/home/home_controller.dart';

class CreateNewPlaylistBottomSheetView extends StatelessWidget {
  const CreateNewPlaylistBottomSheetView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(CreateNewPlaylistBottomSheetController());
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text("Create new playlist"),
              const Spacer(),
              TextButton(
                onPressed: () {
                  HomeController.to.bottomSheet = null;
                },
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: Get.theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              GetBuilder<CreateNewPlaylistBottomSheetController>(
                builder: (c) {
                  return TextButton(
                    onPressed:
                        c.canCreateNewPlaylist ? c.createNewPlaylist : null,
                    child: const Text("Ok"),
                  );
                },
              ),
            ],
          ),
          TextField(
            controller: CreateNewPlaylistBottomSheetController.to.nameController,
            focusNode: FocusNode()..requestFocus(),
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: "Name",
            ),
            onChanged: (_) =>
                CreateNewPlaylistBottomSheetController.to.update(),
            onSubmitted: (_) =>
                CreateNewPlaylistBottomSheetController.to.createNewPlaylist(),
          ),
        ],
      ),
    );
  }
}
