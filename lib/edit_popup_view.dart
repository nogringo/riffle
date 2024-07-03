import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditPopupView extends StatelessWidget {
  final TextEditingController textEditingController;
  final Function() onSave;

  const EditPopupView({
    super.key,
    required this.textEditingController,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.edit),
          const SizedBox(width: 8),
          Text(AppLocalizations.of(context)!.edit),
          const Spacer(),
          const CloseButton(),
        ],
      ),
      content: TextField(
        controller: textEditingController,
        maxLines: null,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.title,
        ),
      ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        FilledButton(
          onPressed: onSave,
          child: Text(AppLocalizations.of(context)!.save),
        ),
      ],
    );
  }
}
