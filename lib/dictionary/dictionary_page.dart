
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/dictionary/entry_list.dart';
import 'package:rogers_dictionary/dictionary/search_bar.dart';
import 'package:rogers_dictionary/main.dart';

class DictionaryPage extends StatelessWidget {
  final SearchBar searchBar = SearchBar();
  final EntryList entryList = EntryList();

  @override
  Widget build(BuildContext context) {
    searchBar.filter.addListener(_sendEntries);
    _sendEntries();

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

  void _sendEntries() {
    MyApp.db.getEntries(searchString: searchBar.filter.text).then((entries) {
      entryList.entriesStreamController.add(entries);
    });
  }
}
