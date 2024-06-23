import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riffle/repository.dart';
import 'package:uuid/uuid.dart';

enum SyncPopupMenu { generateSyncCode, scanQrCode }

class SyncPopupController extends GetxController {
  static SyncPopupController get to => Get.find();

  TextEditingController syncCodeController = TextEditingController(
    text: Repository.to.syncCode,
  );
  int syncCodeError = 0;

  String get syncCode => syncCodeController.text;

  int checkSyncCode() {
    if (syncCode.isEmpty) return 1;
    return 0;
  }

  void onFocusChange(bool hasFocus) {
    if (hasFocus) return;
    syncCodeError = checkSyncCode();
    update();
  }

  void generateNewSyncCode() {
    syncCodeController.text = const Uuid().v4();
  }

  void onSyncCodeChange(_) {
    syncCodeError = 0;
    update();
  }

  void startSync() {
    syncCodeError = checkSyncCode();
    if (syncCodeError != 0) return update();

    Repository.to.syncCode = syncCode;
    Get.back();
  }

  void selectSyncPopupValue(SyncPopupMenu value) {
    switch (value) {
      case SyncPopupMenu.generateSyncCode:
        generateNewSyncCode();
        break;
      case SyncPopupMenu.scanQrCode:
        generateNewSyncCode();
    }
  }
}
