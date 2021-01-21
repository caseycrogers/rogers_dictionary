import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rogers_dictionary/models/search_page_model.dart';
import 'package:rogers_dictionary/models/entry_search_model.dart';
import 'package:rogers_dictionary/widgets/dictionary_page/search_options_view.dart';

class SearchBar extends StatefulWidget {
  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  FocusNode _focusNode;
  TextEditingController _controller;

  SearchPageModel get dictionaryPageModel => SearchPageModel.of(context);

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
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0).subtract(EdgeInsets.only(right: 8.0)),
      color: Theme.of(context).primaryColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            fit: FlexFit.tight,
            child: Container(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40.0),
                child: Container(
                  color: Theme.of(context).backgroundColor,
                  child: Selector<EntrySearchModel, String>(
                    selector: (context, entrySearchModel) =>
                        entrySearchModel.searchString,
                    builder: (context, searchString, _) => TextField(
                      focusNode: _focusNode,
                      style: TextStyle(fontSize: 20.0),
                      controller: _controller,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        suffixIcon: searchString.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _controller.clear();
                                  dictionaryPageModel.onSearchChanged(
                                      newSearchString: '');
                                },
                                icon: Icon(Icons.clear),
                              )
                            : null,
                        hintText: 'search...',
                        border: InputBorder.none,
                      ),
                      onChanged: (searchString) => dictionaryPageModel
                          .onSearchChanged(newSearchString: searchString),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SearchOptionsView(
              onSearchChanged: (newSearchOptions) => dictionaryPageModel
                  .onSearchChanged(newSearchOptions: newSearchOptions)),
        ],
      ),
    );
  }
}
