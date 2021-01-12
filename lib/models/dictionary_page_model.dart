import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:rogers_dictionary/models/entry_search_model.dart';
import 'package:rogers_dictionary/models/search_options.dart';
import 'package:universal_html/html.dart' as html;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';
import 'package:rogers_dictionary/main.dart';

enum TranslationMode {
  English,
  Spanish,
}

const DEFAULT_TRANSLATION_MODE = TranslationMode.English;

class DictionaryPageModel {
  static const String route = 'dictionary';
  static const String SELECTED_ENTRY_QUERY_PARAM = 'entry';
  static const String SEARCH_STRING_QUERY_PARAM = 'search';
  static const String SORT_BY_QUERY_PARAM = 'sortBy';

  static DictionaryPageModel _lastEnglishPageModel =
      DictionaryPageModel.empty(translationMode: TranslationMode.English);
  static DictionaryPageModel _lastSpanishPageModel =
      DictionaryPageModel.empty(translationMode: TranslationMode.Spanish);

  // Transition state.
  final DictionaryPageModel transitionFrom;
  DictionaryPageModel transitionTo;

  // Translation mode state.
  final TranslationMode translationMode;

  // Selected entry state.
  final Future<Entry> selectedEntry;
  final String selectedEntryHeadword;

  // Entry search state
  final EntrySearchModel entrySearchModel;
  bool searchBarHasFocus;

  bool get isEnglish => translationMode == TranslationMode.English;

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

  factory DictionaryPageModel.empty(
          {@required TranslationMode translationMode}) =>
      DictionaryPageModel._(
        transitionFrom: null,
        translationMode: translationMode,
        selectedEntry: null,
        selectedEntryHeadword: '',
        entrySearchModel: EntrySearchModel.empty(translationMode),
        searchBarHasFocus: false,
      );

  factory DictionaryPageModel.fromQueryParams(Map<String, String> queryParams) {
    throw UnimplementedError(
        'Query Params is no longer up to date and should not be used.');
    // var encodedHeadword = queryParams[SELECTED_ENTRY_QUERY_PARAM];
    // var searchString = queryParams[SEARCH_STRING_QUERY_PARAM];
    // return DictionaryPageModel._(
    //   translationMode: DEFAULT_TRANSLATION_MODE,
    //   selectedEntry:
    //       encodedHeadword != null ? MyApp.db.getEntry(encodedHeadword) : null,
    //   selectedEntryHeadword: encodedHeadword ?? '',
    //   entrySearchModel:
    //       EntrySearchModel(searchString ?? '', SearchOptions.empty()),
    //   searchBarHasFocus: false,
    //   expandSearchOptions: false,
    // );
  }

  DictionaryPageModel _copyWithEntry(Entry newEntry) {
    return _copyWith(
        newSelectedEntry: Future.value(newEntry),
        newEncodedHeadword: newEntry?.urlEncodedHeadword);
  }

  DictionaryPageModel _copyWithEncodedHeadword(String newEncodedHeadword) {
    return _copyWith(
        newSelectedEntry: newEncodedHeadword.isNotEmpty
            ? MyApp.db.getEntry(translationMode, newEncodedHeadword)
            : null,
        newEncodedHeadword: newEncodedHeadword);
  }

  DictionaryPageModel _copyWith(
      {DictionaryPageModel overrideTransitionFrom,
      FutureOr<Entry> newSelectedEntry,
      String newEncodedHeadword}) {
    assert((newSelectedEntry != null &&
            newEncodedHeadword != selectedEntryHeadword) ||
        (newSelectedEntry == null && (newEncodedHeadword ?? '') == '') ||
        overrideTransitionFrom != null);
    return DictionaryPageModel._(
      transitionFrom: overrideTransitionFrom ?? this,
      translationMode: translationMode,
      selectedEntry: newSelectedEntry ?? selectedEntry,
      selectedEntryHeadword: newEncodedHeadword ?? selectedEntryHeadword,
      entrySearchModel: entrySearchModel.copy(),
      searchBarHasFocus: false,
    );
  }

  DictionaryPageModel._({
    @required this.transitionFrom,
    @required this.translationMode,
    @required this.selectedEntry,
    @required this.selectedEntryHeadword,
    @required this.entrySearchModel,
    @required this.searchBarHasFocus,
  });

  bool get isTransitionFromTranslationMode =>
      transitionFrom == null ||
      translationMode != transitionFrom.translationMode;

  bool get isTransitionToSelectedHeadword {
    print(transitionTo);
    print(transitionTo != null &&
        transitionTo.translationMode == translationMode &&
        transitionTo.hasSelection &&
        hasSelection);
    print('==============================');
    return transitionTo != null &&
        transitionTo.translationMode == translationMode &&
        transitionTo.hasSelection &&
        hasSelection;
  }

  bool get isTransitionFromSelectedHeadword {
    return transitionFrom != null &&
        transitionFrom.translationMode == translationMode &&
        transitionFrom.hasSelection &&
        hasSelection;
  }

  static void onTranslationModeChanged(
      BuildContext context, TranslationMode newTranslationMode) {
    var currModel = DictionaryPageModel.of(context);
    if (newTranslationMode == currModel.translationMode) return;
    var newModel =
        (currModel.isEnglish ? _lastSpanishPageModel : _lastEnglishPageModel)
            ._copyWith(overrideTransitionFrom: currModel);
    currModel.transitionTo = newModel;
    currModel.isEnglish
        ? _lastEnglishPageModel = currModel
        : _lastSpanishPageModel = currModel;
    newModel._pushPage(context);
  }

  void onSearchChanged(
      {String newSearchString, SearchOptions newSearchOptions}) {
    entrySearchModel.onSearchStringChanged(
        newSearchString ?? searchString, newSearchOptions ?? searchOptions);
  }

  void onEntrySelected(BuildContext context, Entry newEntry) {
    assert(newEntry != null);
    // Only update if the value has actually changed
    if (newEntry.urlEncodedHeadword == selectedEntryHeadword) return;
    var newModel = _copyWithEntry(newEntry);
    transitionTo = newModel;
    newModel._pushPage(context);
  }

  void onHeadwordSelected(BuildContext context, String newUrlEncodedHeadword) {
    // Only update if the value has actually changed
    if (newUrlEncodedHeadword == selectedEntryHeadword) return;
    var newModel = _copyWithEncodedHeadword(newUrlEncodedHeadword);
    transitionTo = newModel;
    newModel._pushPage(context);
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
