import 'package:flutter/material.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';

class SearchBar extends StatefulWidget {
  final String _initialString;

  SearchBar(this._initialString);

  @override
  _SearchBarState createState() => _SearchBarState(_initialString);
}

class _SearchBarState extends State<SearchBar> {
  bool _hasText = false;
  TextEditingController _textEditingController;
  final String _initialString;

  _SearchBarState(this._initialString);

  @override
  void initState() {
    super.initState();

    _textEditingController = TextEditingController(text: _initialString);
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      child: Focus(
        child: TextField(
          controller: _textEditingController,
          decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              suffixIcon: _hasText ? IconButton(
                onPressed: () {
                  _textEditingController.clear();
                  _onTextChanged('');
                },
                icon: Icon(Icons.clear),
              ) : null,
              hintText: 'search...'
          ),
          onChanged: _onTextChanged,
        )
      )
    );
  }

  void _onTextChanged(String newText) {
    if (DictionaryPageModel.of(context).searchStringModel.value == newText) return;
    DictionaryPageModel.of(context).searchStringModel.value = newText;
    setState(() {
      _hasText = _textEditingController.text.isNotEmpty;
    });
  }
}


