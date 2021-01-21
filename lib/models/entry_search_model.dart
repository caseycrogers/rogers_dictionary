import 'package:flutter/cupertino.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';
import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/models/search_page_model.dart';
import 'package:rogers_dictionary/models/search_options.dart';

class EntrySearchModel with ChangeNotifier {
  // Duplicated here because we need it to construct the entry stream.
  final TranslationMode _translationMode;
  String _searchString;
  SearchOptions _searchOptions;
  int _startAfter;
  Stream<Entry> _entryStream;
  List<Entry> _entries;
  ScrollController _scrollController;
  bool _expandSearchOptions;

  String get searchString => _searchString;

  SearchOptions get searchOptions => _searchOptions;

  Stream<Entry> get entryStream => _entryStream;

  List<Entry> get entries => _entries;

  ScrollController get scrollController => _scrollController;

  bool get isEmpty => _searchString.isEmpty;

  bool get expandSearchOptions => _expandSearchOptions;

  set expandSearchOptions(bool value) {
    if (value == _expandSearchOptions) return;
    _expandSearchOptions = value;
    notifyListeners();
  }

  EntrySearchModel._(
      this._translationMode,
      this._searchString,
      this._searchOptions,
      this._entries,
      this._scrollController,
      this._expandSearchOptions) {
    _entryStream = MyApp.db.getEntries(_translationMode,
        searchString: searchString,
        startAfter: entries.length,
        searchOptions: searchOptions);
  }

  EntrySearchModel(TranslationMode translationMode, String searchString,
      SearchOptions searchOptions)
      : this._(translationMode, searchString, searchOptions, [],
            ScrollController(), false);

  EntrySearchModel.empty(TranslationMode translationMode)
      : this._(translationMode, '', SearchOptions.empty(), [],
            ScrollController(), false);

  EntrySearchModel copy() => EntrySearchModel._(
      _translationMode,
      _searchString,
      _searchOptions,
      _entries,
      ScrollController(
          initialScrollOffset:
              _scrollController.hasClients ? _scrollController.offset : 0.0),
      expandSearchOptions);

  void onSearchStringChanged(
      String newSearchString, SearchOptions newSearchOptions) {
    // Do nothing if nothing has changed
    if (_searchString == newSearchString && _searchOptions == newSearchOptions)
      return;
    _searchString = newSearchString;
    _searchOptions = newSearchOptions;
    _startAfter = 0;
    _entries = [];
    _entryStream = MyApp.db.getEntries(_translationMode,
        searchString: _searchString,
        startAfter: _startAfter,
        searchOptions: _searchOptions);
    _scrollController = ScrollController();
    notifyListeners();
  }
}
