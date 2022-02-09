import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:rogers_dictionary/models/translation_model.dart';

import 'dictionary_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!(Platform.isAndroid || Platform.isIOS)) {
    return runApp(const DictionaryApp());
  }
  await initialize();
  return runZonedGuarded<void>(
    () async {
      await FirebaseCrashlytics.instance
          .setCustomKey('mode', kDebugMode ? 'debug' : 'release');
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

      runApp(const DictionaryApp());
    },
    FirebaseCrashlytics.instance.recordError,
  );
}

// Exposed so that the screenshot system can access it.
Future<void> initialize() async {
  await Firebase.initializeApp();
  await MobileAds.instance.initialize();
}