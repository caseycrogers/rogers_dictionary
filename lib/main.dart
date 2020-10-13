import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/entry_list.dart';

import 'entry_database/entry_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static final Future<FirebaseApp> isInitialized = Firebase.initializeApp();
  static final EntryDatabase db = FirestoreDatabase();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dictionary',
      home: EntryList(),
    );
  }
}
