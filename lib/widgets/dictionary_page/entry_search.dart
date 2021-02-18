import 'package:flutter/material.dart';

import 'entry_list.dart';
import 'search_bar.dart';
import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/models/search_page_model.dart';

class EntrySearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      verticalDirection: VerticalDirection.up,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: EntryList(),
        ),
        Material(
          elevation: 4.0,
          color: primaryColor(SearchPageModel.of(context).translationMode),
          child: SearchBar(),
        ),
      ],
    );
  }
}
