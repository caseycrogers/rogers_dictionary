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
    return ChangeNotifierProvider(
      create: (context) => SearchStringModel(),
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Dictionary'),
          ),
          body: Column(children: [
            SearchBar(),
            Flexible(
              child: Consumer<SearchStringModel> (
                builder: (context, searchStringModel, child) => EntryList(_getEntries(searchStringModel.searchString)),
              ),
            ),
          ]),
        );
      },
    );
  }

  Stream<List<Entry>> _getEntries(String searchString) =>
      _cumulativeReduce(MyApp.db.getEntries(searchString: searchString));

  Stream<List<Entry>> _cumulativeReduce(Stream<Entry> stream) {
    var soFar = [];
    return stream.map((e) => List.from(soFar..add(e)));
  }
}
