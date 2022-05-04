import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:implicit_navigator/implicit_navigator.dart';

import 'package:rogers_dictionary/dictionary_app.dart';
import 'package:rogers_dictionary/models/search_model.dart';
import 'package:rogers_dictionary/models/translation_mode.dart';
import 'package:rogers_dictionary/models/translation_model.dart';
import 'package:rogers_dictionary/protobufs/entry.pb.dart';
import 'package:rogers_dictionary/util/focus_utils.dart';
import 'package:rogers_dictionary/util/string_utils.dart';
import 'package:rogers_dictionary/util/value_notifier_extension.dart';
import 'package:rogers_dictionary/widgets/dictionary_page/dictionary_tab.dart';

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

  static late DictionaryModel _instance = DictionaryModel();

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

  late ImplicitNavigatorState<DictionaryTab> tabNavigator;

  static DictionaryModel get instance => _instance;

  // Only used for taking screenshots.
  @visibleForTesting
  static void reset() {
    _instance = DictionaryModel();
    _instance.currTranslationModel.dialoguesPageModel.reset();
  }

  ValueNotifier<List<String>> get currentAdKeywords {
    return currentTab.expand<List<String>>((tab) {
      switch (tab) {
        case DictionaryTab.search:
          return currTranslationModel.searchModel.adKeywords;
        case DictionaryTab.bookmarks:
          return currTranslationModel.bookmarksModel.adKeywords;
        case DictionaryTab.dialogues:
          // There are no ad keywords for the dialogues page.
          return ValueNotifier([]);
      }
    });
  }

  final ScrollController nestedController = ScrollController();

  TranslationModel get currTranslationModel => translationModel.value;

  TranslationMode get currTranslationMode =>
      translationModel.value.translationMode;

  TranslationModel get oppTranslationModel =>
      currTranslationModel.isEnglish ? spanishPageModel : englishPageModel;

  bool get isEnglish => translationModel.value.isEnglish;

  TranslationModel getPageModel(TranslationMode translationMode) =>
      isEnglish ? englishPageModel : spanishPageModel;

  void onTranslationModeChanged([TranslationMode? newTranslationMode]) {
    translationModel.value = translationModelFor(
        newTranslationMode ?? oppTranslationModel.translationMode);
  }

  Future<void> onBookmarkSet(
    BuildContext context,
    Entry entry,
    bool newValue,
  ) async {
    final TranslationMode mode = SearchModel.of(context).mode;
    await DictionaryApp.db.setBookmark(mode, entry, newValue);
  }

  void onEntrySelected(BuildContext context, Entry newEntry) =>
      _onEntrySelected(
        context,
        headword: newEntry.headword.text,
        newEntry: newEntry,
      );

  void clearSelectedEntry(
    BuildContext context, {
    SearchModel? searchModel,
    SelectedEntryReferrer? referrer,
  }) {
    _onEntrySelected(
      context,
      headword: '',
      searchModel: searchModel,
      referrer: referrer,
    );
  }

  void onHeadwordSelected(
    BuildContext context,
    String newHeadword, {
    SelectedEntryReferrer? referrer,
  }) {
    _onEntrySelected(
      context,
      headword: newHeadword,
      referrer: referrer,
    );
  }

  void onOppositeHeadwordSelected(
    BuildContext context,
    String newHeadword,
  ) {
    translationModel.value = oppTranslationModel;
    _onEntrySelected(
      context,
      headword: newHeadword,
      referrer: SelectedEntryReferrer.oppositeHeadword,
    );
  }

  void _onEntrySelected(
    BuildContext context, {
    required String headword,
    SelectedEntryReferrer? referrer,
    Entry? newEntry,
    SearchModel? searchModel,
  }) {
    searchModel ??= isBookmarksOnly
        ? currTranslationModel.bookmarksModel
        : currTranslationModel.searchModel;
    // Only update if the value has actually changed
    if (headword == searchModel.currSelectedHeadword) {
      return;
    }
    if (headword.isEmpty) {
      searchModel.adKeywords.value = [
        ...searchModel.entrySearchModel.entries
            .getRange(0, min(searchModel.entrySearchModel.entries.length, 3))
            .map((e) => e.headword.text),
      ];
      return searchModel.currSelectedEntry.value = null;
    }
    unFocus();
    final SelectedEntry selectedEntry = SelectedEntry(
      headword: headword,
      entry: newEntry == null
          ? DictionaryApp.db
              .getEntry(currTranslationModel.translationMode, headword)
          : Future<Entry>.value(newEntry),
      referrer: referrer,
    );
    searchModel.currSelectedEntry.value = selectedEntry;
    selectedEntry.entry.then((e) {
      searchModel!.adKeywords.value = [
        e.headword.text,
      ];
    });
  }

  bool get isBookmarksOnly => currentTab.value == DictionaryTab.bookmarks;

  String get name {
    String? thirdTier;
    switch (currentTab.value) {
      case DictionaryTab.search:
        thirdTier = translationModel.value.searchModel.currSelectedHeadword;
        break;
      case DictionaryTab.bookmarks:
        thirdTier = translationModel.value.searchModel.currSelectedHeadword;
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
