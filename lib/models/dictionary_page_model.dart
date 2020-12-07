import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';
import 'package:rogers_dictionary/main.dart';

class DictionaryPageModel {
  // Selected entry state.
  Future<Entry> selectedEntry;
  String selectedHeadword;

  get hasSelection => selectedHeadword.isNotEmpty;

  // Search string state.
  final SearchStringModel searchStringModel;

  // EntryList state.
  List<Entry> entries;
  String startAfter;
  final ScrollController scrollController;

  static DictionaryPageModel of(BuildContext context) =>
      ModalRoute.of(context).settings.arguments;

  factory DictionaryPageModel.empty() => DictionaryPageModel._(
      selectedEntry: null,
      selectedHeadword: '',
      searchStringModel: SearchStringModel._(''),
      entries: [],
      startAfter: '',
      scrollController: ScrollController());

  factory DictionaryPageModel.fromHeadword(String urlEncodedHeadword) =>
      DictionaryPageModel._(
          selectedEntry: MyApp.db.getEntry(urlEncodedHeadword),
          selectedHeadword: urlEncodedHeadword,
          searchStringModel: SearchStringModel._(''),
          entries: [],
          // Truncate the last letter because we want to include urlEncodedHeadword
          startAfter:
              urlEncodedHeadword.substring(0, urlEncodedHeadword.length - 1),
          scrollController: ScrollController());

  factory DictionaryPageModel.copy(BuildContext context, Entry newEntry) =>
      DictionaryPageModel.of(context)._copy(newEntry);

  DictionaryPageModel _copy(Entry newEntry) => DictionaryPageModel._(
      selectedEntry: Future.value(newEntry),
      selectedHeadword: newEntry.headword,
      searchStringModel: SearchStringModel._(searchStringModel.value),
      entries: List.from(entries),
      startAfter: startAfter,
      scrollController:
          ScrollController(initialScrollOffset: scrollController.offset));

  DictionaryPageModel._(
      {@required this.selectedEntry,
      @required this.selectedHeadword,
      @required this.searchStringModel,
      @required this.entries,
      @required this.startAfter,
      @required this.scrollController});
}

class SearchStringModel extends ValueNotifier<String> {
  SearchStringModel._(String initialSearchString) : super(initialSearchString);
}
