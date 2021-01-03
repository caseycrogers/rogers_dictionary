import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/models/search_options.dart';

class SearchOptionsView extends StatelessWidget {
  final void Function(SearchOptions) onSearchChanged;

  SearchOptionsView({@required this.onSearchChanged});

  @override
  Widget build(BuildContext context) {
    final dictionaryPageModel = DictionaryPageModel.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      color: Theme.of(context).accentColor,
      child: Wrap(
        children: [
          Row(
            children: [
              Text('sort: '),
              DropdownButton<SortOrder>(
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
            ],
          ),
          Row(
            children: [
              Text('ignore accents'),
              Switch(
                  value: dictionaryPageModel.searchOptions.ignoreAccents,
                  onChanged: (value) => onSearchChanged(dictionaryPageModel
                      .searchOptions
                      .copyWith(newIgnoreAccents: value))),
            ],
          ),
        ],
      ),
    );
  }
}
