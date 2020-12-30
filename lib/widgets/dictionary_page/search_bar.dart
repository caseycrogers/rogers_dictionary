import 'package:flutter/material.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/models/search_options.dart';

import 'package:rogers_dictionary/widgets/dictionary_page/search_options_view.dart';

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
          SearchOptionsView(
            onSearchChanged: (newSearchOptions) =>
                _onSearchChanged(newSearchOptions: newSearchOptions),
            onExpansionChanged: (isExpanded) => setState(
                () => dictionaryPageModel.expandSearchOptions = isExpanded),
          ),
          if (!dictionaryPageModel.expandSearchOptions)
            Divider(
              thickness: 1.0,
              height: 1.0,
            ),
        ],
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
