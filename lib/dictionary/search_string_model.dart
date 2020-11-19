import 'package:flutter/material.dart';

class SearchStringModel extends ChangeNotifier {
  String _currSearchString = '';

  String get searchString => _currSearchString;

  void updateSearchString(String searchString) {
    print('asdfasdfasdf');
    if (searchString == _currSearchString) return;
    print('updating!: $searchString');
    _currSearchString = searchString;
    notifyListeners();
  }
}