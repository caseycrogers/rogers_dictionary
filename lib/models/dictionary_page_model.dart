import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';
import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/models/entry_search_model.dart';
import 'package:rogers_dictionary/pages/favorites_page.dart';
import 'package:rogers_dictionary/models/search_settings_model.dart';
import 'package:rogers_dictionary/pages/search_page.dart';
import 'package:rogers_dictionary/util/local_history_value_notifier.dart';

enum TranslationMode {
  English,
  Spanish,
}

const DEFAULT_TRANSLATION_MODE = TranslationMode.English;

TranslationMode indexToTranslationMode(int index) =>
    TranslationMode.values[index];

int translationModeToIndex(TranslationMode translationMode) {
  assert(translationMode != null);
  return TranslationMode.values.indexOf(translationMode);
}

class DictionaryPageModel {
  static const String _SELECTED_ENTRY_QUERY_PARAM = 'entry';
  static const String _SEARCH_STRING_QUERY_PARAM = 'search';
  static const String _SORT_BY_QUERY_PARAM = 'sortBy';

  final SearchPageModel englishPageModel;
  final SearchPageModel spanishPageModel;
  final tabIndex;

  final TranslationMode _initialTranslationMode;
  LocalHistoryValueNotifier<SearchPageModel> _currSearchPageModel;
  LocalHistoryValueNotifier<SearchPageModel> get currSearchPageModel {
    assert(_currSearchPageModel != null,
        'You must initialize the current model first.');
    return _currSearchPageModel;
  }

  void createSearchPageModel(BuildContext context) {
    _currSearchPageModel ??= LocalHistoryValueNotifier(
        context: context,
        initialValue: _initialTranslationMode == TranslationMode.English
            ? englishPageModel
            : spanishPageModel);
  }

  get uri {
    return Uri(pathSegments: [
      (_currSearchPageModel?.value?.translationMode ?? _initialTranslationMode)
          .toString()
          .split('.')
          .last
          .toLowerCase(),
      _tabToRoute[tabIndex],
    ]);
  }

  SearchPageModel get _currModel => currSearchPageModel.value;

  SearchPageModel get _oppModel =>
      _currModel.translationMode == TranslationMode.English
          ? spanishPageModel
          : englishPageModel;

  static DictionaryPageModel of(BuildContext context) =>
      ModalRoute.of(context).settings.arguments;

  DictionaryPageModel._(this.tabIndex, this.englishPageModel,
      this.spanishPageModel, this._initialTranslationMode);

  static DictionaryPageModel empty() => DictionaryPageModel._(
        0,
        SearchPageModel.empty(translationMode: TranslationMode.English),
        SearchPageModel.empty(translationMode: TranslationMode.Spanish),
        DEFAULT_TRANSLATION_MODE,
      );

  DictionaryPageModel _copyWithNewIndex(int newIndex) {
    return DictionaryPageModel._(newIndex, englishPageModel, spanishPageModel,
        _currModel.translationMode);
  }

  DictionaryPageModel copyWithNewModel(SearchPageModel newModel) {
    var newEnglishModel = newModel.isEnglish ? newModel : englishPageModel;
    var newSpanishModel = newModel.isEnglish ? spanishPageModel : newModel;
    return DictionaryPageModel._(
        tabIndex, newEnglishModel, newSpanishModel, newModel.translationMode);
  }

  SearchPageModel pageModel(TranslationMode translationMode) =>
      translationMode == TranslationMode.English
          ? englishPageModel
          : spanishPageModel;

  void onTranslationModeChanged(TranslationMode newTranslationMode) =>
      currSearchPageModel.value = pageModel(newTranslationMode);

  void onEntrySelected(BuildContext context, Entry newEntry) {
    assert(newEntry != null);
    // Only update if the value has actually changed
    if (newEntry.urlEncodedHeadword == _currModel.selectedEntryHeadword) return;
    var newModel = _currModel._copyWithEntry(newEntry);
    _currModel.transitionTo = newModel;
    copyWithNewModel(newModel)._pushPage(context);
  }

  void onHeadwordSelected(BuildContext context, String newUrlEncodedHeadword) {
    // Only update if the value has actually changed
    if (newUrlEncodedHeadword == _currModel.selectedEntryHeadword) return;
    var newModel = _currModel._copyWithEncodedHeadword(newUrlEncodedHeadword);
    _currModel.transitionTo = newModel;
    copyWithNewModel(newModel)._pushPage(context);
  }

  void onSearchChanged(
      {String newSearchString, SearchSettingsModel newSearchSettings}) {
    _currModel.entrySearchModel.onSearchStringChanged(
      newSearchString: newSearchString,
      newSearchSettings: newSearchSettings,
    );
  }

  void onTabChanged(BuildContext context, int index) {
    _copyWithNewIndex(index)._pushPage(context);
  }

  List<String> _tabToRoute = [
    SearchPage.route,
    FavoritesPage.route,
  ];

  void _pushPage(BuildContext context) {
    Navigator.of(context).pushNamed(
      uri.toString(),
      arguments: this,
    );
  }
}

class SearchPageModel {
  // Transition state.
  final SearchPageModel transitionFrom;
  SearchPageModel transitionTo;

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

  static SearchPageModel of(BuildContext context) =>
      context.select<SearchPageModel, SearchPageModel>((mdl) => mdl);

  static SearchPageModel readFrom(BuildContext context) =>
      context.read<SearchPageModel>();

  factory SearchPageModel.empty({@required TranslationMode translationMode}) =>
      SearchPageModel._(
        transitionFrom: null,
        translationMode: translationMode,
        selectedEntry: null,
        selectedEntryHeadword: '',
        entrySearchModel: EntrySearchModel.empty(translationMode),
        searchBarHasFocus: false,
      );

  factory SearchPageModel.fromQueryParams(Map<String, String> queryParams) {
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

  SearchPageModel _copyWithEntry(Entry newEntry) {
    return _copyWith(
        newSelectedEntry: Future.value(newEntry),
        newEncodedHeadword: newEntry?.urlEncodedHeadword);
  }

  SearchPageModel _copyWithEncodedHeadword(String newEncodedHeadword) {
    return _copyWith(
        newSelectedEntry: newEncodedHeadword.isNotEmpty
            ? MyApp.db.getEntry(translationMode, newEncodedHeadword)
            : null,
        newEncodedHeadword: newEncodedHeadword);
  }

  SearchPageModel _copyWith(
      {SearchPageModel overrideTransitionFrom,
      FutureOr<Entry> newSelectedEntry,
      String newEncodedHeadword}) {
    assert((newSelectedEntry != null &&
            newEncodedHeadword != selectedEntryHeadword) ||
        (newSelectedEntry == null && (newEncodedHeadword ?? '') == '') ||
        overrideTransitionFrom != null);
    return SearchPageModel._(
      transitionFrom: overrideTransitionFrom ?? this,
      translationMode: translationMode,
      selectedEntry: newSelectedEntry ?? selectedEntry,
      selectedEntryHeadword: newEncodedHeadword ?? selectedEntryHeadword,
      entrySearchModel: entrySearchModel.copy(),
      searchBarHasFocus: false,
    );
  }

  SearchPageModel._({
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

//void _pushQueryParams(BuildContext context) {
//  html.window.history.replaceState(null, '', uri.toString());
//}
}
