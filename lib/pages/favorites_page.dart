import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'file:///C:/Users/Waffl/Documents/code/rogers_dictionary/lib/widgets/entry_search_page.dart';
import 'package:rogers_dictionary/widgets/top_shadow.dart';

class FavoritesPage extends StatelessWidget {
  static const route = 'favorites';

  static bool matchesUri(Uri uri) => uri.pathSegments.contains(route);

  @override
  Widget build(BuildContext context) {
    // Reset to catch any new favorites that have been added
    DictionaryPageModel.of(context)
        .englishPageModel
        .favoritesPageModel
        .entrySearchModel
        .resetStream();
    DictionaryPageModel.of(context)
        .spanishPageModel
        .favoritesPageModel
        .entrySearchModel
        .resetStream();
    return Builder(builder: (context) => TopShadow(child: EntrySearchPage()));
  }
}
