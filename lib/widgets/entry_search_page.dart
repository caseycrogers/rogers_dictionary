import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/pages/dictionary_page.dart';
import 'package:rogers_dictionary/widgets/dictionary_page/entry_search.dart';
import 'package:rogers_dictionary/widgets/dictionary_page/entry_view.dart';
import 'package:rogers_dictionary/widgets/translation_mode_switcher.dart';

class EntrySearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dictionaryModel = DictionaryPageModel.of(context);
    return TranslationModeSwitcher(
      englishChild: Provider<SearchPageModel>.value(
        value: _pageModel(context, dictionaryModel.englishPageModel),
        builder: (context, _) => _buildOrientedPage(context, EntrySearch()),
      ),
      spanishChild: Provider<SearchPageModel>.value(
        value: _pageModel(context, dictionaryModel.spanishPageModel),
        builder: (context, _) => _buildOrientedPage(context, EntrySearch()),
      ),
    );
  }

  Widget _buildOrientedPage(BuildContext context, EntrySearch entrySearch) {
    final searchPageModel = SearchPageModel.of(context);

    Widget _getTransition(Widget child, Animation<double> animation) =>
        FadeTransition(child: child, opacity: animation);

    return LayoutBuilder(
      builder: (context, constraints) => ValueListenableBuilder<SelectedEntry>(
        valueListenable: searchPageModel.currSelectedEntry,
        builder: (context, selectedEntry, _) => AnimatedSwitcher(
          transitionBuilder: _getTransition,
          duration: Duration(milliseconds: 200),
          reverseDuration: Duration(milliseconds: 100),
          child: selectedEntry.hasSelection
              ? EntryView.asPage(context)
              : EntrySearch(),
        ),
      ),
    );
  }

  SearchPageModel _pageModel(BuildContext context, TranslationPageModel t) {
    return DictionaryPageModel.of(context).currentTab.value ==
            DictionaryTab.search
        ? t.searchPageModel
        : t.favoritesPageModel;
  }
}
