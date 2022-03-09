import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:path/path.dart';

import 'package:rogers_dictionary/clients/database_constants.dart';
import 'package:rogers_dictionary/models/translation_mode.dart';
import 'package:rogers_dictionary/models/translation_model.dart';
import 'package:rogers_dictionary/protobufs/database_version.pb.dart';
import 'package:rogers_dictionary/protobufs/dialogues.pb.dart';
import 'package:rogers_dictionary/protobufs/entry.pb.dart';
import 'package:rogers_dictionary/util/entry_utils.dart';

// A database interface for fetching dictionary entries.
abstract class DictionaryDatabase {
  Future<DatabaseVersion> get version => rootBundle
      .loadString(join('assets', '$VERSION_FILE'))
      .then((v) => VersionUtils.fromString(v));

  final _BookmarksCache _englishBookmarksCache = _BookmarksCache();
  final _BookmarksCache _spanishBookmarksCache = _BookmarksCache();

  int pseudoHash(TranslationMode translationMode) {
    return _getCache(translationMode)._pseudoHash;
  }

  // Fetch entries from the database.
  Stream<Entry> getEntries(
    TranslationMode translationMode, {
    required String searchString,
    required int startAt,
  });

  // Get the given entry from the database.
  Future<Entry> getEntry(
    TranslationMode translationMode,
    String headword,
  );

  bool isBookmarked(TranslationMode translationMode, Entry entry) =>
      _getCache(translationMode).isBookmarked(entry);

  @mustCallSuper
  Future<void> setBookmark(
    TranslationMode translationMode,
    Entry entry,
    bool newValue,
  ) async {
    return _getCache(translationMode).setBookmark(entry, newValue);
  }

  Stream<Entry> getBookmarked(TranslationMode translationMode,
      {required int startAt});

  Stream<DialogueChapter> getDialogues({
    required int startAt,
  });

  _BookmarksCache _getCache(TranslationMode translationMode) =>
      isEnglish(translationMode)
          ? _englishBookmarksCache
          : _spanishBookmarksCache;

  Future<void> dispose();
}

class _BookmarksCache {
  final Map<String, bool> _cache = {};

  // Changes every time a bookmark is changed.
  int _pseudoHash = 0;

  bool isBookmarked(Entry entry) {
    assert(
      _cache.containsKey(entry.uid),
      'Could not find \'${entry.headword}\' with uid \'${entry.uid}\' in the '
      'bookmarks cache.',
    );
    return _cache[entry.uid]!;
  }

  void setBookmark(Entry entry, bool newValue) {
    final bool? oldValue = _cache[entry.uid];
    _cache[entry.uid] = newValue;
    if (oldValue != null && newValue != oldValue) {
      // Only update if a change has actually been made.
      _pseudoHash += 1;
    }
  }
}
