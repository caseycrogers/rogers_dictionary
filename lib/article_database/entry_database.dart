import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'entry.dart';

// A database interface for fetching dictionary entries
abstract class EntryDatabase {
  // Whether or not the dictionary is in english mode or spanish mode
  bool _english = true;
  void setEnglish() => _english = true;
  void setSpanish() => _english = false;
  bool isEnglish() => _english;

  // Populate the database, for debugging only should be removed before launch
  Future<void> populate();
  // Get all entries in the database
  Future<List<Entry>> getEntries();
}

class FirestoreDatabase extends EntryDatabase {
  FirebaseFirestore _fs;

  FirestoreDatabase() {
    FirebaseFirestore _fs = FirebaseFirestore.instance;
  }
  Future<void> populate() async {
    Entry("foo", ["bar", "baz"]);
  }

  Future<List<Entry>> getEntries() async {
  }

}