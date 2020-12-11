import 'package:flutter/material.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';

class SearchBar extends StatefulWidget {
  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  FocusNode _focusNode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_focusNode == null) {
      _focusNode = FocusNode();
      if (DictionaryPageModel.of(context).searchBarHasFocus)
        //_focusNode.requestFocus();
        _focusNode.addListener(() => DictionaryPageModel.of(context)
            .searchBarHasFocus = _focusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var dictionaryPageModel = DictionaryPageModel.of(context);
    var controller =
        TextEditingController(text: dictionaryPageModel.searchString);
    var _hasText = controller.text.isNotEmpty;
    return Container(
      color: Theme.of(context).dialogBackgroundColor,
      child: TextField(
        focusNode: _focusNode,
        style: TextStyle(fontSize: 20.0),
        controller: controller,
        decoration: InputDecoration(
            prefixIcon: Icon(Icons.search),
            suffixIcon: _hasText
                ? IconButton(
                    onPressed: () {
                      controller.clear();
                      DictionaryPageModel.onSearchStringChanged(context, '');
                    },
                    icon: Icon(Icons.clear),
                  )
                : null,
            hintText: 'search...'),
        onChanged: (newSearchString) {
          DictionaryPageModel.onSearchStringChanged(context, newSearchString);
        },
      ),
    );
  }
}
