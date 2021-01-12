import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/models/entry_search_model.dart';
import 'package:rogers_dictionary/models/search_options.dart';

class SearchOptionsMenu extends StatelessWidget {
  final DictionaryPageModel _dictionaryPageModel;

  SearchOptionsMenu(this._dictionaryPageModel);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4.0,
      child: ListenableProvider.value(
        value: _dictionaryPageModel.entrySearchModel,
        child: Selector<EntrySearchModel, SearchOptions>(
          selector: (context, entrySearchModel) =>
              entrySearchModel.searchOptions,
          builder: (context, searchOptions, _) => Column(
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
                            backgroundColor: searchOptions.sortBy == sortBy
                                ? Colors.black12
                                : null,
                            textStyle: TextStyle(fontSize: 18.0),
                            primary: Colors.black,
                            animationDuration: searchOptions.sortBy == sortBy
                                ? Duration.zero
                                : Duration(milliseconds: 300)),
                        child: Text(sortBy.toString().split('.').last),
                        onPressed: () {
                          if (searchOptions.sortBy == sortBy) return;
                          _updateOptions(context, newSortBy: sortBy);
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
                      value: _dictionaryPageModel.searchOptions.ignoreAccents,
                      onChanged: (newIgnoreAccents) => _updateOptions(context,
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
    _dictionaryPageModel.onSearchChanged(
        newSearchOptions: _dictionaryPageModel.searchOptions.copyWith(
            newSortBy: newSortBy, newIgnoreAccents: newIgnoreAccents));
  }
}
