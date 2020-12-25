import 'dart:async';

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
