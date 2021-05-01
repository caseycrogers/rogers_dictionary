import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rogers_dictionary/entry_database/sqflite_database.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/pages/search_page.dart';

import 'entry_database/dictionary_database.dart';
import 'pages/page_router.dart';

final Color englishPrimary = Colors.indigo.shade600;
final Color spanishPrimary = Colors.orange.shade600;
final Color englishSecondary = Colors.grey.shade300;
final Color spanishSecondary = Colors.grey.shade300;

Color primaryColor(TranslationMode translationMode) =>
    translationMode == TranslationMode.English
        ? englishPrimary
        : spanishPrimary;

Color secondaryColor(TranslationMode translationMode) =>
    translationMode == TranslationMode.English
        ? englishSecondary
        : spanishSecondary;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static final Future<FirebaseApp> isInitialized = Firebase.initializeApp();
  static final DictionaryDatabase db = SqfliteDatabase();
  static RenderBox topRenderObject;

  @override
  Widget build(BuildContext context) {
    topRenderObject = context.findRenderObject();
    return DefaultTabController(
      length: 5,
      child: MaterialApp(
        title: 'Dictionary',
        onGenerateRoute: PageRouter.generateRoute,
        // TODO: Initial route breaks '#' navigation, refactor away from initial route?
        initialRoute: '#/' + SearchPage.route,
        theme: ThemeData(
            textTheme: TextTheme(
              headline1: GoogleFonts.openSans(
                  fontSize: 36.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
              headline2: GoogleFonts.openSans(
                  color: Colors.black,
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold),
              bodyText1: GoogleFonts.openSans(
                  fontSize: 24.0, fontWeight: FontWeight.normal),
              bodyText2: GoogleFonts.openSans(
                  fontSize: 20.0, fontWeight: FontWeight.normal),
            ),
            iconTheme: IconThemeData(color: Colors.white, size: 28),
            accentIconTheme: IconThemeData(
              size: 28,
              color: Colors.black38,
            ),
            backgroundColor: Colors.white),
      ),
    );
  }
}
