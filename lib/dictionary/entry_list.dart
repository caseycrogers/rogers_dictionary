import 'dart:async';
import 'dart:math';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';
import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/util/widgets.dart';

class EntryList extends StatefulWidget {
  final StreamController<String> searchStreamController = StreamController();

  @override
  _EntryListState createState() => _EntryListState(searchStreamController.stream);
}

class _EntryListState extends State<EntryList> {
  StreamQueue<Entry> _entryStream;
  final List<Future<Entry>> _entries = [];
  final _biggerFont = TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold);
  Future<Widget> _entryListView;
  Stream<String> _searchStream;

  _EntryListState(this._searchStream);

  @override
  void dispose() {
    super.dispose();
  }

  void _reset({String searchString = ''}) {
    _entries.clear();
    _entryStream = MyApp.db.getEntries(searchString: searchString);
    _entryListView = _buildEntries();
  }

  @override
  void initState() {
    _reset();
    for ( var i = 0; i < 5; i++ ) _entries.add(_entryStream.next);
    _searchStream.listen((str) {
      setState(() => _reset(searchString: str));
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, snap) {
        if (snap.hasData) return snap.data;
        if (snap.connectionState == ConnectionState.none && !snap.hasData) return loadingWidget();
        return Container();
      },
      future: _entryListView,
    );
  }

  Future<Widget> _buildEntries() async {
    return ListView.builder(
      padding: EdgeInsets.all(16.0),
      itemBuilder: (context, index) {
        if (index % 2 == 0) return Divider();
        var i = index ~/2;
        if (i + 5 >= _entries.length) {
          // Add elements to the list
          for (var j = _entries.length; j < i + 10; j++) {
            _entries.add(_entryStream.next);
          }
        }
        return FutureBuilder(
          builder: (context, entrySnap) {
            if (entrySnap.hasData) return _buildRow(entrySnap.data);
            return Container();
          },
          future: _entries[i],
        );
      },
    );
  }

  Widget _buildRow(Entry entry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
                entry.article,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: _biggerFont),
            Text(
              ' ' + entry.partsOfSpeech.join(' & '),
              style: TextStyle(fontStyle: FontStyle.italic),
            )
          ],
        ),
        Text(
          entry.translations.join(', '),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }
}
