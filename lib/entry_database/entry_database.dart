import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rogers_dictionary/main.dart';

import 'database_constants.dart';
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

  FirestoreDatabase _fs;

  Future<void> init() async {
    if (_fs != null) return Completer().complete(null);
    await MyApp.isInitialized;
    print('Firestore initialized!');
  }

  DocumentReference englishDoc() {
    return FirebaseFirestore.instance.collection(ENTRIES_DB).doc(ENGLISH);
  }

  CollectionReference entriesCol() {
    return englishDoc().collection(ENTRIES);
  }

  Stream<Entry> getEntries({String searchString = ''}) {
    return _getEntryStream(searchString);
  }

  Stream<Entry> _getEntryStream(String searchString) async* {
    await init();
    dynamic start = -1;
    while (true) {
      var snapshot = await entriesCol()
          .orderBy('entry_id')
          .startAfter([start])
          .where('keyword_list', arrayContains: searchString)
          .limit(10)
          .get();
      if (snapshot.docs.isEmpty) return;
      for (var entry in _queryToEntries(snapshot)) {
        print(entry.entryId);
        yield entry;
      }
      start = snapshot.docs.last.get('entry_id');
    }
  }
  
  List<Entry> _queryToEntries(QuerySnapshot query) {
    return query.docs.map(_docToEntry).toList();
  }

  Entry _docToEntry(QueryDocumentSnapshot doc) {
    return Entry.fromJson(doc.data());
  }
}