import 'dart:async';
import 'dart:convert';

import 'package:device_frame/device_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rogers_dictionary/dictionary_app.dart';

import 'package:rogers_dictionary/i18n.dart' as i18n;
import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/models/dictionary_model.dart';
import 'package:rogers_dictionary/screenshot_template.dart';
import 'package:rogers_dictionary/util/string_utils.dart';

import '../test_driver/screenshots_test.dart';

const Locale en = Locale('en', '');
const Locale es = Locale('es', '');

Future<void> main() async {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized()
      as IntegrationTestWidgetsFlutterBinding;

  setUpAll(() async {
    WidgetsApp.debugAllowBannerOverride = false;
    await initialize();
    await DictionaryApp.analytics.setAnalyticsCollectionEnabled(false);
    await binding.convertFlutterSurfaceToImage();
  });

  tearDown(() {
    DictionaryModel.reset();
  });

  final double pixelRatio = binding.window.devicePixelRatio;

  for (final Locale locale in [
    en,
    es,
  ]) {
    for (final ScreenshotDevice device in [
      // ios.
      ScreenshotDevice(
        device: Devices.ios.iPhone13ProMax,
        outputWidth: 1284,
        outputHeight: 2778,
      ),
      ScreenshotDevice(device: Devices.ios.iPadPro11Inches),
      // Android.
      ScreenshotDevice(device: Devices.android.onePlus8Pro),
    ]) {
      String screenshotName(String suffix) {
        return jsonEncode(
          ScreenshotIdentifier(
            path: [
              device.device.identifier.platform.name.enumString,
              device.device.identifier.name,
              locale.languageCode,
              suffix,
            ],
            width: device.outputWidth.toInt(),
            height: device.outputHeight.toInt(),
            offsetY: kTopPad.toInt(),
          ),
        );
      }

      testWidgets('take screenshot', (WidgetTester tester) async {
        final DictionaryModel dictionaryModel = DictionaryModel.instance;
        await tester.pumpWidget(
          DictionaryScreenshotTemplate(
            headerText: const i18n.Message(
              'Search for 15k+ English medical translations!',
              '¡Busca más de 15k traducciones médicas en inglés!',
            ),
            device: device,
            locale: locale,
          ),
        );
        // Have to make sure
        await pumpUntil(
          tester,
          () => dictionaryModel.currTranslationModel.searchModel
              .entrySearchModel.entries.isNotEmpty,
        );
        await tester.pumpAndSettle();
        await binding.takeScreenshot(screenshotName('01-az_en'));
        dictionaryModel.onTranslationModeChanged();
        await tester.pumpWidget(
          DictionaryScreenshotTemplate(
            headerText: const i18n.Message(
              '...and 15k+ Spanish medical translations!',
              '...y más de 15k traducciones médicas al español!',
            ),
            device: device,
            locale: locale,
          ),
        );
        await tester.pumpAndSettle();
        await binding.takeScreenshot(screenshotName('02-az_es'));
      });
    }
  }
}

Future<void> pumpUntil(
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
  final timer = Timer(
    timeout,
    () => throw TimeoutException('Pump until found has timed out'),
  );
  while (timerDone != true) {
    await tester.pump();
    final found = tester.any(finder);
    if (found) {
      timerDone = true;
    }
  }
  await tester.pump();
  timer.cancel();
}
