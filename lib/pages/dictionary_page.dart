import 'package:flutter/material.dart';

import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/widgets/dictionary_tab_bar_view.dart';
import 'package:rogers_dictionary/widgets/dictionary_tab.dart';
import 'favorites_page.dart';
import 'search_page.dart';

class DictionaryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var dictionaryModel = DictionaryPageModel.of(context);
    return ValueListenableBuilder<SearchPageModel>(
      valueListenable: dictionaryModel.currSearchPageModel,
      child: DictionaryTabBarView(
        children: [
          SearchPage(),
          FavoritesPage(),
          Container(color: Colors.orange),
          Container(color: Colors.yellow),
          Container(color: Colors.green),
        ],
      ),
      builder: (context, currSearchPage, child) => Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            verticalDirection: VerticalDirection.up,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: child),
              Material(
                color: primaryColor(currSearchPage.translationMode),
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    stops: [0.0, 0.05, 0.95, 1.0],
                    colors: [
                      primaryColor(currSearchPage.translationMode)
                          .withOpacity(0.0),
                      primaryColor(currSearchPage.translationMode),
                      primaryColor(currSearchPage.translationMode),
                      primaryColor(currSearchPage.translationMode)
                          .withOpacity(0.0),
                    ],
                  ).createShader(bounds),
                  blendMode: BlendMode.dstATop,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
                    child: TabBar(
                      tabs: [
                        DictionaryTab(
                            selected: Text('Dictionary',
                                style: TextStyle(fontSize: 24.0)),
                            unselected:
                                Text('AZ', style: TextStyle(fontSize: 24.0)),
                            index: 0),
                        DictionaryTab(
                            selected: Text('Favorites',
                                style: TextStyle(fontSize: 24.0)),
                            unselected: Icon(Icons.star, size: 26.0),
                            index: 1),
                        DictionaryTab(
                            selected: Text('Dialogue',
                                style: TextStyle(fontSize: 24.0)),
                            unselected: Icon(Icons.message, size: 26.0),
                            index: 2),
                        DictionaryTab(
                            selected:
                                Text('About', style: TextStyle(fontSize: 24.0)),
                            unselected: Icon(Icons.info, size: 26.0),
                            index: 3),
                        DictionaryTab(
                            selected: Text('Settings',
                                style: TextStyle(fontSize: 24.0)),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
