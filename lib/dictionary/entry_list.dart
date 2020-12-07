import 'dart:async';
import 'dart:ui';

import 'package:async_list_view/async_list_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';
import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/pages/dictionary_page.dart';
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
    _currSearchString ??=
        DictionaryPageModel.of(context).searchStringModel.value;
    _currStream ??= getEntries();
  }

  Stream<Entry> getEntries() => MyApp.db.getEntries(
      searchString: _currSearchString,
      startAfter: DictionaryPageModel.of(context).startAfter);

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
    if (_currSearchString.isEmpty)
      return Padding(
        padding: EdgeInsets.all(30.0),
        child: Center(
            child: Text("Enter text above to search for a translation!",
                textAlign: TextAlign.center, style: TextStyle(
                  color: Colors.grey,
                ))),
      );
    return AsyncListView<Entry>(
      initialData: DictionaryPageModel.of(context).entries,
      stream: _currStream,
      loadingWidget: Container(
        padding: EdgeInsets.all(16.0),
        child: LoadingText(),
      ),
      itemBuilder: _buildRow,
      controller: DictionaryPageModel.of(context).scrollController,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
    );
  }

  Widget _buildRow(
      BuildContext context, AsyncSnapshot<List<Entry>> snapshot, int index) {
    if (!snapshot.hasData) return LoadingText();
    DictionaryPageModel.of(context).entries = snapshot.data;
    DictionaryPageModel.of(context).startAfter =
        snapshot.data.last.urlEncodedHeadword;
    var entries = snapshot.data;
    var isSelected = entries[index].headword ==
        DictionaryPageModel.of(context).selectedHeadword;
    return Column(
      children: [
        InkWell(
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
                DictionaryPage.route +
                    '?entry=${entries[index].urlEncodedHeadword}',
                arguments: DictionaryPageModel.copy(context, entries[index]),
              );
            }),
        if (index < snapshot.data.length - 1)
          Divider(
            thickness: 1.0,
            height: 1.0,
          ),
      ],
    );
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
