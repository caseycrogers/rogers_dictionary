import 'package:emulators/emulators.dart' as emu;

import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';

import 'package:rogers_dictionary/main.dart' as app;

void main() {
  // Disable the 'debug' banner
  WidgetsApp.debugAllowBannerOverride = false;

  // Enable flutter driver
  enableFlutterDriverExtension();

  final locale = emu.getString('locale');
  print('Device: ${emu.currentDevice()}');
  print('Locale: $locale');

  app.main();
}
