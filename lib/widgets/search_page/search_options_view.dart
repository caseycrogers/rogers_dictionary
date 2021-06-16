import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/models/entry_search_model.dart';
import 'package:rogers_dictionary/models/search_page_model.dart';
import 'package:rogers_dictionary/models/search_settings_model.dart';

class SearchOptionsView extends StatelessWidget {
  SearchOptionsView(this._exteriorContext)
      : _entrySearchModel = DictionaryPageModel.readFrom(_exteriorContext)
            .translationPageModel
            .value
            .searchPageModel
            .entrySearchModel;

  final BuildContext _exteriorContext;
  final EntrySearchModel _entrySearchModel;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EntrySearchModel>.value(
      value: _entrySearchModel,
      builder: (BuildContext context, _) =>
          Selector<EntrySearchModel, SearchSettingsModel>(
        selector: (_, entrySearch) => entrySearch.searchSettingsModel,
        builder: (BuildContext context, SearchSettingsModel settingsModel, _) =>
            Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('sort: '),
                ...SortOrder.values.map(
                  (sortBy) => TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor: settingsModel.sortBy == sortBy
                            ? Colors.black12
                            : null,
                        textStyle: const TextStyle(fontSize: 18),
                        primary: Colors.black,
                        animationDuration: settingsModel.sortBy == sortBy
                            ? Duration.zero
                            : const Duration(milliseconds: 300)),
                    child: Text(sortBy.toString().split('.').last),
                    onPressed: () {
                      if (settingsModel.sortBy == sortBy) {
                        return;
                      }
                      _updateOptions(_exteriorContext, newSortBy: sortBy);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _updateOptions(BuildContext context, {SortOrder? newSortBy}) {
    SearchPageModel.readFrom(_exteriorContext)
        .entrySearchModel
        .onSearchStringChanged(
          newSearchSettings:
              _entrySearchModel.searchSettingsModel.copy(newSortBy: newSortBy),
        );
  }
}
