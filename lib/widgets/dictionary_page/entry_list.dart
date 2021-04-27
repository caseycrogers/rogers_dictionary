import 'dart:ui';

import 'package:async_list_view/async_list_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/models/entry_search_model.dart';
import 'package:rogers_dictionary/pages/dictionary_page.dart';
import 'package:rogers_dictionary/widgets/dictionary_page/entry_view.dart';
import 'package:rogers_dictionary/widgets/loading_text.dart';
import 'dart:core';

class EntryList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0.0,
      color: Theme.of(context).cardColor,
      child: ChangeNotifierProvider.value(
        value: SearchPageModel.of(context).entrySearchModel,
        builder: (context, _) {
          var entrySearchModel = context.watch<EntrySearchModel>();
          if (entrySearchModel.isEmpty &&
              DictionaryPageModel.of(context).currentTab.value ==
                  DictionaryTab.search)
            return Padding(
              padding: EdgeInsets.all(30.0),
              child: Text('Enter text above to search for a translation!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                  )),
            );
          final controller = ScrollController(
              initialScrollOffset: entrySearchModel.initialScrollOffset);
          controller.addListener(
              () => entrySearchModel.initialScrollOffset = controller.offset);
          return AsyncListView<Entry>(
            noResultsWidgetBuilder: (context) => Container(
              child: Padding(
                padding: EdgeInsets.all(30.0),
                child: Text(
                    entrySearchModel.favoritesOnly
                        ? 'No results! Try favoriting an entry first.'
                        : 'No results! Check for typos.',
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
            itemBuilder: _buildRow,
            controller: controller,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          );
        },
      ),
    );
  }

  Widget _buildRow(BuildContext context, AsyncSnapshot<List<Entry>> snapshot,
          int index) =>
      Builder(
        builder: (BuildContext context) {
          final dictionaryModel = DictionaryPageModel.of(context);
          var searchPageModel = SearchPageModel.of(context);
          if (snapshot.hasError) print(snapshot.error);
          if (!snapshot.hasData) return LoadingText();
          var entry = snapshot.data[index];
          var isSelected =
              entry.urlEncodedHeadword == searchPageModel.currSelectedHeadword;
          return Column(
            children: [
              InkWell(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                    dictionaryModel.onEntrySelected(context, entry);
                  }),
              if (index < snapshot.data.length - 1)
                Divider(
                  thickness: 1.0,
                  height: 1.0,
                ),
            ],
          );
        },
      );

  BoxDecoration _shadowDecoration(BuildContext context, bool isSelected) {
    if (!isSelected) return BoxDecoration(color: Theme.of(context).cardColor);
    return BoxDecoration(boxShadow: [
      BoxShadow(
        color: Theme.of(context).selectedRowColor,
      ),
    ]);
  }
}
