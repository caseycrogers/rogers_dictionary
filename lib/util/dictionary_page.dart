import 'package:flutter/material.dart';

import 'dictionary_tab_bar.dart';
import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/models/search_page_model.dart';

class DictionaryPage extends StatelessWidget {
  final Widget child;

  DictionaryPage({this.child});

  @override
  Widget build(BuildContext context) {
    var bilingualSearchPage = BilingualSearchPageModel.of(context);
    return ValueListenableBuilder<SearchPageModel>(
      valueListenable: bilingualSearchPage.currSearchPageModel,
      child: child,
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
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
                        child: TabBar(
                          tabs: [
                            Text('Dictionary',
                                style: TextStyle(fontSize: 24.0)),
                            Text('Favorites', style: TextStyle(fontSize: 24.0)),
                            Text('Dialogue', style: TextStyle(fontSize: 24.0)),
                          ],
                          isScrollable: true,
                          indicator: UnderlineTabIndicator(
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 3.0,
                            ),
                            insets: EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.info, size: 24.0),
                            onPressed: () {},
                            visualDensity: VisualDensity.comfortable,
                          ),
                          IconButton(
                            icon: Icon(Icons.settings, size: 24.0),
                            onPressed: () {},
                            visualDensity: VisualDensity.comfortable,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tab({Widget active}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.0),
      child: active,
    );
  }
}
