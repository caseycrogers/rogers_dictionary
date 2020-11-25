import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rogers_dictionary/dictionary/search_string_model.dart';


class SearchBar extends StatefulWidget {
  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  bool _hasText = false;
  TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();

    _textEditingController = TextEditingController();
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
    context.read<SearchStringModel>().updateSearchString(newText);
    setState(() {
      _hasText = _textEditingController.text.isNotEmpty;
    });
  }
}


