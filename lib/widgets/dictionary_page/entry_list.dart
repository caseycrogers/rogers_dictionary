import 'dart:ui';

import 'package:async_list_view/async_list_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/models/entry_search_model.dart';
import 'package:rogers_dictionary/widgets/loading_text.dart';
import 'dart:core';

import 'file:///C:/Users/Waffl/Documents/code/rogers_dictionary/lib/widgets/dictionary_page/entry_view.dart';

class EntryList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      child: ChangeNotifierProvider.value(
        value: DictionaryPageModel.of(context).entrySearchModel,
        builder: (context, _) {
          var entrySearchModel = context.watch<EntrySearchModel>();
          if (entrySearchModel.isEmpty)
            return Padding(
              padding: EdgeInsets.all(30.0),
              child: Text('Enter text above to search for a translation!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                  )),
            );
          return AsyncListView<Entry>(
            noResultsWidgetBuilder: (context) => Container(
              child: Padding(
                padding: EdgeInsets.all(30.0),
                child: Text('No results! Check for typos.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                    )),
              ),
            ),
            initialData: entrySearchModel.entries,
            stream: entrySearchModel.entryStream,
            loadingWidget: Container(
              padding: EdgeInsets.all(16.0),
              child: LoadingText(),
            ),
            itemBuilder: _buildRow(entrySearchModel),
            controller: entrySearchModel.scrollController,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          );
        },
      ),
    );
  }

  // A higher order function because higher order functions are cool.
  Widget Function(BuildContext, AsyncSnapshot<List<Entry>>, int) _buildRow(
      EntrySearchModel entrySearchModel) {
    return (context, snapshot, index) {
      if (!snapshot.hasData) return LoadingText();
      entrySearchModel.updateEntries(snapshot.data);
      var entry = snapshot.data[index];
      var isSelected = entry.urlEncodedHeadword ==
          DictionaryPageModel.of(context).selectedEntryHeadword;
      return Column(
        children: [
          InkWell(
              child: Container(
                decoration: _shadowDecoration(context, isSelected),
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    Expanded(child: EntryView.asPreview(entry)),
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
                DictionaryPageModel.onEntrySelected(context, entry);
              }),
          if (index < snapshot.data.length - 1)
            Divider(
              thickness: 1.0,
              height: 1.0,
            ),
        ],
      );
    };
  }

  BoxDecoration _shadowDecoration(BuildContext context, bool isSelected) {
    if (!isSelected) return BoxDecoration(color: Theme.of(context).cardColor);
    return BoxDecoration(boxShadow: [
      BoxShadow(
        color: Theme.of(context).selectedRowColor,
      ),
    ]);
  }
}
