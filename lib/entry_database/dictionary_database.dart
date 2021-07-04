import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:path/path.dart';

import 'package:rogers_dictionary/entry_database/database_constants.dart';
import 'package:rogers_dictionary/entry_database/entry_builders.dart';
import 'package:rogers_dictionary/models/translation_page_model.dart';
import 'package:rogers_dictionary/protobufs/database_version.pb.dart';
import 'package:rogers_dictionary/protobufs/dialogues.pb.dart';
import 'package:rogers_dictionary/protobufs/entry.pb.dart';
import 'package:rogers_dictionary/util/map_utils.dart';

// A database interface for fetching dictionary entries.
abstract class DictionaryDatabase {
  DictionaryDatabase()
      : _englishFavoritesCache = {},
        _spanishFavoritesCache = {};

  Future<DatabaseVersion> get version => rootBundle
      .loadString(join('assets', '$VERSION_FILE'))
      .then((v) => VersionUtils.fromString(v));

  /// Indicates whether or not the favorites list may have changes since it was
  /// last fetched.
  final ValueNotifier<bool> _englishIsFavoritesDirty = ValueNotifier(true);
  final ValueNotifier<bool> _spanishIsFavoritesDirty = ValueNotifier(true);

  ValueNotifier<bool> isFavoritesDirty(TranslationMode translationMode) {
    if (translationMode == TranslationMode.English) {
      return _englishIsFavoritesDirty;
    }
    return _spanishIsFavoritesDirty;
  }

  void _updateDirtyFavorites(TranslationMode translationMode, bool isDirty) {
    isFavoritesDirty(translationMode).value = isDirty;
  }

  final Map<String, bool> _englishFavoritesCache;
  final Map<String, bool> _spanishFavoritesCache;

  // Fetch entries from the database.
  Stream<Entry> getEntries(
    TranslationMode translationMode, {
    required String searchString,
    required int startAfter,
  });

  // Get the given entry from the database.
  Future<Entry> getEntry(
      TranslationMode translationMode, String urlEncodedHeadword);

  @mustCallSuper
  Future<bool> setFavorite(TranslationMode translationMode,
      String urlEncodedHeadword, bool favorite) {
    final bool? oldValue = _getCache(translationMode)[urlEncodedHeadword];
    if (oldValue != null && oldValue != favorite) {
      // Only dirty the cache if we're actually changing the value.
      _updateDirtyFavorites(translationMode, true);
    }
    return Future<bool>.value(
      _getCache(translationMode)[urlEncodedHeadword] = favorite,
    );
  }

  @mustCallSuper
  Stream<Entry> getFavorites(TranslationMode translationMode,
      {required int startAfter}) {
    _updateDirtyFavorites(translationMode, false);
    return const Stream.empty();
  }

  Future<bool> isFavorite(
      TranslationMode translationMode, String urlEncodedHeadword) async {
    return _getCache(translationMode).getOrElse(
      urlEncodedHeadword,
      await internalIsFavorite(translationMode, urlEncodedHeadword),
    );
  }

  @protected
  Future<bool> internalIsFavorite(
    TranslationMode translationMode,
    String urlEncodedHeadword,
  );

  Stream<DialogueChapter> getDialogues({
    int startAfter,
  });

  Map<String, bool> _getCache(TranslationMode translationMode) =>
      translationMode == TranslationMode.English
          ? _englishFavoritesCache
          : _spanishFavoritesCache;
}
