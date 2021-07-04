import 'dart:async';
import 'package:provider/provider.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:rogers_dictionary/entry_database/entry_builders.dart';
import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/models/search_page_model.dart';
import 'package:rogers_dictionary/models/translation_page_model.dart';
import 'package:rogers_dictionary/pages/dictionary_page.dart';
import 'package:rogers_dictionary/protobufs/entry.pb.dart';

const TranslationMode DEFAULT_TRANSLATION_MODE = TranslationMode.English;

TranslationMode indexToTranslationMode(int index) =>
    TranslationMode.values[index];

int translationModeToIndex(TranslationMode translationMode) {
  return TranslationMode.values.indexOf(translationMode);
}

class DictionaryPageModel {
  DictionaryPageModel()
      : currentTab = ValueNotifier(DictionaryTab.search),
        englishPageModel = TranslationPageModel(
          translationMode: TranslationMode.English,
        ),
        spanishPageModel = TranslationPageModel(
          translationMode: TranslationMode.Spanish,
        ) {
    translationPageModel =
        ValueNotifier<TranslationPageModel>(englishPageModel);
  }

  final TranslationPageModel englishPageModel;
  final TranslationPageModel spanishPageModel;

  late final ValueNotifier<TranslationPageModel> translationPageModel;

  final ValueNotifier<DictionaryTab> currentTab;

  final ValueNotifier<double> pageOffset = ValueNotifier(0);

  final ScrollController nestedController = ScrollController();

  TranslationPageModel get _currModel => translationPageModel.value;

  TranslationMode get currTranslationMode =>
      translationPageModel.value.translationMode;

  bool get isEnglish => translationPageModel.value.isEnglish;

  static DictionaryPageModel of(BuildContext context) =>
      context.select<DictionaryPageModel, DictionaryPageModel>(
          (DictionaryPageModel mdl) => mdl);

  static DictionaryPageModel readFrom(BuildContext context) =>
      context.read<DictionaryPageModel>();

  TranslationPageModel pageModel(TranslationMode translationMode) =>
      translationMode == TranslationMode.English
          ? englishPageModel
          : spanishPageModel;

  TranslationPageModel get _oppModel =>
      _currModel.isEnglish ? spanishPageModel : englishPageModel;

  void onTranslationModeChanged(BuildContext context,
      [TranslationMode? newTranslationMode]) {
    translationPageModel.value =
        pageModel(newTranslationMode ?? _oppModel.translationMode);
  }

  void onEntrySelected(BuildContext context, Entry newEntry) =>
      _onHeadwordSelected(
        context,
        newUrlEncodedHeadword: newEntry.headword.urlEncodedHeadword,
        newEntry: newEntry,
        isRelated: false,
      );

  void onHeadwordSelected(
    BuildContext context,
    String newUrlEncodedHeadword, {
    bool? isRelated,
  }) {
    _onHeadwordSelected(
        context,
        newUrlEncodedHeadword: newUrlEncodedHeadword,
        isRelated: isRelated ?? false,
      );
  }

  void onOppositeHeadwordSelected(
    BuildContext context,
    String newUrlEncodedHeadword,
  ) {
    translationPageModel.value = _oppModel;
    _onHeadwordSelected(
      context,
      newUrlEncodedHeadword: newUrlEncodedHeadword,
      // The depth of an opp headword selection is 1 deeper than a typical
      // selection.
      isRelated: true,
    );
  }

  void _onHeadwordSelected(
    BuildContext context, {
    required String newUrlEncodedHeadword,
    required bool isRelated,
    Entry? newEntry,
    SearchPageModel? pageModel,
  }) {
    pageModel ??= isFavoritesOnly
        ? _currModel.favoritesPageModel
        : _currModel.searchPageModel;
    // Only update if the value has actually changed
    if (newUrlEncodedHeadword == pageModel.currSelectedHeadword) {
      return;
    }
    final FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    if (newUrlEncodedHeadword.isEmpty) {
      return pageModel.currSelectedEntry.value = null;
    }
    final SelectedEntry selectedEntry = SelectedEntry(
      urlEncodedHeadword: newUrlEncodedHeadword,
      entry: newEntry == null
          ? MyApp.db.getEntry(_currModel.translationMode, newUrlEncodedHeadword)
          : Future<Entry>.value(newEntry),
      isRelated: isRelated,
    );
    pageModel.currSelectedEntry.value = selectedEntry;
  }

  bool get isFavoritesOnly => currentTab.value == DictionaryTab.favorites;
}
