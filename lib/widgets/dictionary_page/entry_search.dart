import 'package:flutter/material.dart';

import 'entry_list.dart';
import 'search_bar.dart';

class EntrySearch extends StatelessWidget {
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
