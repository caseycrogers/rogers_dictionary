import 'dart:collection';

import 'package:flutter/material.dart';

import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/models/translation_page_model.dart';
import 'package:rogers_dictionary/pages/about_page.dart';
import 'package:rogers_dictionary/pages/dialogues_page.dart';
import 'package:rogers_dictionary/widgets/dictionary_tab_bar_view.dart';
import 'package:rogers_dictionary/widgets/dictionary_tab_entry.dart';
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
    var dictionaryModel = DictionaryPageModel.of(context);
    return ValueListenableBuilder<TranslationPageModel>(
      valueListenable: dictionaryModel.currTranslationPageModel,
      child: DictionaryTabBarView(
        children: LinkedHashMap.from({
          DictionaryTab.search: SearchPage(),
          DictionaryTab.favorites: FavoritesPage(),
          DictionaryTab.dialogues: DialoguesPage(),
          DictionaryTab.about: AboutPage(),
          DictionaryTab.settings: Container(color: Colors.green),
        }),
      ),
      builder: (context, currSearchPage, dictionaryTabView) => Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: primaryColor(currSearchPage.translationMode),
          elevation: 0.0,
          automaticallyImplyLeading: false,
          title: TabBar(
            tabs: [
              DictionaryTabEntry(
                  selected:
                      Text('Dictionary', style: TextStyle(fontSize: 24.0)),
                  unselected: Text('AZ', style: TextStyle(fontSize: 24.0)),
                  index: 0),
              DictionaryTabEntry(
                  selected: Text('Favorites', style: TextStyle(fontSize: 24.0)),
                  unselected: Icon(Icons.star, size: 26.0),
                  index: 1),
              DictionaryTabEntry(
                  selected: Text('Dialogues', style: TextStyle(fontSize: 24.0)),
                  unselected: Icon(Icons.message, size: 26.0),
                  index: 2),
              DictionaryTabEntry(
                  selected: Text('About', style: TextStyle(fontSize: 24.0)),
                  unselected: Icon(Icons.info, size: 26.0),
                  index: 3),
              DictionaryTabEntry(
                  selected: Text('Settings', style: TextStyle(fontSize: 24.0)),
                  unselected: Icon(Icons.settings, size: 26.0),
                  index: 4),
            ],
            isScrollable: true,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                color: Colors.white,
                width: 3.0,
              ),
              insets: EdgeInsets.symmetric(horizontal: 8.0),
            ),
          ),
        ),
        body: Column(
          verticalDirection: VerticalDirection.up,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: dictionaryTabView),
          ],
        ),
      ),
    );
  }
}
