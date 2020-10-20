
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/dictionary/entry_list.dart';
import 'package:rogers_dictionary/dictionary/search_bar.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';
import 'package:rogers_dictionary/main.dart';

class DictionaryPage extends StatelessWidget {
  final SearchBar searchBar = SearchBar();
  final EntryList entryList = EntryList();
  String _currText = '';
  Stream<Entry> _currEntryStream;

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
    var prev = _currText;
    _currText = searchBar.filter.text;
    // Don't send an event if the text hasn't changed
    if (_currText == prev) return;
    _currText = searchBar.filter.text;
    entryList.entryStreamStreamController.add(
        MyApp.db.getEntries(searchString: _currText)
    );
  }
}
