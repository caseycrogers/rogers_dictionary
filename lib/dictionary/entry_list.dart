import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';
import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/util/async_list_view.dart';
import 'package:rogers_dictionary/util/focus_utils.dart';
import 'package:rogers_dictionary/widgets/loading_text.dart';
import 'dart:core';

import 'package:rogers_dictionary/widgets/entry_page.dart';

class EntryList extends StatefulWidget {
  @override
  _EntryListState createState() => _EntryListState();
}

class _EntryListState extends State<EntryList> {
  String _currSearchString;
  Stream<Entry> _currStream;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize here because we need access to context.
    _currSearchString ??= DictionaryPageModel.of(context).searchStringModel.value;
    _currStream ??= getEntries();
  }

  Stream<Entry> getEntries() => MyApp.db.getEntries(searchString: _currSearchString, startAfter: DictionaryPageModel.of(context).startAfter);

  @override
  Widget build(BuildContext context) {
    var searchStringModel = context.watch<SearchStringModel>();
    // Only reset state when the search string has changed.
    if (searchStringModel.value != _currSearchString) {
      DictionaryPageModel.of(context).entries.clear();
      DictionaryPageModel.of(context).startAfter = '';
      _currSearchString = searchStringModel.value;
      _currStream = getEntries();
    }
    return AsyncListView<Entry>(
        initialData: DictionaryPageModel.of(context).entries,
        stream: _currStream,
        itemBuilder: _buildRow,
        controller: DictionaryPageModel.of(context).scrollController,
    );
  }

  Widget _buildRow(
      BuildContext context, AsyncSnapshot<List<Entry>> snapshot, int index) {
    if (!snapshot.hasData || snapshot.data.isEmpty) return LoadingText();
    DictionaryPageModel.of(context).entries = snapshot.data;
    var entries = snapshot.data;
    var isSelected = entries[index].headword ==
        DictionaryPageModel.of(context).selectedHeadword;
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
          if (isSelected) return;
          unFocus(context);
          Navigator.of(context).pushNamed(
            EntryPage.route + '/${entries[index].urlEncodedHeadword}',
            arguments: DictionaryPageModel.copy(context, entries[index]),
          );
        });
  }

  BoxDecoration _shadowDecoration(bool isSelected) {
    if (!isSelected) return BoxDecoration(color: Theme.of(context).cardColor);
    return BoxDecoration(boxShadow: [
      BoxShadow(
        color: Theme.of(context).selectedRowColor,
      ),
    ]);
  }
}
