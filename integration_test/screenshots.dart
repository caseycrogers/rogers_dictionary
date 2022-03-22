import 'dart:async';
import 'dart:convert';

import 'package:device_frame/device_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:rogers_dictionary/dictionary_app.dart';
import 'package:rogers_dictionary/screenshot_template.dart';
import 'package:rogers_dictionary/util/string_utils.dart';

import '../test_driver/screenshots_test.dart';

const Locale en = Locale('en', '');
const Locale es = Locale('es', '');

Future<void> main() async {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized()
      as IntegrationTestWidgetsFlutterBinding;
  WidgetsApp.debugAllowBannerOverride = false;

  setUpAll(() async {
    await binding.convertFlutterSurfaceToImage();
  });

  final double pixelRatio = binding.window.devicePixelRatio;

  for (final Locale locale in [en, es]) {
    for (final DeviceInfo device in [
      Devices.ios.iPhone13ProMax,
      Devices.android.onePlus8Pro,
    ]) {
      String screenshotName(String suffix) {
        return jsonEncode(
          ScreenshotIdentifier(
            path: [
              device.identifier.platform.name.enumString,
              device.name,
              locale.languageCode,
              suffix,
            ],
            width: (device.screenSize.width * pixelRatio).toInt(),
            height: (device.screenSize.height * pixelRatio).toInt(),
          ),
        );
      }

      testWidgets('take screenshot', (WidgetTester tester) async {
        await tester.pumpWidget(
          ScreenshotTemplate(
            headerText: 'Search thousands of terms!',
            background: Container(
              color: DictionaryApp.englishColorScheme.primary,
            ),
            device: device,
            child: DictionaryAppBase(overrideLocale: locale),
          ),
        );
        await tester.pump();
        await tester.pump();
        await binding.takeScreenshot(screenshotName('01'));
      });
    }
  }
}

Future<void> pollUntil(
  WidgetTester tester,
  bool Function() test, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  await (() async {
    while (true) {
      if (test()) {
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await tester.pump();
    }
  })()
      .timeout(timeout);
}

Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  bool timerDone = false;
  final timer =
      Timer(timeout, () => throw TimeoutException('Pump until has timed out'));
  while (timerDone != true) {
    await tester.pump();
    final found = tester.any(finder);
    if (found) {
      timerDone = true;
    }
  }
  timer.cancel();
}
