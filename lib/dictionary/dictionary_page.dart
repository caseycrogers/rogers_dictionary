import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rogers_dictionary/dictionary/search_bar.dart';
import 'package:rogers_dictionary/dictionary/search_string_model.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';
import 'package:rogers_dictionary/main.dart';

import 'entry_list.dart';

class DictionaryPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    SearchBar searchBar = SearchBar();
    bool listened = false;
    return ChangeNotifierProvider(
      create: (context) => SearchStringModel(),
      builder: (context, child) {
        // Add a listener to the search bar from within the notifier provider
        if (!listened) searchBar.textEditingController.addListener(() {
          listened = true;
          context.read<SearchStringModel>().updateSearchString(searchBar.textEditingController.text);
        });

        return Scaffold(
          appBar: AppBar(
            title: Text('Dictionary'),
          ),
          body: Column(children: [
            searchBar,
            Flexible(
              child: Selector<SearchStringModel, String>(
                selector: (context, searchStringModel) => searchStringModel.text,
                builder: (context, searchString, child) {
                  return EntryList(_cumulativeReduce(MyApp.db.getEntries(searchString: searchString)));
                },
              ),
            ),
          ]),
        );
      },
    );
  }

  Stream<List<Entry>> _cumulativeReduce(Stream<Entry> stream) {
    var soFar = [];
    return stream.map((e) => List.from(soFar..add(e)));
  }
}
