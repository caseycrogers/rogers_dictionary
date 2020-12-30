import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/models/search_options.dart';

class SearchOptionsView extends StatelessWidget {
  void Function(SearchOptions) onSearchChanged;
  void Function(bool) onExpansionChanged;

  SearchOptionsView(
      {@required this.onSearchChanged, @required this.onExpansionChanged});

  @override
  Widget build(BuildContext context) {
    final dictionaryPageModel = DictionaryPageModel.of(context);
    return ListTileTheme(
      dense: true,
      minVerticalPadding: 0.0,
      child: Theme(
        data: ThemeData(
          visualDensity: VisualDensity(vertical: -4),
        ),
        child: ExpansionTile(
            key: PageStorageKey('search_options_tile'),
            initiallyExpanded: dictionaryPageModel.expandSearchOptions,
            collapsedBackgroundColor: Colors.grey.shade100,
            backgroundColor: Theme.of(context).cardColor,
            title: Text(
              'Search Options',
              style: TextStyle(color: Colors.black, fontSize: 18.0),
            ),
            tilePadding: EdgeInsets.symmetric(horizontal: 12.0),
            childrenPadding: EdgeInsets.symmetric(horizontal: 12.0),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text('sort:'),
                      ),
                      Container(
                        child: DropdownButton<SortOrder>(
                          style: TextStyle(color: Colors.black, fontSize: 20.0),
                          value: dictionaryPageModel.searchOptions.sortBy,
                          items: SortOrder.values
                              .map((sortOrder) => DropdownMenuItem(
                                    value: sortOrder,
                                    child: Text(
                                      sortOrder.toString().split('.').last,
                                    ),
                                  ))
                              .toList(),
                          onChanged: (SortOrder sortBy) => onSearchChanged(
                              dictionaryPageModel.searchOptions
                                  .copyWith(newSortBy: sortBy)),
                          underline: Container(),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text('ignore accents'),
                      ),
                      Switch(
                          value:
                              dictionaryPageModel.searchOptions.ignoreAccents,
                          onChanged: (value) => onSearchChanged(
                              dictionaryPageModel.searchOptions
                                  .copyWith(newIgnoreAccents: value))),
                    ],
                  ),
                ],
              ),
            ],
            onExpansionChanged: onExpansionChanged),
      ),
    );
  }
}
