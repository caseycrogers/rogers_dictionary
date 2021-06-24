import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rogers_dictionary/dictionary_navigator/animated_listenable_switcher.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/models/search_page_model.dart';
import 'package:rogers_dictionary/models/translation_page_model.dart';
import 'package:rogers_dictionary/pages/dictionary_page.dart';
import 'package:rogers_dictionary/widgets/search_page/entry_view.dart';

import 'entry_list.dart';

class SelectedEntrySwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final SearchPageModel searchPageModel = _pageModel(context);
    return Provider<SearchPageModel>.value(
      value: searchPageModel,
      builder: (BuildContext context, _) {
        return LayoutBuilder(builder: (context, _) {
          switch (MediaQuery.of(context).orientation) {
            case Orientation.portrait:
              return _PortraitPage(searchPageModel);
            case Orientation.landscape:
              return _LandscapePage(searchPageModel);
          }
        });
      },
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

class _PortraitPage extends StatelessWidget {
  const _PortraitPage(this.searchPageModel, {Key? key}) : super(key: key);

  final SearchPageModel searchPageModel;

  @override
  Widget build(BuildContext context) {
    return AnimatedListenableSwitcher<SelectedEntry?>(
      valueListenable: searchPageModel.currSelectedEntry,
      builder: (BuildContext context, SelectedEntry? selectedEntry, _) =>
          selectedEntry != null
              ? EntryView.asPage(context)
              : const EntryList(),
    );
  }
}

class _LandscapePage extends StatelessWidget {
  const _LandscapePage(this.searchPageModel, {Key? key}) : super(key: key);

  final SearchPageModel searchPageModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Flexible(child: EntryList(), flex: 1),
        Flexible(
          flex: 2,
          child: Row(
            children: [
              const VerticalDivider(width: 1),
              Expanded(
                child: AnimatedListenableSwitcher<SelectedEntry?>(
                  valueListenable: searchPageModel.currSelectedEntry,
                  builder:
                      (BuildContext context, SelectedEntry? selectedEntry, _) =>
                          EntryView.asPage(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
