import 'package:flutter/material.dart';

class SearchStringModel extends ChangeNotifier {
  String _currSearchString = '';

  String get text => _currSearchString;

  void updateSearchString(String searchString) {
    if (searchString == _currSearchString) return;
    _currSearchString = searchString;
    notifyListeners();
  }
}