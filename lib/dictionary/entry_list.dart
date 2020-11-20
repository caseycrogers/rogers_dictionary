import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';
import 'file:///C:/Users/Waffl/Documents/code/rogers_dictionary/lib/widgets/loading_text.dart';
import 'dart:core';

import 'package:rogers_dictionary/widgets/entry_widget.dart';

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
  bool hasSeenData = false;

  _EntryListState(this._entryStream);

  void initStream() {
    _entryStreamSubscription?.cancel();
    _entryStreamController?.close();

    _entryStreamController = StreamController();
    _entryStreamSubscription = widget._entryStream.listen((event) {
      _entryStreamController.add(event);
    })..onDone(() => _entryStreamController.close());
    // Start with the stream paused
    _pauseStream();
    hasSeenData = false;
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
            return _buildEntries(entriesSnap.data, entriesSnap.connectionState);
          }
        );
      }

  Widget _buildEntries(List<Entry> entries, ConnectionState state) {
    return ListView.separated(
      padding: EdgeInsets.all(16.0),
      itemCount: state == ConnectionState.done ? entries.length : entries.length + 1,
      itemBuilder: (context, index) {
        if (state == ConnectionState.waiting || index > entries.length - 5) {
          _resumeStream();
        } else {
          _pauseStream();
        }
        if (index == entries.length) return LoadingText();
        // resume the stream if we're within 5 entries of the end of the list
        return _buildRow(entries[index]);
      },
      separatorBuilder: (c, i) => Divider(),
    );
  }

  Widget _buildRow(Entry entry) {
    return EntryWidget(entry);
  }

  void _pauseStream() {
    if (!_entryStreamSubscription.isPaused) _entryStreamSubscription.pause();
  }

  void _resumeStream() {
    if (_entryStreamSubscription.isPaused) _entryStreamSubscription.resume();
  }
}
