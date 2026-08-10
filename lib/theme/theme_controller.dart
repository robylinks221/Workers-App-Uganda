import 'package:flutter/material.dart';

class ThemeController {
  ThemeController._();

  static final ValueNotifier<ThemeMode> mode = ValueNotifier<ThemeMode>(
    ThemeMode.light,
  );

  static void setDarkMode(bool enabled) {
    mode.value = enabled ? ThemeMode.dark : ThemeMode.light;
  }
}
