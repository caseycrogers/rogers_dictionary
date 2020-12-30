import 'package:flutter/material.dart';

import 'entry_list.dart';
import 'search_bar.dart';

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
