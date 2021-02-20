import 'package:flutter/cupertino.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';
import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/models/search_settings_model.dart';

class EntrySearchModel with ChangeNotifier {
  final TranslationMode _translationMode;
  String _searchString;
  SearchSettingsModel _searchSettingsModel;
  int _startAfter;
  Stream<Entry> _entryStream;
  List<Entry> _entries;
  ScrollController _scrollController;
  bool _bookmarksOnly;

  String get searchString => _searchString;

  SearchSettingsModel get searchSettingsModel => _searchSettingsModel;

  Stream<Entry> get entryStream => _entryStream;

  List<Entry> get entries => _entries;

  ScrollController get scrollController => _scrollController;

  bool get isEmpty => _searchString.isEmpty;

  bool get bookmarksOnly => _bookmarksOnly;

  set bookmarksOnly(bool value) {
    print('asdf');
    onSearchStringChanged(newBookmarksOnly: value);
  }

  set expandSearchOptions(bool value) {
    if (_bookmarksOnly == value) return;
    _bookmarksOnly = value;
    notifyListeners();
  }

  EntrySearchModel._(
      this._translationMode,
      this._searchString,
      this._searchSettingsModel,
      this._entries,
      this._scrollController,
      this._bookmarksOnly) {
    _entryStream = MyApp.db.getEntries(_translationMode,
        searchString: searchString,
        startAfter: entries.length,
        searchOptions: searchSettingsModel);
  }

  EntrySearchModel(TranslationMode translationMode, String searchString,
      SearchSettingsModel searchOptions)
      : this._(translationMode, searchString, searchOptions, [],
            ScrollController(), false);

  EntrySearchModel.empty(TranslationMode translationMode)
      : this._(translationMode, '', SearchSettingsModel.empty(), [],
            ScrollController(), false);

  EntrySearchModel copy() => EntrySearchModel._(
      _translationMode,
      _searchString,
      _searchSettingsModel,
      _entries,
      ScrollController(
          initialScrollOffset:
              _scrollController.hasClients ? _scrollController.offset : 0.0),
      _bookmarksOnly);

  void onSearchStringChanged({
    String newSearchString,
    SearchSettingsModel newSearchSettings,
    bool newBookmarksOnly,
  }) {
    // Do nothing if nothing has changed
    if ((newSearchString ?? _searchString) == _searchString &&
        (newSearchSettings ?? _searchSettingsModel) == _searchSettingsModel &&
        (newBookmarksOnly ?? _bookmarksOnly) == _bookmarksOnly) return;
    _searchString = newSearchString ?? _searchString;
    _searchSettingsModel = newSearchSettings ?? _searchSettingsModel;
    _bookmarksOnly = newBookmarksOnly ?? _bookmarksOnly;
    _startAfter = 0;
    _entries = [];
    _entryStream = MyApp.db.getEntries(_translationMode,
        searchString: _searchString,
        startAfter: _startAfter,
        searchOptions: _searchSettingsModel);
    _scrollController = ScrollController();
    print('notifying listeners');
    notifyListeners();
  }
}
