import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
      title: const Row(
        children: [
          Icon(Icons.edit),
          SizedBox(width: 8),
          Text("Edit"),
          Spacer(),
          CloseButton(),
        ],
      ),
      content: TextField(
        controller: textEditingController,
        maxLines: null,
        decoration: const InputDecoration(
          labelText: "Title",
        ),
      ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: const Text("Cancel"),
        ),
        FilledButton(
          onPressed: onSave,
          child: const Text("Save"),
        ),
      ],
    );
  }
}
