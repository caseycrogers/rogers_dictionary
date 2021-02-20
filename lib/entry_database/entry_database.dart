import 'dart:async';

import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/models/search_settings_model.dart';

import 'entry.dart';

// A database interface for fetching dictionary entries.
abstract class EntryDatabase {
  // Fetch entries from the database.
  Stream<Entry> getEntries(TranslationMode translationMode,
      {String searchString,
      int startAfter,
      SearchSettingsModel searchOptions,
      bool bookmarksOnly});

  // Get the given entry from the database.
  Future<Entry> getEntry(
      TranslationMode translationMode, String urlEncodedHeadword);

  Future<void> setFavorite(TranslationMode translationMode,
      String urlEncodedHeadword, bool favorite);
}
