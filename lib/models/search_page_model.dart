import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rogers_dictionary/dictionary_navigator/local_history_value_notifier.dart';
import 'package:rogers_dictionary/protobufs/entry.pb.dart';

import 'entry_search_model.dart';
import 'translation_page_model.dart';

class SearchPageModel {
  SearchPageModel._({
    required this.translationMode,
    required this.currSelectedEntry,
    required this.entrySearchModel,
  }) {
    _currSearchString.addListener(() {
      if (_currSearchString.value.isNotEmpty) {
        currSelectedEntry.value = null;
      }
    });
  }

  SearchPageModel.empty({
    required BuildContext context,
    required TranslationMode translationMode,
    required bool isFavoritesOnly,
  }) : this._(
          translationMode: translationMode,
          currSelectedEntry: LocalHistoryValueNotifier<SelectedEntry?>(
            modalRoute: ModalRoute.of(context)!,
            value: null,
            getDepth: (selectedEntry) => selectedEntry == null ?  0 : 1,
          ),
          entrySearchModel: EntrySearchModel.empty(
            _currSearchString,
            translationMode,
            isFavoritesOnly,
          ),
        );

  // Translation mode state.
  final TranslationMode translationMode;

  // Selected entry state.
  final LocalHistoryValueNotifier<SelectedEntry?> currSelectedEntry;

  // Entry search state
  final EntrySearchModel entrySearchModel;

  static final ValueNotifier<String> _currSearchString = ValueNotifier('');

  bool get isEnglish => translationMode == TranslationMode.English;

  bool get hasSelection => currSelectedEntry.value != null;

  String get searchString => entrySearchModel.searchString;

  String? get currSelectedHeadword =>
      currSelectedEntry.value?.urlEncodedHeadword;

  static SearchPageModel of(BuildContext context) =>
      context.watch<SearchPageModel>();

  static SearchPageModel readFrom(BuildContext context) =>
      context.read<SearchPageModel>();
}

class SelectedEntry {
  SelectedEntry({required this.urlEncodedHeadword, required this.entry});

  final String urlEncodedHeadword;
  final Future<Entry> entry;
}
