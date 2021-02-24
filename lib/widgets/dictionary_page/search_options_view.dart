import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/models/entry_search_model.dart';
import 'package:rogers_dictionary/models/search_settings_model.dart';

class SearchOptionsView extends StatelessWidget {
  final BuildContext _exteriorContext;
  final EntrySearchModel _entrySearchModel;

  SearchOptionsView(this._exteriorContext)
      : _entrySearchModel = DictionaryPageModel.readFrom(_exteriorContext)
            .currSearchPageModel
            .value
            .entrySearchModel;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _entrySearchModel,
      builder: (context, _) => Material(
        elevation: 4.0,
        child: Selector<EntrySearchModel, SearchSettingsModel>(
          selector: (_, entrySearch) => entrySearch.searchSettingsModel,
          builder: (context, settingsModel, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('sort: '),
                  ]..addAll(SortOrder.values.map((sortBy) => TextButton(
                        style: TextButton.styleFrom(
                            backgroundColor: settingsModel.sortBy == sortBy
                                ? Colors.black12
                                : null,
                            textStyle: TextStyle(fontSize: 18.0),
                            primary: Colors.black,
                            animationDuration: settingsModel.sortBy == sortBy
                                ? Duration.zero
                                : Duration(milliseconds: 300)),
                        child: Text(sortBy.toString().split('.').last),
                        onPressed: () {
                          if (settingsModel.sortBy == sortBy) return;
                          _updateOptions(_exteriorContext, newSortBy: sortBy);
                        },
                      ))),
                ),
              ),
              Divider(height: 0.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Text('ignore accents'),
                    Switch(
                      value: settingsModel.ignoreAccents,
                      onChanged: (newIgnoreAccents) => _updateOptions(
                          _exteriorContext,
                          newIgnoreAccents: newIgnoreAccents),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateOptions(BuildContext context,
      {SortOrder newSortBy, bool newIgnoreAccents}) {
    DictionaryPageModel.of(context).onSearchChanged(
        newSearchSettings: _entrySearchModel.searchSettingsModel
            .copy(newSortBy: newSortBy, newIgnoreAccents: newIgnoreAccents));
  }
}
