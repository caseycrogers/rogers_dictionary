import 'package:feedback/feedback.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info/package_info.dart';

import 'package:rogers_dictionary/clients/dictionary_database/dictionary_database.dart';
import 'package:rogers_dictionary/clients/dictionary_database/sqflite_database.dart';
import 'package:rogers_dictionary/clients/feedback_sender.dart';
import 'package:rogers_dictionary/clients/snack_bar_notifier.dart';
import 'package:rogers_dictionary/clients/text_to_speech.dart';
import 'package:rogers_dictionary/models/translation_model.dart';
import 'package:rogers_dictionary/pages/dictionary_page.dart';
import 'package:rogers_dictionary/widgets/get_dictionary_feedback.dart';

class DictionaryApp extends StatefulWidget {
  const DictionaryApp({this.overrideLocale, Key? key}) : super(key: key);

  // Used for screenshot generation.
  final Locale? overrideLocale;

  // Client instances.
  static final DictionaryDatabase db = SqfliteDatabase();
  static final TextToSpeech textToSpeech = TextToSpeech();
  static final Future<PackageInfo> packageInfo = PackageInfo.fromPlatform();
  static final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static late SnackBarNotifier _snackBarNotifier;
  static late FeedbackSender _feedback;

  // Color stuff.
  static final ColorScheme englishColorScheme = ColorScheme.fromSwatch(
    primarySwatch: Colors.indigo,
    backgroundColor: Colors.grey.shade200,
  );

  static final ColorScheme spanishColorScheme = ColorScheme.fromSwatch(
    primarySwatch: Colors.orange,
    backgroundColor: Colors.grey.shade200,
  ).copyWith(onPrimary: Colors.white);

  static ColorScheme themeOf(TranslationModel translationModel) {
    if (translationModel.isEnglish) {
      return englishColorScheme;
    }
    return spanishColorScheme;
  }

  static SnackBarNotifier get snackBarNotifier => _snackBarNotifier;

  static FeedbackSender get feedback => _feedback;

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
    return Builder(
      builder: (context) {
        return BetterFeedback(
          mode: FeedbackMode.draw,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          feedbackBuilder: (context, onSubmit, controller) {
            return GetDictionaryFeedback(onSubmit, controller!);
          },
          child: Builder(
            builder: (context) {
              DictionaryApp._feedback = FeedbackSender(
                locale: Localizations.localeOf(context),
                feedbackController: BetterFeedback.of(context),
              );
              return const DictionaryAppBase();
            }
          ),
        );
      }
    );
  }
}

class DictionaryAppBase extends StatelessWidget {
  const DictionaryAppBase({this.overrideLocale, Key? key}) : super(key: key);

  final Locale? overrideLocale;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: MaterialApp(
        title: 'Rogers Dictionary',
        // Required for device frame to generate screenshots.
        useInheritedMediaQuery: true,
        home: Builder(builder: (context) {
          DictionaryApp._snackBarNotifier = SnackBarNotifier(context);
          return DictionaryPage();
        }),
        theme: ThemeData(
          selectedRowColor: Colors.grey.shade200,
          textTheme: TextTheme(
            headline1: GoogleFonts.roboto(
              color: Colors.black,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
            headline2: GoogleFonts.roboto(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            // This should really be bold but google fonts has a bug where
            // bolded styles can't be un-bolded:
            // https://github.com/material-foundation/google-fonts-flutter/issues/141
            headline3: GoogleFonts.roboto(
              color: Colors.black,
              fontSize: 22,
            ),
            bodyText2: GoogleFonts.roboto(
              color: Colors.black,
              fontSize: 20,
              // Pad the top height so that a line of text is the exact same
              // height as an icon.
              height: 24 / 20,
            ),
          ),
          iconTheme: const IconThemeData(size: 24),
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
      ),
    );
  }
}
