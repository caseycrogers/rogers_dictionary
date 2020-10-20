import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rogers_dictionary/main.dart';

import 'entry.dart';


// A database interface for fetching dictionary entries
abstract class EntryDatabase {
  // Whether or not the dictionary is in english mode or spanish mode
  bool _english = true;
  void setEnglish() => _english = true;
  void setSpanish() => _english = false;
  bool isEnglish() => _english;

  // Get all entries in the database
  Stream<Entry> getEntries({String searchString = ''});
}

class FirestoreDatabase extends EntryDatabase {
  static const String _ENTRIES_DB = "entriesDB";
  static const String _ENGLISH = "english";
  static const String _SPANISH = "spanish";
  static const String _ENTRIES = "entries";
  static const String _SIZE = "size";

  FirestoreDatabase _fs;

  Future<void> init() async {
    if (_fs != null) return Completer().complete(null);
    await MyApp.isInitialized;
  }

  DocumentReference englishDoc() {
    return FirebaseFirestore.instance.collection(_ENTRIES_DB).doc(_ENGLISH);
  }

  CollectionReference entriesCol() {
    return englishDoc().collection(_ENTRIES);
  }

  Stream<Entry> getEntries({String searchString = ''}) {
    return _getEntryStream(searchString);
  }

  Stream<Entry> _getEntryStream(String searchString) async* {
    await init();
    dynamic start = -1;
    while (true) {
      var snapshot = await entriesCol()
          .orderBy('articleId')
          .startAfter([start])
          .limit(10)
          .get();
      if (snapshot.docs.isEmpty) return;
      for (var entry in _queryToEntries(snapshot, searchString)) yield entry;
      start = snapshot.docs.last.get('articleId');
    }
  }
  
  List<Entry> _queryToEntries(QuerySnapshot query, String searchString) {
    return query.docs.map(_docToEntry).where((e) => e.keyWordMatches(searchString) ?? false).toList();
  }

  Entry _docToEntry(QueryDocumentSnapshot doc) {
    return Entry.fromJson(doc.data());
  }
}