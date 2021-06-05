import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:rogers_dictionary/entry_database/database_constants.dart';
import 'package:rogers_dictionary/entry_database/entry_builders.dart';
import 'package:rogers_dictionary/models/search_settings_model.dart';
import 'package:rogers_dictionary/models/translation_page_model.dart';
import 'package:rogers_dictionary/protobufs/database_version.pb.dart';
import 'package:rogers_dictionary/protobufs/dialogues.pb.dart';
import 'package:rogers_dictionary/protobufs/entry.pb.dart';

// A database interface for fetching dictionary entries.
abstract class DictionaryDatabase {
  Future<DatabaseVersion> get version => rootBundle
      .loadString(join('assets', '$VERSION_FILE'))
      .then((v) => VersionUtils.fromString(v));

  DictionaryDatabase()
      : _englishFavoritesCache = {},
        _spanishFavoritesCache = {};

  final Map<String, bool> _englishFavoritesCache;
  final Map<String, bool> _spanishFavoritesCache;

  // Fetch entries from the database.
  Stream<Entry> getEntries(
    TranslationMode translationMode, {
    required String searchString,
    required int startAfter,
    required SearchSettingsModel searchOptions,
  });

  // Get the given entry from the database.
  Future<Entry> getEntry(
      TranslationMode translationMode, String urlEncodedHeadword);

  @mustCallSuper
  Future<bool> setFavorite(TranslationMode translationMode,
          String urlEncodedHeadword, bool favorite) =>
      Future<bool>.value(
        _getCache(translationMode)[urlEncodedHeadword] = favorite,
      );

  Stream<Entry> getFavorites(TranslationMode translationMode,
      {required int startAfter});

  bool isFavorite(TranslationMode translationMode, String urlEncodedHeadword) {
    return _getCache(translationMode)[urlEncodedHeadword]!;
  }

  Stream<DialogueChapter> getDialogues({
    int startAfter,
  });

  Map<String, bool> _getCache(TranslationMode translationMode) =>
      translationMode == TranslationMode.English
          ? _englishFavoritesCache
          : _spanishFavoritesCache;
}
