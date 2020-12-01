import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';
import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/util/focus_utils.dart';
import 'package:rogers_dictionary/widgets/loading_text.dart';
import 'dart:core';

import 'package:rogers_dictionary/widgets/entry_page.dart';
import 'package:stream_summary_builder/stream_summary_builder.dart';

class EntryList extends StatefulWidget {
  @override
  _EntryListState createState() => _EntryListState();

  EntryList();
}

class _EntryListState extends State<EntryList> {
  get _dictionaryPageModel => DictionaryPageModel.of(context);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var searchStringModel = context.watch<SearchStringModel>();
    var entryStream = MyApp.db.getEntries(
        searchString: searchStringModel.value,
        startAfter: _dictionaryPageModel.startAfter);
    return StreamSummaryBuilder<Entry, List<Entry>>(
        initialData: _dictionaryPageModel.entries,
        stream: entryStream,
        fold: (_, value) => _dictionaryPageModel.entries..add(value),
        builder: (_, entriesSnap) {
          return _buildEntries(entriesSnap.data, entriesSnap.connectionState);
        });
  }

  Widget _buildEntries(List<Entry> entries, ConnectionState state) {
    return ListView.separated(
      itemCount:
          state == ConnectionState.done ? entries.length : entries.length + 1,
      itemBuilder: (context, index) {
        //if (state == ConnectionState.waiting || index > entries.length - 5) {
        //  _resumeStream();
        //} else {
        //  _pauseStream();
        //}
        if (index == entries.length)
          return Container(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: LoadingText(),
          );
        // resume the stream if we're within 5 entries of the end of the list
        return _buildRow(entries, index);
      },
      separatorBuilder: (c, i) => Divider(
        thickness: 1,
        height: 1,
      ),
      controller: _dictionaryPageModel.scrollController,
    );
  }

  BoxDecoration _shadowDecoration(bool isSelected) {
    if (!isSelected)
      return BoxDecoration(color: Theme.of(context).cardColor);
    return BoxDecoration(boxShadow: [
      BoxShadow(
        color: Theme.of(context).selectedRowColor,
      ),
    ]);
  }

  Widget _buildRow(List<Entry> entries, int index) {
    var isSelected =
        entries[index].headword == _dictionaryPageModel.selectedHeadword;
    return InkWell(
          child: Container(
            decoration: _shadowDecoration(isSelected),
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                Expanded(child: EntryPage.asPreview(entries[index])),
                Icon(
                  Icons.arrow_forward_ios_outlined,
                  color: Theme.of(context).accentIconTheme.color,
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
          ),
          onTap: () {
            if (entries[index].headword ==
                _dictionaryPageModel.selectedHeadword) return;
            unFocus(context);
            Navigator.of(context).pushNamed(
              EntryPage.route + '/${entries[index].urlEncodedHeadword}',
              arguments: DictionaryPageModel.copy(context, entries[index]),
            );
          });
  }

  //void _pauseStream() {
  //  if (!_entryStreamSubscription.isPaused) _entryStreamSubscription.pause();
  //}

  //void _resumeStream() {
  //  if (_entryStreamSubscription.isPaused) _entryStreamSubscription.resume();
  //}

  void _scrollListener() {
    unFocus(context);
  }
}
