// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:feedback/feedback.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';

// Project imports:
import 'package:rogers_dictionary/clients/dictionary_database/dictionary_database.dart';
import 'package:rogers_dictionary/clients/dictionary_database/sqflite_database.dart';
import 'package:rogers_dictionary/clients/feedback_sender.dart';
import 'package:rogers_dictionary/clients/text_to_speech.dart';
import 'package:rogers_dictionary/models/dictionary_model.dart';
import 'package:rogers_dictionary/models/translation_mode.dart';
import 'package:rogers_dictionary/pages/dictionary_page.dart';
import 'package:rogers_dictionary/widgets/dictionary_feedback_view.dart';

class DictionaryApp extends StatefulWidget {
  const DictionaryApp({this.overrideLocale, Key? key}) : super(key: key);

  // Used for screenshot generation.
  final Locale? overrideLocale;

  // Client instances.
  static final DictionaryDatabase db = SqfliteDatabase();
  static final TextToSpeech textToSpeech = TextToSpeech();
  static final Future<PackageInfo> packageInfo = PackageInfo.fromPlatform();
  static final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static late ScaffoldMessengerState scaffoldMessenger;
  static late FeedbackSender feedback;

  // Color stuff.
  static final ColorScheme englishColorScheme = ColorScheme.fromSwatch(
    primarySwatch: Colors.indigo,
    backgroundColor: Colors.grey.shade200,
  ).copyWith(
    secondary: Colors.grey.shade300,
    onPrimary: Colors.white,
    outline: Colors.grey.withOpacity(.4),
  );

  static final ColorScheme spanishColorScheme = ColorScheme.fromSwatch(
    primarySwatch: Colors.orange,
    backgroundColor: Colors.grey.shade200,
  ).copyWith(
    secondary: Colors.grey.shade300,
    onPrimary: Colors.white,
    outline: Colors.grey.withOpacity(.4),
  );

  static final ColorScheme darkEnglishColorScheme = ColorScheme.fromSwatch(
    primarySwatch: Colors.indigo,
    backgroundColor: Color.lerp(Colors.white, Colors.black, .85),
    brightness: Brightness.dark,
  ).copyWith(
    primary: Color.lerp(Colors.indigo, Colors.black, .6),
    secondary: Colors.grey.shade600,
    onPrimary: Colors.white,
    surface: Color.lerp(Colors.white, Colors.black, .9),
    outline: Colors.grey.withOpacity(.4),
  );

  static final ColorScheme darkSpanishColorScheme = ColorScheme.fromSwatch(
    primarySwatch: Colors.orange,
    backgroundColor: Color.lerp(Colors.white, Colors.black, .85),
    brightness: Brightness.dark,
  ).copyWith(
    onPrimary: Colors.white,
    primary: Color.lerp(Colors.orange, Colors.black, .7),
    secondary: Colors.grey.shade600,
    surface: Color.lerp(Colors.white, Colors.black, .9),
    outline: Colors.grey.withOpacity(.4),
  );

  static ColorScheme schemeFor(
    TranslationMode translationMode,
    bool isDark,
  ) {
    if (translationMode == TranslationMode.English) {
      return isDark ? darkEnglishColorScheme : englishColorScheme;
    }
    return isDark ? darkSpanishColorScheme : spanishColorScheme;
  }

  static FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  _DictionaryAppState createState() => _DictionaryAppState();
}

class _DictionaryAppState extends State<DictionaryApp> {
  @override
  Future<void> dispose() async {
    try {
      await DictionaryApp.textToSpeech.dispose();
      await DictionaryApp.db.dispose();
      await DictionaryApp.feedback.dispose();
    } finally {
      super.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BetterFeedback(
      mode: FeedbackMode.draw,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      feedbackBuilder: (context, onSubmit, controller) {
        return DictionaryFeedbackView(onSubmit, controller!);
      },
      // Builder is here to ensure that `BetterFeedback.of(context)` gets a
      // context with an enclosing better feedback widget.
      child: Builder(
        builder: (context) {
          DictionaryApp.feedback = FeedbackSender(
            locale: Localizations.localeOf(context),
            feedbackController: BetterFeedback.of(context),
          );
          return const DictionaryAppBase();
        },
      ),
    );
  }
}

class DictionaryAppBase extends StatelessWidget {
  const DictionaryAppBase({
    super.key,
    this.overrideLocale,
    this.overridePlatform,
  });

  final Locale? overrideLocale;
  final TargetPlatform? overridePlatform;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: ValueListenableBuilder<bool>(
        valueListenable: DictionaryModel.instance.isDark,
        builder: (context, isDark, child) {
          return MaterialApp(
            title: 'Rogers Dictionary',
            home: child!,
            theme: ThemeData(
              platform: overridePlatform,
              dividerTheme: DividerThemeData(
                color: Colors.grey.withOpacity(.4),
              ),
              textTheme: TextTheme(
                displayLarge: GoogleFonts.roboto(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
                displayMedium: GoogleFonts.roboto(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                // This should really be bold but google fonts has a bug where
                // bolded styles can't be un-bolded:
                // https://github.com/material-foundation/google-fonts-flutter/issues/141
                displaySmall: GoogleFonts.roboto(
                  fontSize: 22,
                ),
                bodyMedium: GoogleFonts.roboto(
                  fontSize: 20,
                  // Pad the top height so that a line of text is the exact same
                  // height as an icon.
                  height: 24 / 20,
                ),
              ).apply(
                displayColor: isDark ? Colors.grey.shade300 : Colors.black,
                bodyColor: isDark ? Colors.grey.shade300 : Colors.black,
              ),
              iconTheme: IconThemeData(
                size: 24,
                color: Colors.grey.shade600,
              ),
              chipTheme: ChipThemeData(
                backgroundColor: DictionaryModel.instance.isDark.value
                    ? Colors.white38
                    : Colors.black12,
                labelStyle: TextStyle(
                  color: DictionaryModel.instance.isDark.value
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            locale: overrideLocale,
            supportedLocales: const [
              Locale('en', ''),
              Locale('es', ''),
            ],
          );
        },
        child: Builder(
          builder: (context) {
            DictionaryApp.scaffoldMessenger = ScaffoldMessenger.of(context);
            return const DictionaryPage();
          },
        ),
      ),
    );
  }
}
