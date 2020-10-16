import 'package:flutter/material.dart';
import 'package:rogers_dictionary/dictionary/entry_list.dart';
import 'package:rogers_dictionary/dictionary/search_bar.dart';

class DictionaryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var searchBar = SearchBar();
    var entryList = EntryList();
    searchBar.filter.addListener(() {
      entryList.searchStreamController.add(searchBar.filter.text);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Dictionary'),
      ),
      body: Column(children: [
        searchBar,
        Flexible(child: entryList),
      ]),
    );
  }
}
