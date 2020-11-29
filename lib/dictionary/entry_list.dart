import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';
import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/util/focus_utils.dart';
import 'package:rogers_dictionary/widgets/loading_text.dart';
import 'dart:core';

import 'package:rogers_dictionary/widgets/entry_page.dart';
import 'package:stream_summary_builder/stream_summary_builder.dart';

class EntryList extends StatefulWidget {
  final String _searchString;

  @override
  _EntryListState createState() => _EntryListState();

  EntryList(this._searchString);
}

class _EntryListState extends State<EntryList> {
  StreamController<Entry> _entryStreamController;
  StreamSubscription<Entry> _entryStreamSubscription;
  bool hasSeenData = false;

  ScrollController _scrollController;

  _EntryListState();

  void initEntryList() {
    var entryStream = MyApp.db.getEntries(searchString: widget._searchString);
    _entryStreamSubscription?.cancel();
    _entryStreamController?.close();

    _entryStreamController = StreamController();
    _entryStreamSubscription = entryStream.listen((event) {
      _entryStreamController.add(event);
    })..onDone(() => _entryStreamController.close());
    // Start with the stream paused
    _pauseStream();
    hasSeenData = false;

    _scrollController?.removeListener(_scrollListener);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void initState() {
    super.initState();
    initEntryList();
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
    // Initialize the stream only if the search string has changed
    if (oldEntryList._searchString != widget._searchString) {
      initEntryList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamSummaryBuilder<Entry, List<Entry>>(
          initialData: List<Entry>(),
          stream: _entryStreamController.stream,
          fold: (summary, value) => List.from(summary)..add(value),
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
        if (index == entries.length) return Container(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: LoadingText(),
        );
        // resume the stream if we're within 5 entries of the end of the list
        return _buildRow(entries[index]);
      },
      separatorBuilder: (c, i) => Divider(
        thickness: 1,
        height: 1,
      ),
      controller: _scrollController,
    );
  }

  Widget _buildRow(Entry entry) {
    return InkWell(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(child: EntryPage.asPreview(entry)),
              Icon(
                Icons.arrow_forward_ios_outlined,
                color: Theme.of(context).accentIconTheme.color,
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          ),
        ),
        onTap: () {
          Navigator.of(context).pushNamed(
            EntryPage.route + '/${entry.urlEncodedHeadword}',
          );
        }
    );
  }

  void _pauseStream() {
    if (!_entryStreamSubscription.isPaused) _entryStreamSubscription.pause();
  }

  void _resumeStream() {
    if (_entryStreamSubscription.isPaused) _entryStreamSubscription.resume();
  }

  void _scrollListener() {
   unFocus(context);
  }
}
