import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';

class EntryList extends StatefulWidget {
  final StreamController<List<Entry>> entriesStreamController = StreamController();

  @override
  _EntryListState createState() => _EntryListState(entriesStreamController.stream);
}

class _EntryListState extends State<EntryList> {
  Stream<List<Entry>> entriesStream;
  List<Entry> _entries = [];
  final _biggerFont = TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold);

  _EntryListState(this.entriesStream);

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    entriesStream.listen((entryLst) {
      setState(() {
        _entries = entryLst;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildEntries();
  }

  Widget _buildEntries() {
    return ListView.separated(
      padding: EdgeInsets.all(16.0),
      itemCount: _entries.length,
      itemBuilder: (context, index) {
        return _buildRow(_entries[index]);
      },
      separatorBuilder: (c, i) => Divider(),
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
