import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:rogers_dictionary/clients/entry_builders.dart';
import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/models/search_model.dart';
import 'package:rogers_dictionary/models/translation_model.dart';
import 'package:rogers_dictionary/pages/dictionary_page.dart';
import 'package:rogers_dictionary/protobufs/entry.pb.dart';
import 'package:rogers_dictionary/util/string_utils.dart';

const TranslationMode DEFAULT_TRANSLATION_MODE = TranslationMode.English;

TranslationMode indexToTranslationMode(int index) =>
    TranslationMode.values[index];

int translationModeToIndex(TranslationMode translationMode) {
  return TranslationMode.values.indexOf(translationMode);
}

class DictionaryModel {
  DictionaryModel()
      : currentTab = ValueNotifier(DictionaryTab.search),
        englishPageModel = TranslationModel(
          translationMode: TranslationMode.English,
        ),
        spanishPageModel = TranslationModel(
          translationMode: TranslationMode.Spanish,
        ) {
    translationModel = ValueNotifier<TranslationModel>(englishPageModel);
    translationModel.addListener(() {
      DictionaryApp.analytics.setCurrentScreen(screenName: name);
    });
  }

  static late final DictionaryModel _instance = DictionaryModel();

  final TranslationModel englishPageModel;
  final TranslationModel spanishPageModel;

  TranslationModel translationModelFor(TranslationMode mode) {
    if (mode == TranslationMode.English) {
      return englishPageModel;
    }
    return spanishPageModel;
  }

  late final ValueNotifier<TranslationModel> translationModel;

  final ValueNotifier<DictionaryTab> currentTab;

  final ValueNotifier<double> pageOffset = ValueNotifier(0);

  final ScrollController nestedController = ScrollController();

  TranslationModel get currTranslationModel => translationModel.value;

  TranslationMode get currTranslationMode =>
      translationModel.value.translationMode;

  bool get isEnglish => translationModel.value.isEnglish;

  static DictionaryModel of(BuildContext context) {
    return _instance;
  }

  TranslationModel getPageModel(TranslationMode translationMode) =>
      isEnglish ? englishPageModel : spanishPageModel;

  TranslationModel get _oppModel =>
      currTranslationModel.isEnglish ? spanishPageModel : englishPageModel;

  void onTranslationModeChanged(BuildContext context,
      [TranslationMode? newTranslationMode]) {
    translationModel.value =
        translationModelFor(newTranslationMode ?? _oppModel.translationMode);
  }

  void onEntrySelected(BuildContext context, Entry newEntry) =>
      _onHeadwordSelected(
        context,
        newUrlEncodedHeadword: newEntry.headword.urlEncodedHeadword,
        newEntry: newEntry,
        isRelated: false,
        isOppositeHeadword: false,
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
      isOppositeHeadword: false,
    );
  }

  void onOppositeHeadwordSelected(
    BuildContext context,
    String newUrlEncodedHeadword,
  ) {
    translationModel.value = _oppModel;
    _onHeadwordSelected(
      context,
      newUrlEncodedHeadword: newUrlEncodedHeadword,
      isRelated: false,
      // The depth of an opp headword selection is 1 deeper than a typical
      // selection.
      isOppositeHeadword: true,
    );
  }

  void _onHeadwordSelected(
    BuildContext context, {
    required String newUrlEncodedHeadword,
    required bool isRelated,
    required bool isOppositeHeadword,
    Entry? newEntry,
    SearchModel? pageModel,
  }) {
    pageModel ??= isBookmarkedOnly
        ? currTranslationModel.bookmarksPageModel
        : currTranslationModel.searchPageModel;
    // Only update if the value has actually changed
    if (newUrlEncodedHeadword == pageModel.currSelectedHeadword) {
      return;
    }
    if (newUrlEncodedHeadword.isEmpty) {
      pageModel.adKeywords.value = [
        ...pageModel.entrySearchModel.entries
            .getRange(0, min(pageModel.entrySearchModel.entries.length, 3))
            .map((e) => e.headword.headwordText),
      ];
      return pageModel.currSelectedEntry.value = null;
    }
    final FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    final SelectedEntry selectedEntry = SelectedEntry(
      urlEncodedHeadword: newUrlEncodedHeadword,
      entry: newEntry == null
          ? DictionaryApp.db.getEntry(
              currTranslationModel.translationMode, newUrlEncodedHeadword)
          : Future<Entry>.value(newEntry),
      isRelated: isRelated,
      isOppositeHeadword: isOppositeHeadword,
    );
    pageModel.currSelectedEntry.value = selectedEntry;
    pageModel.adKeywords.value = [
      EntryUtils.urlDecode(selectedEntry.urlEncodedHeadword),
    ];
  }

  bool get isBookmarkedOnly => currentTab.value == DictionaryTab.bookmarks;

  String get name {
    String? thirdTier;
    switch (currentTab.value) {
      case DictionaryTab.search:
        thirdTier = translationModel.value.searchPageModel.currSelectedHeadword;
        break;
      case DictionaryTab.bookmarks:
        thirdTier = translationModel.value.searchPageModel.currSelectedHeadword;
        break;
      case DictionaryTab.dialogues:
        thirdTier = translationModel
            .value.dialoguesPageModel.selectedChapter?.englishTitle;
        break;
    }
    return '${currTranslationMode.toString().enumString}'
        ' > ${currentTab.value.toString().enumString}'
        ' > ${thirdTier.toString().enumString}';
  }
}
