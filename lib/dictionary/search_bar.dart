import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rogers_dictionary/dictionary/search_string_model.dart';

class SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextEditingController textEditingController = TextEditingController();
    textEditingController.addListener(() {
      context.read<SearchStringModel>().updateSearchString(textEditingController.text);
    });
    return TextField(
      controller: textEditingController,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.search),
          suffixIcon: IconButton(
            onPressed: () => textEditingController.clear(),
            icon: Icon(Icons.clear),
          ),
          hintText: 'search...'
      ),

    );
  }
}
