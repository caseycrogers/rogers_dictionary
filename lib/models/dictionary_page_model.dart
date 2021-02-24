import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';
import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/models/entry_search_model.dart';
import 'package:rogers_dictionary/models/search_settings_model.dart';
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
  final SearchPageModel englishPageModel;
  final SearchPageModel spanishPageModel;

  final LocalHistoryValueNotifier<SearchPageModel> currSearchPageModel;

  final LocalHistoryValueNotifier<int> currentIndex;

  get uri {
    return Uri(pathSegments: [
      (currSearchPageModel.value.translationMode)
          .toString()
          .split('.')
          .last
          .toLowerCase(),
    ]);
  }

  SearchPageModel get _currModel => currSearchPageModel.value;

  SearchPageModel get _oppModel =>
      currSearchPageModel.value.translationMode == TranslationMode.English
          ? spanishPageModel
          : englishPageModel;

  static DictionaryPageModel of(BuildContext context) =>
      context.select<DictionaryPageModel, DictionaryPageModel>((mdl) => mdl);

  static DictionaryPageModel readFrom(BuildContext context) =>
      context.read<DictionaryPageModel>();

  DictionaryPageModel._(this.currentIndex, this.currSearchPageModel,
      this.englishPageModel, this.spanishPageModel);

  static DictionaryPageModel empty(BuildContext context) {
    var initialPage = SearchPageModel.empty(
        context: context, translationMode: DEFAULT_TRANSLATION_MODE);
    return DictionaryPageModel._(
      LocalHistoryValueNotifier(
          modalRoute: ModalRoute.of(context), initialValue: 0),
      LocalHistoryValueNotifier(
          modalRoute: ModalRoute.of(context), initialValue: initialPage),
      initialPage,
      SearchPageModel.empty(
          context: context, translationMode: TranslationMode.Spanish),
    );
  }

  DictionaryPageModel copyWithNewModel(SearchPageModel newModel) {
    var newEnglishModel = newModel.isEnglish ? newModel : englishPageModel;
    var newSpanishModel = newModel.isEnglish ? spanishPageModel : newModel;
    return DictionaryPageModel._(
      currentIndex.copy(),
      currSearchPageModel.copy(),
      newEnglishModel,
      newSpanishModel,
    );
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
    if (newEntry.urlEncodedHeadword == _currModel.selectedEntryHeadword.value)
      return;
    _currModel.selectedEntryHeadword.value = newEntry.urlEncodedHeadword;
    _currModel.selectedEntry = Future.value(newEntry);
    _currModel.entrySearchModel.resetStream();
    _oppModel.entrySearchModel.resetStream();
  }

  void onHeadwordSelected(BuildContext context, String newUrlEncodedHeadword) {
    // Only update if the value has actually changed
    if (newUrlEncodedHeadword == _currModel.selectedEntryHeadword.value) return;
    _currModel.selectedEntryHeadword.value = newUrlEncodedHeadword;
    _currModel.selectedEntry = newUrlEncodedHeadword.isNotEmpty
        ? MyApp.db.getEntry(_currModel.translationMode, newUrlEncodedHeadword)
        : null;
    _currModel.entrySearchModel.resetStream();
    _oppModel.entrySearchModel.resetStream();
  }

  void onSearchChanged(
      {String newSearchString, SearchSettingsModel newSearchSettings}) {
    _currModel.entrySearchModel.onSearchStringChanged(
      newSearchString: newSearchString,
      newSearchSettings: newSearchSettings,
    );
  }

  void onTabChanged() {
    if (currentIndex.value == 0) {
      _currModel.entrySearchModel.resetStream();
      _oppModel.entrySearchModel.resetStream();
    }
  }
}

class SearchPageModel {
  // Translation mode state.
  final TranslationMode translationMode;

  // Selected entry state.
  Future<Entry> selectedEntry;
  final LocalHistoryValueNotifier<String> selectedEntryHeadword;

  // Entry search state
  final EntrySearchModel entrySearchModel;

  bool get isEnglish => translationMode == TranslationMode.English;

  bool get hasSelection => selectedEntryHeadword.value.isNotEmpty;

  String get searchString => entrySearchModel.searchString;

  bool get hasSearchString => entrySearchModel.searchString.isNotEmpty;

  static SearchPageModel of(BuildContext context) =>
      context.select<SearchPageModel, SearchPageModel>((mdl) => mdl);

  static SearchPageModel readFrom(BuildContext context) =>
      context.read<SearchPageModel>();

  factory SearchPageModel.empty(
          {@required BuildContext context,
          @required TranslationMode translationMode}) =>
      SearchPageModel._(
        translationMode: translationMode,
        selectedEntry: null,
        selectedEntryHeadword: LocalHistoryValueNotifier(
            modalRoute: ModalRoute.of(context), initialValue: ''),
        entrySearchModel: EntrySearchModel.empty(translationMode),
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

  SearchPageModel._({
    @required this.translationMode,
    @required this.selectedEntry,
    @required this.selectedEntryHeadword,
    @required this.entrySearchModel,
  });
}
