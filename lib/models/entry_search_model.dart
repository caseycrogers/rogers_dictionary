// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:rogers_dictionary/dictionary_app.dart';
import 'package:rogers_dictionary/models/dictionary_model.dart';
import 'package:rogers_dictionary/models/translation_mode.dart';
import 'package:rogers_dictionary/protobufs/entry.pb.dart';
import 'package:rogers_dictionary/util/layout_picker.dart';

class EntrySearchModel {
  EntrySearchModel._(
    this._translationMode,
    this._isBookmarkedOnly,
  );

  EntrySearchModel.empty(
    TranslationMode translationMode,
    bool isBookmarkedOnly,
  ) : this._(translationMode, isBookmarkedOnly);

  // Static so that this is shared between both modes.
  static final ValueNotifier<String> _currSearchString = ValueNotifier('');

  @visibleForTesting
  static void reset() => _currSearchString.value = '';

  // Used to expose the current entry list to other widgets.
  List<Entry> entries = [];

  final TranslationMode _translationMode;
  final bool _isBookmarkedOnly;

  ValueNotifier<String> get currSearchString => _currSearchString;

  String get searchString => currSearchString.value;

  bool get isEmpty => currSearchString.value.isEmpty;

  bool get isBookmarkedOnly => _isBookmarkedOnly;


  void resetEntries() {
    entries = [];
  }

  Stream<Entry> getEntries() {
    final int startAt = entries.length;
    if (_isBookmarkedOnly) {
      return DictionaryApp.db.getBookmarked(_translationMode, startAt: startAt);
    }
    return DictionaryApp.db
        .getEntries(
      _translationMode,
      searchString: searchString,
      startAt: startAt,
    )
        .handleError(
      (Object error, StackTrace stackTrace) {
        print('ERROR (entry stream): $error\n$stackTrace');
      },
    ).map((e) {
      entries.add(e);
      return e;
    });
  }

  void onSearchStringChanged({
    required BuildContext context,
    required String newSearchString,
  }) {
    _onSearchStringChanged(context: context, newSearchString: newSearchString);
    // We also need to update the opposite model.
    DictionaryModel.instance.oppTranslationModel.searchModel.entrySearchModel
        ._onSearchStringChanged(
      context: context,
      newSearchString: newSearchString,
    );
    // Update the value notifier last.
    currSearchString.value = newSearchString;
  }

  void _onSearchStringChanged({
    required BuildContext context,
    required String newSearchString,
  }) {
    if (newSearchString == currSearchString.value) {
      // Value hasn't changed, don't update.
      return;
    }
    if (!isBigEnoughForAdvanced(context) && newSearchString.isNotEmpty) {
      DictionaryModel.instance.clearSelectedEntry(
        context,
        searchModel: DictionaryModel.instance
            .translationModelFor(_translationMode)
            .searchModel,
      );
    }
    entries = [];
    DictionaryApp.analytics.logSearch(searchTerm: newSearchString);
  }
}
