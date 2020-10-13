import 'dart:async';
import 'dart:math';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/util/widgets.dart';

import 'entry_database/entry.dart';

class EntryList extends StatefulWidget {
  @override
  _EntryListState createState() => _EntryListState();

  EntryList();
}

class _EntryListState extends State<EntryList> {
  StreamQueue<Entry> _entryStream = MyApp.db.getEntries();
  final List<Future<Entry>> _entries = List();
  final _biggerFont = TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold);
  Future<Widget> _entryListView;

  @override
  void initState() {
    _entryListView = _buildEntries();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dictionary'),
      ),
      body: FutureBuilder(
        builder: (context, snap) {
          if (snap.hasData) return snap.data;
          if (snap.connectionState == ConnectionState.none && !snap.hasData) return loadingWidget();
          return Container();
        },
        future: _entryListView,
      ),
    );
  }

  Future<Widget> _buildEntries() async {
    var size = await MyApp.db.getEntriesSize();
    return ListView.separated(
      padding: EdgeInsets.all(16.0),
      itemBuilder: (context, index) {
        if (index + 2 >= _entries.length) {
          // Add elements to the list
          for (var j = _entries.length; j < min(index + 4, size); j++) {
            _entries.add(_entryStream.next);
          }
        }
        return FutureBuilder(
          builder: (context, entrySnap) {
            if (entrySnap.hasData) return _buildRow(entrySnap.data);
            print("no data ):");
            return Container();
          },
          future: _entries[index],
        );
      },
      separatorBuilder: (c, i) => Divider(),
      itemCount: size,
    );
  }

  Widget _buildRow(Entry entry) {
    return ListTile(
      title: Text(
        entry.article,
        style: _biggerFont,
      ),
      subtitle: Text(entry.translations.join(", ")),
    );
  }
}