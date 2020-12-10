import 'package:flutter/material.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';

class SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var dictionaryPageModel = DictionaryPageModel.of(context);
    var controller =
        TextEditingController.fromValue(dictionaryPageModel.textValue);
    var _hasText = controller.text.isNotEmpty;
    return Container(
      color: Theme.of(context).dialogBackgroundColor,
      child: FocusScope(
          child: Focus(
              onFocusChange: (hasFocus) =>
                  dictionaryPageModel.searchBarHasFocus = hasFocus,
              child: TextField(
                // autofocus: dictionaryPageModel.searchBarHasFocus,
                style: TextStyle(fontSize: 20.0),
                controller: controller,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: _hasText
                        ? IconButton(
                            onPressed: () {
                              controller.clear();
                              DictionaryPageModel.onSearchStringChanged(
                                  context, '');
                            },
                            icon: Icon(Icons.clear),
                          )
                        : null,
                    hintText: 'search...'),
                onChanged: (newSearchString) =>
                    DictionaryPageModel.onSearchStringChanged(
                        context, newSearchString),
              ))),
    );
  }
}
