import 'dart:async';
import 'package:provider/provider.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:rogers_dictionary/entry_database/entry.dart';
import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/models/search_page_model.dart';
import 'package:rogers_dictionary/models/translation_page_model.dart';
import 'package:rogers_dictionary/models/search_settings_model.dart';
import 'package:rogers_dictionary/dictionary_navigator/local_history_value_notifier.dart';
import 'package:rogers_dictionary/pages/dictionary_page.dart';

const DEFAULT_TRANSLATION_MODE = TranslationMode.English;

TranslationMode indexToTranslationMode(int index) =>
    TranslationMode.values[index];

int translationModeToIndex(TranslationMode translationMode) {
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
          modalRoute: ModalRoute.of(context)!,
          initialValue: DictionaryTab.search),
      LocalHistoryValueNotifier(
          modalRoute: ModalRoute.of(context)!, initialValue: englishPage),
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
        newUrlEncodedHeadword.isNotEmpty
            ? SelectedEntry(
                urlEncodedHeadword: newUrlEncodedHeadword,
                entry: MyApp.db.getEntry(
                    _currModel.translationMode, newUrlEncodedHeadword),
              )
            : null;
  }

  void onSearchChanged(
    BuildContext context, {
    String? newSearchString,
    SearchSettingsModel? newSearchSettings,
  }) {
    _getPageModel(_currModel, isFavoritesOnly(context))
        .entrySearchModel
        .onSearchStringChanged(
          newSearchString: newSearchString,
          newSearchSettings: newSearchSettings,
        );
  }
}

bool isFavoritesOnly(BuildContext context) =>
    DictionaryPageModel.readFrom(context).currentTab.value ==
    DictionaryTab.favorites;
