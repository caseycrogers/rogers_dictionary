import 'package:flutter/material.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/models/search_options.dart';
import 'package:rogers_dictionary/util/string_utils.dart';

class SearchBar extends StatefulWidget {
  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  FocusNode _focusNode;
  bool _hasText;
  TextEditingController _controller;

  DictionaryPageModel get dictionaryPageModel =>
      DictionaryPageModel.of(context);

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_focusNode == null) {
      _focusNode = FocusNode();
      if (dictionaryPageModel.searchBarHasFocus)
        //_focusNode.requestFocus();
        _focusNode.addListener(
            () => dictionaryPageModel.searchBarHasFocus = _focusNode.hasFocus);
    }
    _controller = _controller ??
        TextEditingController(text: dictionaryPageModel.searchString);
    _hasText = _hasText ?? dictionaryPageModel.searchString.isNotEmpty;
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).dialogBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            focusNode: _focusNode,
            style: TextStyle(fontSize: 20.0),
            controller: _controller,
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                suffixIcon: _hasText
                    ? IconButton(
                        onPressed: () {
                          _controller.clear();
                          _onSearchChanged(newSearchString: '');
                        },
                        icon: Icon(Icons.clear),
                      )
                    : null,
                hintText: 'search...'),
            onChanged: (searchString) =>
                _onSearchChanged(newSearchString: searchString),
          ),
          _searchOptions(),
          if (!dictionaryPageModel.expandSearchOptions)
            Divider(
              thickness: 1.0,
              height: 1.0,
            ),
        ],
      ),
    );
  }

  Widget _searchOptions() {
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
                        onChanged: (SortOrder sortBy) => _onSearchChanged(
                            newSearchOptions: dictionaryPageModel.searchOptions
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
                        value: dictionaryPageModel.searchOptions.ignoreAccents,
                        onChanged: (value) => _onSearchChanged(
                            newSearchOptions: dictionaryPageModel.searchOptions
                                .copyWith(newIgnoreAccents: value))),
                  ],
                ),
              ],
            ),
          ],
          onExpansionChanged: (isExpanded) => setState(
              () => dictionaryPageModel.expandSearchOptions = isExpanded),
        ),
      ),
    );
  }

  void _onSearchChanged(
      {String newSearchString, SearchOptions newSearchOptions}) {
    DictionaryPageModel.onSearchChanged(
        context,
        newSearchString ?? DictionaryPageModel.of(context).searchString,
        newSearchOptions ?? DictionaryPageModel.of(context).searchOptions);
    setState(() {
      _hasText = newSearchString?.isNotEmpty ?? _hasText;
    });
  }
}
