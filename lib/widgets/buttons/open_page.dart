import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class OpenPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.arrow_forward_ios_outlined,
      color: Theme.of(context).accentIconTheme.color,
      size: Theme.of(context).accentIconTheme.size,
    );
  }
}
