import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchStringModel extends ValueNotifier {
  SearchStringModel(String searchString) : super(searchString);

  SearchStringModel.empty() : super('');
}
