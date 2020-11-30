import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';
import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/models/search_string_model.dart';

@immutable
class DictionaryPageModel {
  final Future<Entry> entry;
  final String headword;
  final SearchStringModel searchStringModel;

  get hasSelection => headword.isNotEmpty;

  static DictionaryPageModel of(BuildContext context) =>
      ModalRoute.of(context).settings.arguments;

  factory DictionaryPageModel.empty() =>
      DictionaryPageModel._(null, '', SearchStringModel());

  factory DictionaryPageModel.fromHeadword(String urlEncodedHeadword) =>
      DictionaryPageModel._(Future.value(MyApp.db.getEntry(urlEncodedHeadword)),
          urlEncodedHeadword, SearchStringModel());

  factory DictionaryPageModel.copyWith(BuildContext context, {Entry entry}) =>
      DictionaryPageModel.of(context)._copyWith(entry: entry);

  DictionaryPageModel _copyWith({Entry entry}) => DictionaryPageModel._(
      Future.value(entry ?? this.entry),
      entry.urlEncodedHeadword,
      searchStringModel);

  DictionaryPageModel._(this.entry, this.headword, this.searchStringModel);
}
