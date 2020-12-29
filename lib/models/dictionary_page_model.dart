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

TranslationMode oppositeTranslationMode(TranslationMode translationMode) =>
    translationMode == TranslationMode.English
        ? TranslationMode.Spanish
        : TranslationMode.English;

const DEFAULT_TRANSLATION_MODE = TranslationMode.English;

class DictionaryPageModel {
  static const String route = 'dictionary';
  static const String SELECTED_ENTRY_QUERY_PARAM = 'entry';
  static const String SEARCH_STRING_QUERY_PARAM = 'search';
  static const String SORT_BY_QUERY_PARAM = 'sortBy';

  static DictionaryPageModel _lastEnglishPageModel =
      DictionaryPageModel.empty(translationMode: TranslationMode.English);
  static DictionaryPageModel _lastSpanishModel =
      DictionaryPageModel.empty(translationMode: TranslationMode.Spanish);

  // Translation mode state.
  final TranslationMode translationMode;

  // Selected entry state.
  final Future<Entry> selectedEntry;
  final String selectedEntryHeadword;

  // Entry search state
  final EntrySearchModel entrySearchModel;
  bool searchBarHasFocus;
  bool expandSearchOptions;

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
        translationMode: translationMode,
        selectedEntry: null,
        selectedEntryHeadword: '',
        entrySearchModel: EntrySearchModel.empty(),
        searchBarHasFocus: false,
        expandSearchOptions: false,
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
        newEncodedHeadword: newEntry.urlEncodedHeadword);
  }

  DictionaryPageModel _copyWithEncodedHeadword(String newEncodedHeadword) {
    return _copyWith(
        newSelectedEntry: MyApp.db.getEntry(newEncodedHeadword),
        newEncodedHeadword: newEncodedHeadword);
  }

  DictionaryPageModel _copyWith(
      {DictionaryPageModel newOppositeModeModel,
      FutureOr<Entry> newSelectedEntry,
      String newEncodedHeadword}) {
    assert((newSelectedEntry != null && newEncodedHeadword != null) ||
        (newSelectedEntry == null && newEncodedHeadword == null));
    assert(newOppositeModeModel == null ||
        newOppositeModeModel.translationMode != translationMode);
    return DictionaryPageModel._(
      translationMode: translationMode,
      selectedEntry: newSelectedEntry ?? selectedEntry,
      selectedEntryHeadword: newEncodedHeadword ?? selectedEntryHeadword,
      entrySearchModel: entrySearchModel.copy(),
      searchBarHasFocus: false,
      expandSearchOptions: expandSearchOptions,
    );
  }

  DictionaryPageModel._({
    @required this.translationMode,
    @required this.selectedEntry,
    @required this.selectedEntryHeadword,
    @required this.entrySearchModel,
    @required this.searchBarHasFocus,
    @required this.expandSearchOptions,
  });

  static void onTranslationModeChanged(
      BuildContext context, TranslationMode newTranslationMode) {
    var oldModel = DictionaryPageModel.of(context);
    if (newTranslationMode == oldModel.translationMode) return;
    if (oldModel.isEnglish) {
      _lastEnglishPageModel = oldModel;
      return _lastSpanishModel._copyWith()._pushPage(context);
    }
    _lastSpanishModel = oldModel;
    return _lastEnglishPageModel._copyWith()._pushPage(context);
  }

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
