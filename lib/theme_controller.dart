import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:system_theme/system_theme.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find();

  ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: SystemTheme.accentColor.accent,
      brightness: Brightness.light,
    ),
  );
  ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: SystemTheme.accentColor.accent,
      brightness: Brightness.dark,
    ),
  );

  ThemeController() {
    SystemTheme.onChange.listen((color) {
      lightTheme = ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: color.accent,
          brightness: Brightness.light,
        ),
      );
      darkTheme = ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: color.accent,
          brightness: Brightness.dark,
        ),
      );
      update();
    });
  }

  void changeTheme(ThemeData newTheme) {
    lightTheme = newTheme;
    darkTheme = newTheme;
    update();
  }
}
