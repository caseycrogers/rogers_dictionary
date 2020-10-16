import 'dart:async';

import 'package:async/async.dart';
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
  Future<List<Entry>> getEntries({String searchString = ''});
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

  Future<List<Entry>> getEntries({String searchString = ''}) async {
    return _getEntryStream(searchString);
  }

  Future<int> getEntriesSize() async {
    await init();
    var metadata = await englishDoc().get();
    return metadata.get(_SIZE);
  }

  Future<List<Entry>> _getEntryStream(String searchString) async {
    await init();
    return _queryToEntries(await entriesCol().orderBy('articleId').get(), searchString);
  }
  
  List<Entry> _queryToEntries(QuerySnapshot query, String searchString) {
    return query.docs.map(_docToEntry).where((e) => e.article?.contains(searchString) ?? false).toList();
  }

  Entry _docToEntry(QueryDocumentSnapshot doc) {
    return Entry.fromJson(doc.data());
  }
}