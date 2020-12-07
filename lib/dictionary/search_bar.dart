import 'package:flutter/material.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';

class SearchBar extends StatefulWidget {
  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  bool _hasText;
  TextEditingController _textEditingController;

  get _searchStringModel => DictionaryPageModel.of(context).searchStringModel;

  @override
  Widget build(BuildContext context) {
    _textEditingController ??= TextEditingController(text: _searchStringModel.value);
    _hasText ??= _textEditingController.text.isNotEmpty;
    return Container(
      color: Theme.of(context).dialogBackgroundColor,
      child: FocusScope(
        child: Focus(
          child: TextField(
            style: TextStyle(fontSize: 20.0),
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
      ),
    );
  }

  void _onTextChanged(String newText) {
    if (_searchStringModel.value == newText) return;
    _searchStringModel.value = newText;
    setState(() {
      _hasText = _textEditingController.text.isNotEmpty;
    });
  }
}


