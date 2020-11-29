import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rogers_dictionary/dictionary/search_bar.dart';
import 'package:rogers_dictionary/dictionary/search_string_model.dart';

import 'entry_list.dart';

class EntrySearch extends StatelessWidget {
  static const String route = '/';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ChangeNotifierProvider(
        create: (context) => SearchStringModel(),
        builder: (context, child) {
          return Column(children: [
              SearchBar(),
              Expanded(
                child: Consumer<SearchStringModel> (
                  builder: (context, searchStringModel, child) => EntryList(searchStringModel.searchString),
                ),
              ),
            ]);
        },
      ),
    );
  }
}
