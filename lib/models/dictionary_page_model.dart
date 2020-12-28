import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:rogers_dictionary/models/entry_search_model.dart';
import 'package:rogers_dictionary/models/search_options.dart';
import 'package:universal_html/html.dart' as html;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';
import 'package:rogers_dictionary/main.dart';

class DictionaryPageModel {
  static const String route = 'dictionary';
  static const String SELECTED_ENTRY_QUERY_PARAM = 'entry';
  static const String SEARCH_STRING_QUERY_PARAM = 'search';
  static const String SORT_BY_QUERY_PARAM = 'sortBy';

  // Selected entry state.
  Future<Entry> selectedEntry;
  String selectedEntryHeadword;

  // Entry search state
  final EntrySearchModel entrySearchModel;
  bool searchBarHasFocus;
  bool expandSearchOptions;

  bool get hasSelection => selectedEntryHeadword.isNotEmpty;

  String get searchString => entrySearchModel.searchString;

  bool get hasSearchString => entrySearchModel.searchString.isNotEmpty;

  SearchOptions get searchOptions => entrySearchModel.searchOptions;

  get uri {
    var params = <String, String>{};
    if (selectedEntryHeadword != '')
      params[SELECTED_ENTRY_QUERY_PARAM] = selectedEntryHeadword;
    if (selectedEntryHeadword != '')
      params[SEARCH_STRING_QUERY_PARAM] = searchString;
    return Uri(path: route, queryParameters: params);
  }

  static DictionaryPageModel of(BuildContext context) =>
      ModalRoute.of(context).settings.arguments;

  factory DictionaryPageModel.empty() => DictionaryPageModel._(
        selectedEntry: null,
        selectedEntryHeadword: '',
        entrySearchModel: EntrySearchModel.empty(),
        searchBarHasFocus: false,
        expandSearchOptions: false,
      );

  factory DictionaryPageModel.fromQueryParams(Map<String, String> queryParams) {
    var encodedHeadword = queryParams[SELECTED_ENTRY_QUERY_PARAM];
    var searchString = queryParams[SEARCH_STRING_QUERY_PARAM];
    return DictionaryPageModel._(
      selectedEntry:
          encodedHeadword != null ? MyApp.db.getEntry(encodedHeadword) : null,
      selectedEntryHeadword: encodedHeadword ?? '',
      entrySearchModel:
          EntrySearchModel(searchString ?? '', SearchOptions.empty()),
      searchBarHasFocus: false,
      expandSearchOptions: false,
    );
  }

  DictionaryPageModel _copyWithEntry(Entry newEntry) {
    return _copyWith(Future.value(newEntry), newEntry.urlEncodedHeadword);
  }

  DictionaryPageModel _copyWithEncodedHeadword(String newEncodedHeadword) {
    return _copyWith(MyApp.db.getEntry(newEncodedHeadword), newEncodedHeadword);
  }

  DictionaryPageModel _copyWith(
      FutureOr<Entry> newEntry, String newEncodedHeadword) {
    return DictionaryPageModel._(
      selectedEntry: newEntry,
      selectedEntryHeadword: newEncodedHeadword,
      entrySearchModel: entrySearchModel.copy(),
      searchBarHasFocus: false,
      expandSearchOptions: expandSearchOptions,
    );
  }

  DictionaryPageModel._({
    @required this.selectedEntry,
    @required this.selectedEntryHeadword,
    @required this.entrySearchModel,
    @required this.searchBarHasFocus,
    @required this.expandSearchOptions,
  });

  static void onSearchChanged(BuildContext context, String newSearchString,
      SearchOptions newSearchOptions) {
    var dictionaryPageModel = DictionaryPageModel.of(context);
    dictionaryPageModel.entrySearchModel
        .onSearchStringChanged(newSearchString, newSearchOptions);
    if (kIsWeb) dictionaryPageModel._pushQueryParams(context);
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
    if (newUrlEncodedHeadword == oldModel.selectedEntryHeadword) return;
    oldModel._copyWithEncodedHeadword(newUrlEncodedHeadword)._pushPage(context);
  }

  void _pushQueryParams(BuildContext context) {
    html.window.history.replaceState(null, '', uri.toString());
  }

  void _pushPage(BuildContext context) {
    Navigator.of(context).pushNamed(
      uri.toString(),
      arguments: this,
    );
  }
}
