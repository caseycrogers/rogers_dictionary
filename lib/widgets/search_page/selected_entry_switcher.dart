import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rogers_dictionary/dictionary_navigator/animated_listenable_switcher.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/models/search_page_model.dart';
import 'package:rogers_dictionary/models/translation_page_model.dart';
import 'package:rogers_dictionary/pages/dictionary_page.dart';
import 'package:rogers_dictionary/widgets/search_page/entry_view.dart';
import 'package:rogers_dictionary/widgets/search_page/entry_search.dart';

class SelectedEntrySwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final SearchPageModel searchPageModel = _pageModel(context);
    return Provider<SearchPageModel>.value(
      value: searchPageModel,
      builder: (BuildContext context, _) =>
          AnimatedListenableSwitcher<SelectedEntry?>(
        valueListenable: searchPageModel.currSelectedEntry,
        builder: (BuildContext context, SelectedEntry? selectedEntry, _) =>
            selectedEntry != null
                ? EntryView.asPage(context)
                : const EntrySearch(),
      ),
    );
  }

  SearchPageModel _pageModel(BuildContext context) {
    final TranslationPageModel t = TranslationPageModel.of(context);
    return DictionaryPageModel.of(context).currentTab.value ==
            DictionaryTab.search
        ? t.searchPageModel
        : t.favoritesPageModel;
  }
}
