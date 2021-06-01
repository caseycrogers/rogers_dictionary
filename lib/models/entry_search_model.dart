import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:rogers_dictionary/entry_database/entry_builders.dart';
import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/models/search_settings_model.dart';
import 'package:rogers_dictionary/models/translation_page_model.dart';
import 'package:rogers_dictionary/protobufs/entry.pb.dart';

class EntrySearchModel with ChangeNotifier {
  EntrySearchModel._(this._translationMode, this._searchString,
      this._searchSettingsModel, this._favoritesOnly) {
    _initializeStream();
  }

  EntrySearchModel.empty(TranslationMode translationMode, bool favoritesOnly)
      : this._(translationMode, '', SearchSettingsModel.empty(), favoritesOnly);

  final TranslationMode _translationMode;
  String _searchString;
  SearchSettingsModel _searchSettingsModel;
  late Stream<Entry> _entryStream;
  LinkedHashSet<Entry> _entries = LinkedHashSet();
  final bool _favoritesOnly;

  String get searchString => _searchString;

  SearchSettingsModel get searchSettingsModel => _searchSettingsModel;

  Stream<Entry> get entryStream => _entryStream;

  List<Entry> get entries => _entries.toList();

  bool get isEmpty => _searchString.isEmpty;

  bool get favoritesOnly => _favoritesOnly;

  void resetStream() => _initializeStream();

  void _initializeStream() {
    Stream<Entry> stream;
    // Use a new hashSet to avoid any potential race conditions.
    final LinkedHashSet<Entry> hashSet = LinkedHashSet();
    if (_favoritesOnly) {
      stream = MyApp.db.getFavorites(_translationMode, startAfter: 0);
    } else {
      if (searchString.isEmpty) {
        stream = const Stream<Entry>.empty();
      }
      stream = MyApp.db.getEntries(
        _translationMode,
        searchString: searchString,
        startAfter: 0,
        searchOptions: searchSettingsModel,
      );
    }
    _entryStream = stream
        .handleError((Object error, StackTrace stackTrace) =>
            print('ERROR (entry stream): :$error\n$stackTrace'))
        .map(
      (Entry entry) {
        if (!hashSet.add(entry))
          print('WARNING: added duplicate entry '
              '${entry.headword.urlEncodedHeadword}. '
              'Set:\n${hashSet.toList()}');
        return entry;
      },
    ).asBroadcastStream();
    _entries = hashSet;
  }

  void onSearchStringChanged({
    String? newSearchString,
    SearchSettingsModel? newSearchSettings,
  }) {
    // Do nothing if nothing has changed
    if ((newSearchString ?? _searchString) == _searchString &&
        (newSearchSettings ?? _searchSettingsModel) == _searchSettingsModel)
      return;
    _searchString = newSearchString ?? _searchString;
    _searchSettingsModel = newSearchSettings ?? _searchSettingsModel;
    _initializeStream();
    notifyListeners();
  }
}
