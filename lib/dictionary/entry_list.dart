import 'dart:async';

import "package:collection/collection.dart";
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';
import 'package:rogers_dictionary/util/default_map.dart';
import 'package:rogers_dictionary/util/loading_text.dart';
import 'dart:core';

class EntryList extends StatefulWidget {
  final Stream<List<Entry>> _entryStream;

  @override
  _EntryListState createState() => _EntryListState(_entryStream);

  EntryList(this._entryStream);
}

class _EntryListState extends State<EntryList> {
  final _biggerFont = TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold);
  final StreamController<List<Entry>> _entryStreamController = StreamController();
  final Stream<List<Entry>> _entryStream;
  StreamSubscription<List<Entry>> _entryStreamSubscription;

  _EntryListState(this._entryStream);

  @override
  void initState() {
    _entryStreamSubscription = _entryStream.listen((event) {
        _entryStreamController.add(event);
      }
    );

    super.initState();
  }

  @override
  void dispose() {
    _entryStreamController.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
          initialData: List<Entry>(),
          stream: _entryStreamController.stream,
          builder: (_, entriesSnap) {
            return _buildEntries(entriesSnap.data, entriesSnap.connectionState == ConnectionState.done);
          }
        );
      }

  Widget _buildEntries(List<Entry> entries, bool isDone) {
    return ListView.separated(
      padding: EdgeInsets.all(16.0),
      itemCount: isDone ? entries.length : entries.length + 1,
      itemBuilder: (context, index) {
        if (index == entries.length) return LoadingText();
        return _buildRow(entries[index]);
      },
      separatorBuilder: (c, i) => Divider(),
    );
  }

  Widget _buildRow(Entry entry) {
    // {meaningId: {partOfSpeech: [translation]}}
    Map<String, Map<String, List<Translation>>> translationMap = {};
    entry.translations.forEach((t) =>
        translationMap.getOrElse(t.meaningId, {}).getOrElse(t.partOfSpeech, []).add(t));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              entry.headword,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: _biggerFont,
            ),
          ],
        ),
        Column(
          children: [
            Row(
                children: groupBy(
                    entry.translations,
                        (t) => t.partOfSpeech).map(
                        (partOfSpeech, translations) =>
                        MapEntry(
                            partOfSpeech,
                            Row(
                                children: [
                                  Text(partOfSpeech + ':'),
                                  SizedBox(width: 10),
                                  Column(
                                      children: translations.map((t) => Text(t.translation)).toList(),
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                  )
                                ],
                              crossAxisAlignment: CrossAxisAlignment.start,
                            )
                        )
                ).values.toList()
            ),
          ],
        ),
      ],
    );
  }
}
