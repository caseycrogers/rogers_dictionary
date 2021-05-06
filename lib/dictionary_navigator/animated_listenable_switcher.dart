import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:rogers_dictionary/widgets/search_page/transitions.dart';

class AnimatedListenableSwitcher<T> extends StatelessWidget {
  final ValueListenable<T> valueListenable;
  final ValueWidgetBuilder<T> builder;

  AnimatedListenableSwitcher(
      {required this.valueListenable, required this.builder});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<T>(
      valueListenable: valueListenable,
      builder: (context, value, child) => AnimatedSwitcher(
        transitionBuilder: (child, animation) =>
            DictionaryPageTransition(child: child, animation: animation),
        duration: Duration(milliseconds: 200),
        reverseDuration: Duration(milliseconds: 100),
        child: builder(context, value, child),
      ),
    );
  }
}
