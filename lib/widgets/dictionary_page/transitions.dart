import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class DictionaryPageTransition extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;

  DictionaryPageTransition({@required this.child, @required this.animation});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(child: child, opacity: animation);
  }
}
