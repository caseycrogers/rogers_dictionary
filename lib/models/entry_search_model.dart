import 'package:flutter/cupertino.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';
import 'package:rogers_dictionary/main.dart';

class EntrySearchModel with ChangeNotifier {
  String _searchString;
  String _startAfter;
  Stream<Entry> _entryStream;
  List<Entry> _entries;
  ScrollController _scrollController;

  get searchString => _searchString;

  get startAfter => _startAfter;

  get entryStream => _entryStream;

  get entries => _entries;

  get scrollController => _scrollController;

  get isEmpty => _searchString.isEmpty;

  EntrySearchModel._(this._searchString, this._startAfter, this._entries,
      this._scrollController) {
    _entryStream =
        MyApp.db.getEntries(searchString: searchString, startAfter: startAfter);
  }

  EntrySearchModel(String searchString)
      : this._(searchString, '', [], ScrollController());

  EntrySearchModel.empty() : this._('', '', [], ScrollController());

  EntrySearchModel copy() => EntrySearchModel._(
      _searchString,
      _startAfter,
      _entries,
      ScrollController(
          initialScrollOffset:
              _scrollController.hasClients ? _scrollController.offset : 0.0));

  void onSearchStringChanged(String newSearchString) {
    // Do nothing if the string hasn't changed
    if (_searchString == newSearchString) return;
    _searchString = newSearchString;
    _startAfter = '';
    _entries = [];
    _entryStream = MyApp.db
        .getEntries(searchString: _searchString, startAfter: _startAfter);
    _scrollController = ScrollController();
    notifyListeners();
  }

  void updateEntries(newEntries) {
    _entries = newEntries;
    _startAfter = _entries.isNotEmpty ? _entries.last.urlEncodedHeadword : '';
  }
}
