import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:rogers_dictionary/util/LoadingText.dart';

class EntryList extends StatefulWidget {
  final StreamController<Stream<Entry>> entryStreamStreamController = StreamController();

  @override
  _EntryListState createState() => _EntryListState(entryStreamStreamController.stream);
}

class _EntryListState extends State<EntryList> {
  Stream<Stream<Entry>> entryStreamStream;
  List<Entry> _entries = [];
  bool _loading = true;
  // Initialize with empty stream to simplify init logic
  StreamSubscription<Entry> _subscriber = StreamController<Entry>().stream.listen((_) { });
  final _biggerFont = TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold);

  _EntryListState(this.entryStreamStream);

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    entryStreamStream.listen((entryStream) {
      _subscriber.cancel().then((_) {
        var lst = List<Entry>();
        _entries = lst;
        setState(() {
          print('loading');
          _loading = true;
        });
        _subscriber = entryStream.listen(
                (entry) {
              setState(() {
                lst.add(entry);
              });
            },
            onDone: () => setState(() {
              print('done');
              _loading = false;
            }));
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
      itemCount: _loading ? _entries.length + 1 : _entries.length,
      itemBuilder: (context, index) {
        if (index == _entries.length) return LoadingText();
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
