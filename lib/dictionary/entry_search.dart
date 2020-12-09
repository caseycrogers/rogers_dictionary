import 'package:flutter/material.dart';
import 'package:rogers_dictionary/dictionary/search_bar.dart';

import 'entry_list.dart';

class EntrySearch extends StatelessWidget {
  static const String route = '/';

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SearchBar(),
      Expanded(
        child: EntryList(),
      ),
    ]);
  }
}
