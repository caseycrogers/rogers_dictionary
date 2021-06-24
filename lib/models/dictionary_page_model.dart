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

const TranslationMode DEFAULT_TRANSLATION_MODE = TranslationMode.English;

TranslationMode indexToTranslationMode(int index) =>
    TranslationMode.values[index];

int translationModeToIndex(TranslationMode translationMode) {
  return TranslationMode.values.indexOf(translationMode);
}

class DictionaryPageModel {
  DictionaryPageModel._(
    this.currentTab,
    this.translationPageModel,
    this.spanishPageModel,
  ) : englishPageModel = translationPageModel.value;

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

  final LocalHistoryValueNotifier<TranslationPageModel> translationPageModel;

  final LocalHistoryValueNotifier<DictionaryTab> currentTab;

  final ValueNotifier<double> pageOffset = ValueNotifier(0);

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
      );

  void onHeadwordSelected(
    BuildContext context,
    String newUrlEncodedHeadword, {
    SearchPageModel? pageModel,
  }) =>
      _onHeadwordSelected(
        context,
        newUrlEncodedHeadword: newUrlEncodedHeadword,
        pageModel: pageModel,
      );

  void onOppositeHeadwordSelected(
    BuildContext context,
    String newUrlEncodedHeadword,
  ) {
    final SearchPageModel pageModel = isFavoritesOnly
        ? _oppModel.favoritesPageModel
        : _oppModel.searchPageModel;
    final SelectedEntry? previousSelection = pageModel.currSelectedEntry.value;
    translationPageModel.setWith(_oppModel, onPop: () {
      translationPageModel.setWith(_oppModel);
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
    SearchPageModel? pageModel,
    bool updateStack = true,
  }) {
    pageModel ??= isFavoritesOnly
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

  bool get isFavoritesOnly => currentTab.value == DictionaryTab.favorites;
}

abstract class BasePageModel {
  void onClose(BuildContext context);
}
