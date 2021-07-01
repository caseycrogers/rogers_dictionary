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
              value: DictionaryTab.search,
              getDepth: (newValue) => newValue == DictionaryTab.search ? 0 : 1),
          ValueNotifier<TranslationPageModel>(
            TranslationPageModel.empty(
                context: context, translationMode: DEFAULT_TRANSLATION_MODE),
          ),
          TranslationPageModel.empty(
              context: context, translationMode: TranslationMode.Spanish),
        );

  final TranslationPageModel englishPageModel;
  final TranslationPageModel spanishPageModel;

  final ValueNotifier<TranslationPageModel> translationPageModel;

  final LocalHistoryValueNotifier<DictionaryTab> currentTab;

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
    // We need special case history stack and pop behavior so we need to
    // manually implement implement it.
    // Namely, we should add to the stack with first onOppHeadword and onPop
    // should pop the entry and the translation mode.
    final TranslationPageModel oldPageModel = _currModel;
    final LocalHistoryValueNotifier<SelectedEntry?> selectedEntryNotifier =
        isFavoritesOnly
            ? _oppModel.favoritesPageModel.currSelectedEntry
            : _oppModel.searchPageModel.currSelectedEntry;
    final int oldDepth = selectedEntryNotifier.depth;
    final SelectedEntry? oldSelectedEntry = selectedEntryNotifier.value;
    translationPageModel.value = _oppModel;
    _onHeadwordSelected(
      context,
      newUrlEncodedHeadword: newUrlEncodedHeadword,
      // The depth of an opp headword selection is 1 deeper than a typical
      // selection.
      overrideDepth: 2,
      onPop: () {
        translationPageModel.value = oldPageModel;
        selectedEntryNotifier.depth = oldDepth;
        // A negative depth will never update the stack.
        selectedEntryNotifier.setWith(oldSelectedEntry, overrideDepth: -1);
      },
    );
  }

  void _onHeadwordSelected(
    BuildContext context, {
    required String newUrlEncodedHeadword,
    Entry? newEntry,
    SearchPageModel? pageModel,
    VoidCallback? onPop,
    int? overrideDepth,
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
    );
    pageModel.currSelectedEntry.setWith(
      selectedEntry,
      overrideDepth: overrideDepth,
      onPop: onPop,
    );
  }

  bool get isFavoritesOnly => currentTab.value == DictionaryTab.favorites;
}

abstract class BasePageModel {
  void onClose(BuildContext context);
}
