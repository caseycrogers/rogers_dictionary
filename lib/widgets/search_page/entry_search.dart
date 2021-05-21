import 'package:flutter/material.dart';
import 'package:rogers_dictionary/pages/dictionary_page.dart';
import 'package:rogers_dictionary/util/constants.dart';

import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/models/search_page_model.dart';

import 'entry_list.dart';
import 'search_bar.dart';

class EntrySearch extends StatelessWidget {
  const EntrySearch({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (DictionaryPageModel.of(context).currentTab.value ==
            DictionaryTab.search)
          Material(
            elevation: kGroundElevation,
            color: primaryColor(SearchPageModel.of(context).translationMode),
            child: SearchBar(),
          ),
        Expanded(
          child: EntryList(),
        ),
      ],
    );
  }
}
