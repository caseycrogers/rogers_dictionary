import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/entry_list.dart';

import 'article_database/entry_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dictionary',
      home: ArticleList(),
    );
  }
}
