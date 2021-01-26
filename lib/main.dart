import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rogers_dictionary/entry_database/sqflite_database.dart';
import 'package:rogers_dictionary/models/search_page_model.dart';
import 'package:rogers_dictionary/util/focus_utils.dart';

import 'entry_database/entry_database.dart';
import 'pages/page_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static final Future<FirebaseApp> isInitialized = Firebase.initializeApp();
  static final EntryDatabase db = SqfliteDatabase();
  static RenderBox topRenderObject;

  @override
  Widget build(BuildContext context) {
    topRenderObject = context.findRenderObject();
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: MaterialApp(
        title: 'Dictionary',
        onGenerateRoute: PageRouter.generateRoute,
        // TODO: Initial route breaks '#' navigation, refactor away from initial route?
        initialRoute: '#/' + SearchPageModel.route,
        theme: ThemeData(
            tabBarTheme: TabBarTheme(
              labelStyle: TextStyle(
                      fontSize: 24.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)
                  .merge(GoogleFonts.openSans()),
              unselectedLabelStyle: TextStyle(
                      fontSize: 22.0,
                      color: Colors.white54,
                      fontWeight: FontWeight.bold)
                  .merge(GoogleFonts.openSans()),
              indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(width: 2.0, color: Colors.white)),
            ),
            textTheme: TextTheme(
              headline1: TextStyle(
                      fontSize: 36.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold)
                  .merge(GoogleFonts.openSans()),
              headline2: TextStyle(
                      fontSize: 22.0,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold)
                  .merge(GoogleFonts.openSans()),
              bodyText1:
                  TextStyle(fontSize: 24.0, fontWeight: FontWeight.normal)
                      .merge(GoogleFonts.openSans()),
              bodyText2:
                  TextStyle(fontSize: 20.0, fontWeight: FontWeight.normal)
                      .merge(GoogleFonts.openSans()),
            ),
            accentIconTheme: IconThemeData(
              color: Colors.black38,
            ),
            backgroundColor: Colors.white),
      ),
      onTap: () => unFocus(context),
    );
  }
}
