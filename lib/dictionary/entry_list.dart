import 'dart:ui';

import 'package:async_list_view/async_list_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/models/search_string_model.dart';
import 'package:rogers_dictionary/widgets/loading_text.dart';
import 'dart:core';

import 'package:rogers_dictionary/widgets/entry_page.dart';

class EntryList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var dictionaryPageModel = DictionaryPageModel.of(context);
    return ChangeNotifierProvider.value(
      value: dictionaryPageModel.searchStringModel,
      builder: (context, _) {
        var searchString = context.watch<SearchStringModel>().value;
        if (searchString.isEmpty)
          return Padding(
            padding: EdgeInsets.all(30.0),
            child: Center(
                child: Text("Enter text above to search for a translation!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                    ))),
          );
        return AsyncListView<Entry>(
          initialData: dictionaryPageModel.entries,
          stream: dictionaryPageModel.entryStream,
          loadingWidget: Container(
            padding: EdgeInsets.all(16.0),
            child: LoadingText(),
          ),
          itemBuilder: _buildRow,
          controller: dictionaryPageModel.scrollController,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        );
      },
    );
  }

  Widget _buildRow(
      BuildContext context, AsyncSnapshot<List<Entry>> snapshot, int index) {
    if (!snapshot.hasData) return LoadingText();
    DictionaryPageModel.of(context).entries = snapshot.data;
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
