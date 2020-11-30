import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rogers_dictionary/dictionary/search_bar.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/models/search_string_model.dart';

import 'entry_list.dart';

class EntrySearch extends StatelessWidget {
  static const String route = '/';

  @override
  Widget build(BuildContext context) {
    var initialModel = DictionaryPageModel.of(context).searchStringModel;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ChangeNotifierProvider<SearchStringModel>.value(
        value: initialModel,
        builder: (context, child) {
          return Column(children: [
              SearchBar(initialModel.value),
              Expanded(
                child: Consumer<SearchStringModel> (
                  builder: (context, searchStringModel, child) => EntryList(searchStringModel.value),
                ),
              ),
            ]);
        },
      ),
    );
  }
}
