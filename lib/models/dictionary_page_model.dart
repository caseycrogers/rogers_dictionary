import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';
import 'package:rogers_dictionary/main.dart';

class DictionaryPageModel {
  static const String route = '/dictionary';
  static const String selectedEntryQueryParameter = 'entry';
  static const String searchStringQueryParameter = 'search';

  // Selected entry state.
  Future<Entry> selectedEntry;
  String selectedEntryHeadword;

  get hasSelection => selectedEntryHeadword.isNotEmpty;

  get uri => Uri(
      path: route,
      queryParameters: {
        selectedEntryQueryParameter: selectedEntryHeadword,
        searchStringQueryParameter: searchString
      }..removeWhere((key, value) => value == ''));

  final bool animateTransition;

  // Search bar state.
  final String searchString;
  bool searchBarHasFocus;

  // EntryList state.
  final Stream<Entry> entryStream;
  List<Entry> entries;
  final String startAfter;
  final ScrollController scrollController;

  static DictionaryPageModel of(BuildContext context) =>
      ModalRoute.of(context).settings.arguments;

  factory DictionaryPageModel.empty() => DictionaryPageModel._(
      selectedEntry: null,
      selectedEntryHeadword: '',
      searchString: '',
      searchBarHasFocus: false,
      entries: [],
      entryStream: Stream.empty(),
      startAfter: '',
      scrollController: ScrollController(),
      animateTransition: true);

  factory DictionaryPageModel.fromQueryParams(Map<String, String> queryParams) {
    var encodedHeadword = queryParams[selectedEntryQueryParameter];
    var searchString = queryParams[searchStringQueryParameter];
    return DictionaryPageModel._(
        selectedEntry:
            encodedHeadword != null ? MyApp.db.getEntry(encodedHeadword) : null,
        selectedEntryHeadword: encodedHeadword ?? '',
        searchString: searchString ?? '',
        searchBarHasFocus: false,
        entryStream: MyApp.db.getEntries(searchString: searchString),
        entries: [],
        // Truncate the last letter because we want to include urlEncodedHeadword
        startAfter: '',
        scrollController: ScrollController(),
        animateTransition: false);
  }

  DictionaryPageModel _copyWithEntry(Entry newEntry) {
    return _copyWith(
        Future.value(newEntry), newEntry.urlEncodedHeadword, searchString,
        maintainFocus: false);
  }

  DictionaryPageModel _copyWithEncodedHeadword(String newEncodedHeadword) {
    return _copyWith(
        MyApp.db.getEntry(newEncodedHeadword), newEncodedHeadword, searchString,
        maintainFocus: false);
  }

  DictionaryPageModel _copyWithSearchString(String newSearchString) {
    if (newSearchString == '') return DictionaryPageModel.empty();
    return _copyWith(selectedEntry, selectedEntryHeadword, newSearchString,
        resetEntries: true, animateTransition: false);
  }

  DictionaryPageModel _copyWith(FutureOr<Entry> newEntry,
      String newEncodedHeadword, String newSearchString,
      {bool resetEntries: false,
      bool animateTransition: true,
      bool maintainFocus: true}) {
    var newStartAfter =
        (entries.isEmpty || resetEntries) ? '' : entries.last.orderByField;
    return DictionaryPageModel._(
        selectedEntry: newEntry,
        selectedEntryHeadword: newEncodedHeadword,
        searchString: newSearchString,
        searchBarHasFocus: maintainFocus && searchBarHasFocus,
        entryStream: MyApp.db.getEntries(
            searchString: newSearchString, startAfter: newStartAfter),
        entries: resetEntries ? [] : List.from(entries),
        startAfter: newStartAfter,
        scrollController: (scrollController.hasClients && !resetEntries)
            ? ScrollController(initialScrollOffset: scrollController.offset)
            : scrollController,
        animateTransition: animateTransition);
  }

  DictionaryPageModel._(
      {@required this.selectedEntry,
      @required this.selectedEntryHeadword,
      @required this.searchString,
      @required this.searchBarHasFocus,
      @required this.entryStream,
      @required this.entries,
      @required this.startAfter,
      @required this.scrollController,
      @required this.animateTransition});

  static void onSearchStringChanged(
      BuildContext context, String newSearchString) {
    var oldModel = DictionaryPageModel.of(context);
    // Only update if the value has actually changed
    if (newSearchString == oldModel.searchString) return;
    oldModel
        ._copyWithSearchString(newSearchString)
        ._pushReplacementPage(context);
  }

  static void onEntrySelected(BuildContext context, Entry newEntry) {
    var oldModel = DictionaryPageModel.of(context);
    // Only update if the value has actually changed
    if (newEntry.urlEncodedHeadword == oldModel.selectedEntryHeadword) return;
    oldModel._copyWithEntry(newEntry)._pushPage(context);
  }

  static void onHeadwordSelected(
      BuildContext context, String newUrlEncodedHeadword) {
    var oldModel = DictionaryPageModel.of(context);
    // Only update if the value has actually changed
    print(newUrlEncodedHeadword);
    if (newUrlEncodedHeadword == oldModel.selectedEntryHeadword) return;
    oldModel._copyWithEncodedHeadword(newUrlEncodedHeadword)._pushPage(context);
  }

  void _pushReplacementPage(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(
      uri.toString(),
      arguments: this,
    );
  }

  void _pushPage(BuildContext context) {
    Navigator.of(context).pushNamed(
      uri.toString(),
      arguments: this,
    );
  }
}
