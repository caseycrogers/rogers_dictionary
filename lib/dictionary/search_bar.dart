import 'dart:async';

import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  final TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
