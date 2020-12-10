import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rogers_dictionary/main.dart';

import 'database_constants.dart';
import 'entry.dart';

// A database interface for fetching dictionary entries.
abstract class EntryDatabase {
  // Whether or not the dictionary is in english mode or spanish mode.
  bool _english = true;

  void setEnglish() => _english = true;

  void setSpanish() => _english = false;

  bool isEnglish() => _english;

  // Fetch entries from the database.
  Stream<Entry> getEntries({String searchString, String startAfter});

  // Get the given entry from the database.
  Future<Entry> getEntry(String urlEncodedHeadword);
}

class FirestoreDatabase extends EntryDatabase {
  FirestoreDatabase _fs;

  Future<void> init() async {
    if (_fs != null) return Completer().complete(null);
    await MyApp.isInitialized;
  }

  DocumentReference englishDoc() {
    return FirebaseFirestore.instance.collection(ENTRIES_DB).doc(ENGLISH);
  }

  CollectionReference entriesCol() {
    return englishDoc().collection(ENTRIES);
  }

  @override
  Future<Entry> getEntry(String urlEncodedHeadword) async {
    await init();
    return _docToEntry(await entriesCol().doc(urlEncodedHeadword).get());
  }

  @override
  Stream<Entry> getEntries({String searchString: '', String startAfter: ''}) {
    return _getEntryStream(searchString, startAfter).asBroadcastStream();
  }

  Stream<Entry> _getEntryStream(String searchString, String startAfter) async* {
    await init();
    dynamic lastSeen = startAfter;
    while (true) {
      var snapshot = await entriesCol()
          .orderBy('order_by_field')
          .startAfter([lastSeen])
          .where('keyword_list', arrayContains: searchString)
          .limit(10)
          .get();
      if (snapshot.docs.isEmpty) {
        return;
      }
      for (var entry in _queryToEntries(snapshot)) {
        yield entry;
      }
      lastSeen = snapshot.docs.last.get('order_by_field');
    }
  }

  List<Entry> _queryToEntries(QuerySnapshot query) {
    return query.docs.map(_queryDocToEntry).toList();
  }

  Entry _queryDocToEntry(QueryDocumentSnapshot doc) {
    return Entry.fromJson(doc.data());
  }

  Entry _docToEntry(DocumentSnapshot doc) {
    return Entry.fromJson(doc.data());
  }
}
