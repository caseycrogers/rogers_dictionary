import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/pages/dictionary_page.dart';
import 'package:rogers_dictionary/widgets/dictionary_bottom_navigation_bar.dart';
import 'package:rogers_dictionary/widgets/dictionary_page/entry_search.dart';
import 'package:rogers_dictionary/widgets/dictionary_page/entry_view.dart';
import 'package:rogers_dictionary/main.dart';

class EntrySearchPage extends StatelessWidget {
  EntrySearchPage();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: Material(child: _searchPages(context), elevation: 4.0)),
        DictionaryBottomNavigationBar(),
      ],
    );
  }

  Widget _searchPages(BuildContext context) {
    final dictionaryModel = DictionaryPageModel.of(context);
    final PageController controller = PageController(
      initialPage: translationModeToIndex(
          dictionaryModel.currTranslationPageModel.value.translationMode),
    );
    dictionaryModel.currTranslationPageModel.addListener(() {
      var targetPage = translationModeToIndex(
          dictionaryModel.currTranslationPageModel.value.translationMode);
      // If the controller isn't attached yet then the PageView will be properly
      // constructed via initialPage.
      if (!controller.hasClients || controller.page.round() == targetPage)
        return;
      controller.animateToPage(
        targetPage,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeIn,
      );
    });
    return PageView(
      allowImplicitScrolling: true,
      controller: controller,
      onPageChanged: (index) => DictionaryPageModel.readFrom(context)
          .onTranslationModeChanged(indexToTranslationMode(index)),
      children: [
        Theme(
          data: Theme.of(context)
              .copyWith(primaryColor: primaryColor(TranslationMode.English)),
          child: Provider<SearchPageModel>.value(
            value: _pageModel(context, dictionaryModel.englishPageModel),
            builder: (context, _) => _buildOrientedPage(context, EntrySearch()),
          ),
        ),
        Theme(
          data: Theme.of(context)
              .copyWith(primaryColor: primaryColor(TranslationMode.Spanish)),
          child: Provider<SearchPageModel>.value(
            value: _pageModel(context, dictionaryModel.spanishPageModel),
            builder: (context, _) => _buildOrientedPage(context, EntrySearch()),
          ),
        ),
      ],
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
