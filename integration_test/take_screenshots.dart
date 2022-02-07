import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rogers_dictionary/dictionary_app.dart';
import 'package:rogers_dictionary/models/dictionary_model.dart';

const Locale en = Locale('en', '');
const Locale es = Locale('es', '');

Future<void> main() async {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized()
      as IntegrationTestWidgetsFlutterBinding;
  if (Platform.isAndroid) {
    await binding.convertFlutterSurfaceToImage();
  }
  WidgetsApp.debugAllowBannerOverride = false;

  for (final Locale locale in [en, es]) {
    testWidgets('take screenshot', (WidgetTester tester) async {
      await tester.pumpWidget(DictionaryApp(overrideLocale: locale));
      await tester.pumpAndSettle();
      final DictionaryModel dictionaryModel = DictionaryModel.instance;
      await pollUntil(tester, () {
        return find.byKey(const ValueKey('loading')).evaluate().isEmpty;
      });
      await binding.takeScreenshot('${locale.languageCode}_01');
    });
  }
}

Future<void> pollUntil(
  WidgetTester tester,
  bool Function() test, {
  Duration timeout = const Duration(seconds: 10),
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
