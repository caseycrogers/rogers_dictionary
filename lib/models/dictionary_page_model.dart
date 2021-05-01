import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';
import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/models/dialogues_page_model.dart';
import 'package:rogers_dictionary/models/entry_search_model.dart';
import 'package:rogers_dictionary/models/search_settings_model.dart';
import 'package:rogers_dictionary/dictionary_navigator/local_history_value_notifier.dart';
import 'package:rogers_dictionary/pages/dictionary_page.dart';

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
  final TranslationPageModel englishPageModel;
  final TranslationPageModel spanishPageModel;

  final LocalHistoryValueNotifier<TranslationPageModel>
      currTranslationPageModel;

  final LocalHistoryValueNotifier<DictionaryTab> currentTab;

  get uri {
    return Uri(pathSegments: [
      (currTranslationPageModel.value.translationMode)
          .toString()
          .split('.')
          .last
          .toLowerCase(),
    ]);
  }

  TranslationPageModel get _currModel => currTranslationPageModel.value;

  TranslationPageModel get _oppModel =>
      currTranslationPageModel.value.translationMode == TranslationMode.English
          ? spanishPageModel
          : englishPageModel;

  bool get isEnglish => currTranslationPageModel.value.isEnglish;

  static DictionaryPageModel of(BuildContext context) =>
      context.select<DictionaryPageModel, DictionaryPageModel>((mdl) => mdl);

  static DictionaryPageModel readFrom(BuildContext context) =>
      context.read<DictionaryPageModel>();

  DictionaryPageModel._(this.currentTab, this.currTranslationPageModel,
      this.englishPageModel, this.spanishPageModel);

  static DictionaryPageModel empty(BuildContext context) {
    var englishPage = TranslationPageModel.empty(
        context: context, translationMode: DEFAULT_TRANSLATION_MODE);
    var spanishPage = TranslationPageModel.empty(
        context: context, translationMode: TranslationMode.Spanish);
    return DictionaryPageModel._(
      LocalHistoryValueNotifier(
          modalRoute: ModalRoute.of(context),
          initialValue: DictionaryTab.search),
      LocalHistoryValueNotifier(
          modalRoute: ModalRoute.of(context), initialValue: englishPage),
      englishPage,
      spanishPage,
    );
  }

  TranslationPageModel pageModel(TranslationMode translationMode) =>
      translationMode == TranslationMode.English
          ? englishPageModel
          : spanishPageModel;

  void onTranslationModeChanged(TranslationMode newTranslationMode) =>
      currTranslationPageModel.value = pageModel(newTranslationMode);

  void onEntrySelected(BuildContext context, Entry newEntry) {
    assert(newEntry != null);
    bool isFavoritesModel = isFavoritesOnly(context);
    // Only update if the value has actually changed
    if (newEntry.urlEncodedHeadword ==
        _getPageModel(_currModel, isFavoritesModel).currSelectedHeadword)
      return;
    _getPageModel(_currModel, isFavoritesModel).currSelectedEntry.value =
        SelectedEntry(
      urlEncodedHeadword: newEntry.urlEncodedHeadword,
      entry: Future.value(newEntry),
    );
  }

  SearchPageModel _getPageModel(
          TranslationPageModel translationPageModel, bool isFavoritesModel) =>
      isFavoritesModel
          ? translationPageModel.favoritesPageModel
          : translationPageModel.searchPageModel;

  void onHeadwordSelected(BuildContext context, String newUrlEncodedHeadword) {
    bool isFavoritesModel = isFavoritesOnly(context);
    // Only update if the value has actually changed
    if (newUrlEncodedHeadword ==
        _getPageModel(_currModel, isFavoritesModel).currSelectedHeadword)
      return;
    _getPageModel(_currModel, isFavoritesModel).currSelectedEntry.value =
        SelectedEntry(
      urlEncodedHeadword: newUrlEncodedHeadword,
      entry: newUrlEncodedHeadword.isNotEmpty
          ? MyApp.db.getEntry(_currModel.translationMode, newUrlEncodedHeadword)
          : null,
    );
  }

  void onSearchChanged(
    BuildContext context, {
    String newSearchString,
    SearchSettingsModel newSearchSettings,
  }) {
    _getPageModel(_currModel, isFavoritesOnly(context))
        .entrySearchModel
        .onSearchStringChanged(
          newSearchString: newSearchString,
          newSearchSettings: newSearchSettings,
        );
  }
}

class TranslationPageModel {
  // Translation mode state.
  final TranslationMode translationMode;

  final SearchPageModel searchPageModel;

  final SearchPageModel favoritesPageModel;

  final DialoguesPageModel dialoguesPageModel;

  bool get isEnglish => translationMode == TranslationMode.English;

  factory TranslationPageModel.empty(
          {@required BuildContext context,
          @required TranslationMode translationMode}) =>
      TranslationPageModel._(
          context: context, translationMode: translationMode);

  TranslationPageModel._({
    @required BuildContext context,
    @required this.translationMode,
  })  : searchPageModel = SearchPageModel.empty(
          context: context,
          translationMode: translationMode,
          isFavoritesOnly: false,
        ),
        favoritesPageModel = SearchPageModel.empty(
          context: context,
          translationMode: translationMode,
          isFavoritesOnly: true,
        ),
        dialoguesPageModel = DialoguesPageModel.empty(context);

  static TranslationPageModel of(BuildContext context) =>
      context.select<TranslationPageModel, TranslationPageModel>((mdl) => mdl);
}

class SearchPageModel {
  // Translation mode state.
  final TranslationMode translationMode;

  // Selected entry state.
  final LocalHistoryValueNotifier<SelectedEntry> currSelectedEntry;

  // Entry search state
  final EntrySearchModel entrySearchModel;

  bool get isEnglish => translationMode == TranslationMode.English;

  bool get hasSelection => currSelectedEntry.value.hasSelection;

  String get searchString => entrySearchModel.searchString;

  bool get hasSearchString => entrySearchModel.searchString.isNotEmpty;

  String get currSelectedHeadword => currSelectedEntry.value.urlEncodedHeadword;

  static SearchPageModel of(BuildContext context) =>
      context.select<SearchPageModel, SearchPageModel>((mdl) => mdl);

  static SearchPageModel readFrom(BuildContext context) =>
      context.read<SearchPageModel>();

  factory SearchPageModel.empty({
    @required BuildContext context,
    @required TranslationMode translationMode,
    @required bool isFavoritesOnly,
  }) =>
      SearchPageModel._(
        translationMode: translationMode,
        currSelectedEntry: LocalHistoryValueNotifier(
          modalRoute: ModalRoute.of(context),
          initialValue: SelectedEntry.empty(),
        ),
        entrySearchModel:
            EntrySearchModel.empty(translationMode, isFavoritesOnly),
      );

  SearchPageModel._({
    @required this.translationMode,
    @required this.currSelectedEntry,
    @required this.entrySearchModel,
  });
}

class SelectedEntry {
  final String urlEncodedHeadword;
  final Future<Entry> entry;

  SelectedEntry({@required this.urlEncodedHeadword, @required this.entry});

  static SelectedEntry empty() => SelectedEntry(
        urlEncodedHeadword: '',
        entry: null,
      );

  bool get hasSelection => urlEncodedHeadword.isNotEmpty;
}

bool isFavoritesOnly(BuildContext context) =>
    DictionaryPageModel.readFrom(context).currentTab.value ==
    DictionaryTab.favorites;
