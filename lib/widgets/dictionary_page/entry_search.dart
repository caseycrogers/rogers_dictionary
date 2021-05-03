import 'package:flutter/material.dart';
import 'package:rogers_dictionary/pages/dictionary_page.dart';

import 'entry_list.dart';
import 'search_bar.dart';
import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/models/search_page_model.dart';

class EntrySearch extends StatelessWidget {
  EntrySearch({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      verticalDirection: VerticalDirection.up,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: EntryList(),
        ),
        if (DictionaryPageModel.of(context).currentTab.value ==
            DictionaryTab.search)
          Material(
            elevation: 4.0,
            color: primaryColor(SearchPageModel.of(context).translationMode),
            child: SearchBar(),
          ),
      ],
    );
  }
}
