import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class DictionaryPageTransition extends StatelessWidget {
  const DictionaryPageTransition(this.child, this.animation);

  final Widget child;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(child: child, opacity: animation);
  }
}
