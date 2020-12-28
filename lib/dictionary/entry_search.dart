import 'package:flutter/material.dart';
import 'package:rogers_dictionary/dictionary/search_bar.dart';

import 'entry_list.dart';

class EntrySearch extends StatelessWidget {
  static const String route = '/';
  @override
  Key get key => PageStorageKey('ENTRY_SEARCH_KEY');

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SearchBar(),
        Expanded(
          child: EntryList(),
        ),
      ],
    );
  }
}
