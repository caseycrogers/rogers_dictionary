import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rogers_dictionary/dictionary_navigator/local_history_value_notifier.dart';
import 'package:rogers_dictionary/protobufs/entry.pb.dart';

import 'entry_search_model.dart';
import 'translation_page_model.dart';

class SearchPageModel {
  // Translation mode state.
  final TranslationMode translationMode;

  // Selected entry state.
  final LocalHistoryValueNotifier<SelectedEntry?> currSelectedEntry;

  // Entry search state
  final EntrySearchModel entrySearchModel;

  bool get isEnglish => translationMode == TranslationMode.English;

  bool get hasSelection => currSelectedEntry.value != null;

  String get searchString => entrySearchModel.searchString;

  String? get currSelectedHeadword =>
      currSelectedEntry.value?.urlEncodedHeadword;

  static SearchPageModel of(BuildContext context) =>
      context.select<SearchPageModel, SearchPageModel>((mdl) => mdl);

  static SearchPageModel readFrom(BuildContext context) =>
      context.read<SearchPageModel>();

  factory SearchPageModel.empty({
    required BuildContext context,
    required TranslationMode translationMode,
    required bool isFavoritesOnly,
  }) =>
      SearchPageModel._(
        translationMode: translationMode,
        currSelectedEntry: LocalHistoryValueNotifier(
          modalRoute: ModalRoute.of(context)!,
          initialValue: null,
        ),
        entrySearchModel:
            EntrySearchModel.empty(translationMode, isFavoritesOnly),
      );

  SearchPageModel._({
    required this.translationMode,
    required this.currSelectedEntry,
    required this.entrySearchModel,
  });
}

class SelectedEntry {
  final String urlEncodedHeadword;
  final Future<Entry> entry;

  SelectedEntry({required this.urlEncodedHeadword, required this.entry});
}
