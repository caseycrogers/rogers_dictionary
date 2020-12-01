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
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [BoxShadow(
            color: Colors.grey.withOpacity(.5),
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(0, 2),
          )]),
      child: Column(children: [
        SearchBar(),
        Expanded(
          child: ChangeNotifierProvider.value(
            value: initialModel,
            child: EntryList(),
          ),
        ),
      ]),
    );
  }
}
