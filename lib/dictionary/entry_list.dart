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
  Stream<List<Entry>> _entryStream;
  StreamController<List<Entry>> _entryStreamController;
  StreamSubscription<List<Entry>> _entryStreamSubscription;

  _EntryListState(this._entryStream);

  void initStream() {
    _entryStreamSubscription?.cancel();
    _entryStreamController?.close();

    _entryStreamController = StreamController();
    _entryStreamSubscription = widget._entryStream.listen((event) {
      _entryStreamController.add(event);
    }
    )..onDone(() => _entryStreamController.close());
  }

  @override
  void initState() {
    super.initState();
    initStream();
  }

  @override
  void dispose() {
    super.dispose();
    _entryStreamSubscription?.cancel();
    _entryStreamController?.close();
  }

  @override
  void didUpdateWidget(EntryList oldEntryList) {
    super.didUpdateWidget(oldEntryList);
    // Initialize the stream only if it has changed
    if (_entryStream != widget._entryStream) {
      _entryStream = widget._entryStream;
      initStream();
    }
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
        // if (index > entries.length - 5 && _entryStreamSubscription.isPaused) _entryStreamSubscription.resume();
        // if (index <= entries.length - 5 && !_entryStreamSubscription.isPaused) _entryStreamSubscription.pause();
        return _buildRow(entries[index]);
      },
      separatorBuilder: (c, i) => Divider(),
    );
  }

  Widget _buildRow(Entry entry) {
    // Schema:
    // {meaningId: {partOfSpeech: [translation]}}
    Map<String, Map<String, List<Translation>>> translationMap = {};
    entry.translations.forEach((t) =>
        translationMap.getOrElse(t.meaningId, {}).getOrElse(t.partOfSpeech, []).add(t));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            entry.headword,
            overflow: TextOverflow.ellipsis,
            maxLines: 1
        ),
        Column(
          children: [
            Row(
              children: groupBy(entry.translations, (t) => t.partOfSpeech).values
                  .map(_buildTranslations).toList(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTranslations(List<Translation> translations) {
    String partOfSpeech = translations.first.partOfSpeech;
    return Row(
      children: [
        Text(partOfSpeech + ':'),
        SizedBox(width: 10),
        Column(
          children: translations.map((t) => Text(t.translation)).toList(),
          crossAxisAlignment: CrossAxisAlignment.start,
        )
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }
}
