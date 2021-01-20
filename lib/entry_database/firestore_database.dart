import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';
import 'package:rogers_dictionary/entry_database/entry_database.dart';
import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/models/search_options.dart';

import 'database_constants.dart';

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
  Future<Entry> getEntry(
      TranslationMode translationMode, String urlEncodedHeadword) async {
    await init();
    return _docToEntry(await entriesCol().doc(urlEncodedHeadword).get());
  }

  @override
  Stream<Entry> getEntries(TranslationMode translationMode,
      {String searchString: '',
      int startAfter: 0,
      SearchOptions searchOptions}) {
    return _getEntryStream(searchString, startAfter);
  }

  Stream<Entry> _getEntryStream(String searchString, int startAfter) async* {
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
