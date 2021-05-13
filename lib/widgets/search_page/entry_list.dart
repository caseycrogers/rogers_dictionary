import 'dart:ui';
import 'dart:core';

import 'package:async_list_view/async_list_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rogers_dictionary/entry_database/entry_builders.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/models/search_page_model.dart';
import 'package:rogers_dictionary/models/entry_search_model.dart';
import 'package:rogers_dictionary/pages/dictionary_page.dart';
import 'package:rogers_dictionary/protobufs/entry.pb.dart';
import 'package:rogers_dictionary/util/delayed.dart';
import 'package:rogers_dictionary/widgets/search_page/entry_view.dart';
import 'package:rogers_dictionary/widgets/loading_text.dart';
import 'package:rogers_dictionary/widgets/buttons/open_page.dart';

class EntryList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: SearchPageModel.of(context).entrySearchModel,
      builder: (context, _) {
        var entrySearchModel = context.watch<EntrySearchModel>();
        if (entrySearchModel.isEmpty &&
            DictionaryPageModel.of(context).currentTab.value ==
                DictionaryTab.search)
          return _noResultsWidget(
              'Enter text above to search for a translation!');
        return AsyncListView<Entry>(
          // Maintains scroll state
          key: PageStorageKey(
              'entry_list-tab${DictionaryPageModel.of(context).currentTab.value.index}'),
          padding: EdgeInsets.zero,
          noResultsWidgetBuilder: (context) => _noResultsWidget(
              entrySearchModel.favoritesOnly
                  ? 'No results! Try favoriting an entry first.'
                  : 'No results! Check for typos.'),
          initialData: entrySearchModel.entries,
          stream: entrySearchModel.entryStream,
          loadingWidget: Delayed(
            delay: Duration(milliseconds: 100),
            initialChild: Container(),
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: LoadingText(),
            ),
          ),
          itemBuilder: _buildRow,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        );
      },
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
          final entry = snapshot.data![index];
          var isSelected = entry.headword.urlEncodedHeadword ==
              searchPageModel.currSelectedHeadword;
          return Column(
            children: [
              InkWell(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      children: [
                        Expanded(child: EntryView.asPreview(entry)),
                        OpenPage(),
                      ],
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    ),
                  ),
                  onTap: () {
                    if (isSelected) return;
                    dictionaryModel.onEntrySelected(context, entry);
                  }),
              if (index < snapshot.data!.length - 1)
                Divider(
                  thickness: 1.0,
                  height: 1.0,
                ),
            ],
          );
        },
      );

  Widget _noResultsWidget(String text) => Padding(
        padding: EdgeInsets.all(30.0),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      );
}
