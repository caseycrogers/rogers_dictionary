import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rogers_dictionary/dictionary_navigator/animated_listenable_switcher.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/pages/dictionary_page.dart';
import 'package:rogers_dictionary/widgets/dictionary_page/entry_view.dart';

import 'dictionary_page/entry_search.dart';

class EntrySearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final searchPageModel = _pageModel(context);
    return Provider<SearchPageModel>.value(
      value: searchPageModel,
      builder: (context, _) => AnimatedListenableSwitcher(
        valueListenable: searchPageModel.currSelectedEntry,
        builder: (BuildContext context, SelectedEntry selectedEntry, _) =>
            selectedEntry.hasSelection
                ? EntryView.asPage(context)
                : EntrySearch(),
      ),
    );
  }

  SearchPageModel _pageModel(BuildContext context) {
    var t = TranslationPageModel.of(context);
    return DictionaryPageModel.of(context).currentTab.value ==
            DictionaryTab.search
        ? t.searchPageModel
        : t.favoritesPageModel;
  }
}
