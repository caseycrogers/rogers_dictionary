import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/models/translation_page_model.dart';
import 'package:rogers_dictionary/pages/dialogues_page.dart';
import 'package:rogers_dictionary/util/constants.dart';
import 'package:rogers_dictionary/util/on_first_launch.dart';
import 'package:rogers_dictionary/util/swipe_tutorial.dart';
import 'package:rogers_dictionary/widgets/dictionary_page/dictionary_tab_bar_view.dart';
import 'package:rogers_dictionary/widgets/dictionary_page/dictionary_tab_entry.dart';
import 'package:rogers_dictionary/widgets/dictionary_page/dictionary_top_bar.dart';
import 'favorites_page.dart';
import 'search_page.dart';

enum DictionaryTab {
  search,
  favorites,
  dialogues,
  about,
  settings,
}

String dictionaryTabName(DictionaryTab dictionaryTab) =>
    dictionaryTab.toString().split('.').last;

class DictionaryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final DictionaryPageModel dictionaryModel = DictionaryPageModel.of(context);
    return Scaffold(
      body: ValueListenableBuilder<TranslationPageModel>(
        valueListenable: dictionaryModel.translationPageModel,
        child: DictionaryTabBarView(
          children: LinkedHashMap.from(<DictionaryTab, Widget>{
            DictionaryTab.search: SearchPage(),
            DictionaryTab.favorites: FavoritesPage(),
            DictionaryTab.dialogues: DialoguesPage(),
          }),
        ),
        builder: (context, currSearchPage, dictionaryTabView) => Container(
          color: primaryColor(currSearchPage.translationMode),
          child: DictionaryTopBar(
            controller: dictionaryModel.topBarController,
            child: Column(
              children: [
                Expanded(child: dictionaryTabView!),
                Material(
                  color: primaryColor(currSearchPage.translationMode),
                  elevation: kGroundElevation,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: kPad),
                    child: Column(
                      children: [
                        TabBar(
                          labelPadding: const EdgeInsets.all(kPad)
                              .add(const EdgeInsets.only(bottom: kPad)),
                          indicatorPadding:
                              const EdgeInsets.only(bottom: 2 * kPad - 4),
                          tabs: const [
                            DictionaryTabEntry(
                                selected: Text('Dictionary',
                                    style: TextStyle(fontSize: 24)),
                                unselected: Text('Dictionary',
                                    style: TextStyle(fontSize: 24)),
                                index: 0),
                            DictionaryTabEntry(
                                selected: Text('Favorites',
                                    style: TextStyle(fontSize: 24)),
                                unselected: Text('Favorites',
                                    style: TextStyle(fontSize: 24)),
                                index: 1),
                            DictionaryTabEntry(
                                selected: Text('Dialogues',
                                    style: TextStyle(fontSize: 24)),
                                unselected: Text('Dialogues',
                                    style: TextStyle(fontSize: 24)),
                                index: 2),
                          ],
                          isScrollable: true,
                          indicator: const UnderlineTabIndicator(
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 3,
                            ),
                            insets: EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
