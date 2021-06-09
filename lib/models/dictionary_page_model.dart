import 'dart:async';
import 'package:provider/provider.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:rogers_dictionary/entry_database/entry_builders.dart';
import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/models/search_page_model.dart';
import 'package:rogers_dictionary/models/translation_page_model.dart';
import 'package:rogers_dictionary/dictionary_navigator/local_history_value_notifier.dart';
import 'package:rogers_dictionary/pages/dictionary_page.dart';
import 'package:rogers_dictionary/protobufs/entry.pb.dart';
import 'package:rogers_dictionary/widgets/dictionary_page/dictionary_top_bar.dart';

const TranslationMode DEFAULT_TRANSLATION_MODE = TranslationMode.English;

TranslationMode indexToTranslationMode(int index) =>
    TranslationMode.values[index];

int translationModeToIndex(TranslationMode translationMode) {
  return TranslationMode.values.indexOf(translationMode);
}

class DictionaryPageModel {
  DictionaryPageModel._(
      this.currentTab, this.currTranslationPageModel, this.spanishPageModel)
      : englishPageModel = currTranslationPageModel.value,
        topBarController = DictionaryTopBarController();

  DictionaryPageModel.empty(BuildContext context)
      : this._(
          LocalHistoryValueNotifier<DictionaryTab>(
              modalRoute: ModalRoute.of(context)!,
              initialValue: DictionaryTab.search),
          LocalHistoryValueNotifier<TranslationPageModel>(
            modalRoute: ModalRoute.of(context)!,
            initialValue: TranslationPageModel.empty(
                context: context, translationMode: DEFAULT_TRANSLATION_MODE),
          ),
          TranslationPageModel.empty(
              context: context, translationMode: TranslationMode.Spanish),
        );

  final TranslationPageModel englishPageModel;
  final TranslationPageModel spanishPageModel;

  final LocalHistoryValueNotifier<TranslationPageModel>
      currTranslationPageModel;

  final LocalHistoryValueNotifier<DictionaryTab> currentTab;

  final DictionaryTopBarController topBarController;

  TranslationPageModel get _currModel => currTranslationPageModel.value;

  bool get isEnglish => currTranslationPageModel.value.isEnglish;

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

  void onTranslationModeChanged(
      BuildContext context, TranslationMode newTranslationMode) {
    currTranslationPageModel.value = pageModel(newTranslationMode);
  }

  void onEntrySelected(BuildContext context, Entry newEntry) =>
      _onHeadwordSelected(
        context,
        newUrlEncodedHeadword: newEntry.headword.urlEncodedHeadword,
        newEntry: newEntry,
      );

  void onHeadwordSelected(BuildContext context, String newUrlEncodedHeadword) =>
      _onHeadwordSelected(
        context,
        newUrlEncodedHeadword: newUrlEncodedHeadword,
      );

  void onOppositeHeadwordSelected(
    BuildContext context,
    String newUrlEncodedHeadword,
  ) {
    final SearchPageModel pageModel = isFavoritesOnly
        ? _oppModel.favoritesPageModel
        : _oppModel.searchPageModel;
    final SelectedEntry? previousSelection = pageModel.currSelectedEntry.value;
    currTranslationPageModel.setWith(_oppModel, onPop: () {
      currTranslationPageModel.setWith(_oppModel);
      pageModel.currSelectedEntry.setWith(previousSelection);
    });
    _onHeadwordSelected(
      context,
      newUrlEncodedHeadword: newUrlEncodedHeadword,
      updateStack: false,
    );
  }

  void _onHeadwordSelected(
    BuildContext context, {
    required String newUrlEncodedHeadword,
    Entry? newEntry,
    bool updateStack = true,
  }) {
    final SearchPageModel pageModel = isFavoritesOnly
        ? _currModel.favoritesPageModel
        : _currModel.searchPageModel;
    // Only update if the value has actually changed
    if (newUrlEncodedHeadword == pageModel.currSelectedHeadword) {
      return;
    }
    if (newUrlEncodedHeadword.isEmpty) {
      if (updateStack) {
        return pageModel.currSelectedEntry.value = null;
      }
      pageModel.currSelectedEntry.setWith(null);
    } else {
      final SelectedEntry selectedEntry = SelectedEntry(
        urlEncodedHeadword: newUrlEncodedHeadword,
        entry: newEntry == null
            ? MyApp.db
                .getEntry(_currModel.translationMode, newUrlEncodedHeadword)
            : Future<Entry>.value(newEntry),
      );
      if (updateStack) {
        pageModel.currSelectedEntry.value = selectedEntry;
        return;
      }
      pageModel.currSelectedEntry.setWith(selectedEntry);
    }
  }

  void listenOnPageChanges(BuildContext context) {
    currentTab.addListener(() => updateTopBarArrow(context));
    currTranslationPageModel.addListener(() => updateTopBarArrow(context));
    for (final TranslationPageModel pageModel in [
      englishPageModel,
      spanishPageModel
    ]) {
      pageModel.searchPageModel.currSelectedEntry
          .addListener(() => updateTopBarArrow(context));
      pageModel.favoritesPageModel.currSelectedEntry
          .addListener(() => updateTopBarArrow(context));
      pageModel.dialoguesPageModel.selectedChapterNotifier
          .addListener(() => updateTopBarArrow(context));
    }
  }

  void updateTopBarArrow(BuildContext context) {
    // Handle dialogue page.
    if (currentTab.value == DictionaryTab.dialogues) {
      if (_currModel.dialoguesPageModel.hasSelection) {
        topBarController.onClose = (BuildContext context) => _currModel
            .dialoguesPageModel
            .onChapterSelected(context, null, null);
        return;
      }
      topBarController.onClose = null;
      return;
    }
    // Handle search pages.
    final SearchPageModel pageModel = isFavoritesOnly
        ? _currModel.favoritesPageModel
        : _currModel.searchPageModel;
    // Add back button to top bar.
    if (pageModel.hasSelection) {
      topBarController.onClose = (BuildContext context) =>
          _onHeadwordSelected(context, newUrlEncodedHeadword: '');
      return;
    }
    // Remove top bar arrow.
    return topBarController.onClose = null;
  }

  bool get isFavoritesOnly => currentTab.value == DictionaryTab.favorites;
}

abstract class BasePageModel {
  void onClose(BuildContext context);
}
