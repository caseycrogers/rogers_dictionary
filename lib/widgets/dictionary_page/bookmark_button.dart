import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';

class BookmarkButton extends StatefulWidget {
  @override
  _BookmarkButtonState createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton> {
  bool _bookmarksOnly;
  SearchPageModel searchPageModel;

  @override
  void initState() {
    super.initState();
    searchPageModel = SearchPageModel.readFrom(context);
    _bookmarksOnly = searchPageModel.entrySearchModel.bookmarksOnly;
  }

  @override
  Widget build(BuildContext context) => IconButton(
        color: _bookmarksOnly ? Colors.white : Colors.black,
        icon: Icon(
          Icons.star,
          size: 28.0,
        ),
        onPressed: () => _toggle(),
      );

  void _toggle() {
    setState(() {
      _bookmarksOnly = !_bookmarksOnly;
      searchPageModel.entrySearchModel.bookmarksOnly = _bookmarksOnly;
    });
  }
}
