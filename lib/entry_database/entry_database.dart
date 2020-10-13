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
  StreamQueue<Entry> getEntries();

  // Get number of entries
  Future<int> getEntriesSize();
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

  StreamQueue<Entry> getEntries() => StreamQueue(_getEntryStream());

  Future<int> getEntriesSize() async {
    await init();
    var metadata = await englishDoc().get();
    return metadata.get(_SIZE);
  }

  Stream<Entry> _getEntryStream() async* {
    await init();
    for (var entry in _queryToEntries(await entriesCol().get())) yield entry;
  }
  
  List<Entry> _queryToEntries(QuerySnapshot query) {
    return query.docs.map(_docToEntry).toList();
  }

  Entry _docToEntry(QueryDocumentSnapshot doc) {
    Map<String, dynamic> ret = doc.data();
    ret["id"] = int.parse(doc.id);
    return Entry.fromJson(ret);
  }
}