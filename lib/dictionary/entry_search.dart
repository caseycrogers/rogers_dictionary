import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rogers_dictionary/dictionary/search_bar.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';

import 'entry_list.dart';

class EntrySearch extends StatelessWidget {
  static const String route = '/';

  @override
  Widget build(BuildContext context) {
    DictionaryPageModel pageModel = DictionaryPageModel.of(context);
    SearchStringModel initialModel = pageModel.searchStringModel;
    return Column(children: [
      SearchBar(),
      Expanded(
        child: ChangeNotifierProvider.value(
          value: initialModel,
          child: EntryList(),
        ),
      ),
    ]);
  }
}
