// Dart imports:
import 'dart:async';
import 'dart:io' show Platform;

// Flutter imports:
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// Project imports:
import 'package:rogers_dictionary/clients/analytics.dart';
import 'package:rogers_dictionary/clients/local_persistence.dart';
import 'package:rogers_dictionary/dictionary_app.dart';
import 'package:rogers_dictionary/firebase_options.dart';
import 'package:rogers_dictionary/models/dictionary_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemStatusBarContrastEnforced: true,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.dark,
  ));

  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top],
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
      systemStatusBarContrastEnforced: false,
    ),
  );

  if (!(Platform.isAndroid || Platform.isIOS)) {
    return runApp(const DictionaryApp());
  }
  await initialize();
  await FirebaseCrashlytics.instance
      .setCustomKey('mode', kDebugMode ? 'debug' : 'release');
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  runApp(const DictionaryApp());
}

// Exposed so that the screenshot system can access it.
Future<void> initialize() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await MobileAds.instance.initialize();
  await LocalPersistence.instance.initialize();
  await disableIfTestDevice();

  // Don't hang or throw on logging.
  unawaited(FirebaseAnalytics.instance.setUserProperty(
    name: 'dark_mode',
    value: DictionaryModel.instance.isDark.value.toString(),
  ));
}
