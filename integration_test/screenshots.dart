import 'dart:async';

import 'package:device_frame/device_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:rogers_dictionary/dictionary_app.dart';
import 'package:rogers_dictionary/models/dictionary_model.dart';
import 'package:rogers_dictionary/screenshot_template.dart';

const Locale en = Locale('en', '');
const Locale es = Locale('es', '');

Future<void> main() async {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized()
      as IntegrationTestWidgetsFlutterBinding;
  WidgetsApp.debugAllowBannerOverride = false;

  setUpAll(() async {
    await binding.convertFlutterSurfaceToImage();
  });

  for (final Locale locale in [en, es]) {
    testWidgets('take screenshot', (WidgetTester tester) async {
      final DeviceInfo device = Devices.ios.iPhone13ProMax;
      final double pixelRatio = binding.window.devicePixelRatio;

      await tester.pumpWidget(
        ScreenshotTemplate(
          headerText: 'Search thousands of terms!',
          background: Container(
            color: DictionaryApp.englishColorScheme.primary,
          ),
          device: device,
          locale: locale,
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      final DictionaryModel dictionaryModel = DictionaryModel.instance;
      await binding.takeScreenshot(
        '${locale.languageCode}'
        '\$${(device.screenSize.width * pixelRatio).toInt()}'
        '\$${(device.screenSize.height * pixelRatio).toInt()}',
      );
    });
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
      await tester.pump();
      await Future<void>.delayed(const Duration(milliseconds: 100));
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
