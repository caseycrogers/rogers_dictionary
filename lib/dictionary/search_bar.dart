import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  @override
  _SearchBarState createState() => _SearchBarState(filter);

  final filter = TextEditingController();
}

class _SearchBarState extends State<SearchBar> {
  TextEditingController _filter;

  _SearchBarState(this._filter);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _filter,
      decoration: new InputDecoration(
          prefixIcon: new Icon(Icons.search),
          hintText: 'search....'
      ),
    );
  }
}
