import 'package:flutter/cupertino.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';
import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/models/search_options.dart';

import 'dictionary_page_model.dart';

class EntrySearchModel with ChangeNotifier {
  String _searchString;
  SearchOptions _searchOptions;
  String _startAfter;
  Stream<Entry> _entryStream;
  List<Entry> _entries;
  ScrollController _scrollController;

  get searchString => _searchString;

  get searchOptions => _searchOptions;

  get startAfter => _startAfter;

  get entryStream => _entryStream;

  get entries => _entries;

  get scrollController => _scrollController;

  get isEmpty => _searchString.isEmpty;

  EntrySearchModel._(this._searchString, this._searchOptions, this._startAfter,
      this._entries, this._scrollController) {
    _entryStream =
        MyApp.db.getEntries(searchString: searchString, startAfter: startAfter);
  }

  EntrySearchModel(String searchString, SearchOptions searchOptions)
      : this._(searchString, searchOptions, '', [], ScrollController());

  EntrySearchModel.empty()
      : this._('', SearchOptions.empty(), '', [], ScrollController());

  EntrySearchModel copy() => EntrySearchModel._(
      _searchString,
      _searchOptions,
      _startAfter,
      _entries,
      ScrollController(
          initialScrollOffset:
              _scrollController.hasClients ? _scrollController.offset : 0.0));

  void onSearchStringChanged(
      String newSearchString, SearchOptions newSearchOptions) {
    // Do nothing if nothing has changed
    if (_searchString == newSearchString && _searchOptions == newSearchOptions)
      return;
    _searchString = newSearchString;
    _searchOptions = newSearchOptions;
    _startAfter = '';
    _entries = [];
    _entryStream = MyApp.db.getEntries(
        searchString: _searchString,
        startAfter: _startAfter,
        searchOptions: _searchOptions);
    _scrollController = ScrollController();
    notifyListeners();
  }

  void updateEntries(newEntries) {
    _entries = newEntries;
    _startAfter = _entries.isNotEmpty ? _entries.last.urlEncodedHeadword : '';
  }
}
